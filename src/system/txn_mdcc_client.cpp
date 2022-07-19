//
// Created by Zhihan Guo on 7/12/22.
//

#include <cmath>
#include "txn.h"
#include "row.h"
#include "workload.h"
#include "ycsb.h"
#include "worker_thread.h"
#include "table.h"
#include "catalog.h"
#include "index_btree.h"
#include "index_hash.h"
#include "helper.h"
#include "manager.h"
#include "query.h"
#include "txn_table.h"
#include "cc_manager.h"
#include "store_procedure.h"
#include "ycsb_store_procedure.h"
#include "tpcc_store_procedure.h"
#include "tpcc_query.h"
#include "tpcc_helper.h"

#include "tictoc_manager.h"
#include "lock_manager.h"
#include "f1_manager.h"
#include "occ_manager.h"
#if CC_ALG == NO_WAIT || CC_ALG == WAIT_DIE
#include "row_lock.h"
#endif
#include "log.h"
#include "redis_client.h"
#include "azure_blob_client.h"


// MDCC client (coordinator)

RC TxnManager::process_mdcc_singlepart(RC rc) {
    process_mdcc_local_phase1(rc);
    int num_acceptors = (int) g_num_storage_nodes + 1;
#if BALLOT_TYPE == BALLOT_CLASSIC
    int quorum = (int) floor(num_acceptors / 2) + 1;
#else
    int quorum = (int) floor(num_acceptors / 4 * 3) + 1;
#endif
    // wait quorum for local partition
    rpc_log_semaphore->wait();
    increment_replied_acceptors(g_node_id);
    while (get_replied_acceptors(g_node_id) < quorum) {}
    _cc_manager->cleanup(rc);
    _finish_time = get_sys_clock();
    _txn_state = (rc == COMMIT)? COMMITTED : ABORTED;
    return rc;
}

RC TxnManager::process_mdcc_phase1() {
    // send proposal for all updates
    process_mdcc_local_phase1(COMMIT);
    for (auto it = _remote_nodes_involved.begin(); it != _remote_nodes_involved
        .end(); it++) {
        // init replied_acceptors
        replied_acceptors[it->first] = 0;
        _decision = COMMIT;
        SundialRequest::NodeData *participant;
        if (BALLOT_TYPE == BALLOT_CLASSIC) {
            // send proposal to leader (participant)
            SundialRequest &request = it->second->request;
            SundialResponse &response = it->second->response;
            request.Clear();
            response.Clear();
            request.set_txn_id(get_txn_id());
            request.set_request_type(SundialRequest::MDCC_Propose);
            // set node id as self so that the acceptor can find coordinator
            request.set_node_id(g_node_id);
            // attach coordinator
            participant = request.add_nodes();
            participant->set_nid(g_node_id);
            // attach participants
            for (auto itr = _remote_nodes_involved.begin(); itr !=
                _remote_nodes_involved.end(); itr++) {
                participant = request.add_nodes();
                participant->set_nid(it->first);
            }
            // build request
            ((CC_MAN *) _cc_manager)->build_prepare_req(it->first, request);
            if (rpc_client->sendRequestAsync(this, it->first, request, response)
                == FAIL) {
                return FAIL; // self is down, no msg can be sent out
            }
        } else {
            // TODO: send proposal to acceptors (participant + storage nodes)
        }
    }
    // process learned options
    //  iterate through each remote node
    //  wait for quorum
    //  check one response, if prepared no, abort
    int num_acceptors = (int) g_num_storage_nodes + 1;
#if BALLOT_TYPE == BALLOT_CLASSIC
    int quorum = (int) floor(num_acceptors / 2) + 1;
#else
    int quorum = (int) floor(num_acceptors / 4 * 3) + 1;
#endif
    for (auto it = _remote_nodes_involved.begin(); it != _remote_nodes_involved
        .end(); it++) {
        // wait until quorum
        while (get_replied_acceptors(it->first) < quorum) {}
        if (it->second->state == ABORTED) {
            // abort txn
            _decision = ABORT;
            break;
        }
    }
    // wait quorum for local partition
    rpc_log_semaphore->wait();
    increment_replied_acceptors(g_node_id);
    while (get_replied_acceptors(g_node_id) < quorum) {}
    INC_INT_STATS(num_prepare, 1);
    _txn_state = PREPARED;
    return _decision;
}

RC TxnManager::process_mdcc_phase2(RC rc) {
    int num_acceptors = (int) g_num_storage_nodes + 1;
#if BALLOT_TYPE == BALLOT_CLASSIC
    int quorum = (int) floor(num_acceptors / 2) + 1;
#else
    int quorum = (int) floor(num_acceptors / 4 * 3) + 1;
#endif
    // start 2nd phase (send visibility request)
    int leader_id = -1;
    for (auto it = _remote_nodes_involved.begin(); it != _remote_nodes_involved
        .end(); it ++) {
        if (it->second->state == ABORTED || it->second->state == COMMITTED ||
            it->second->state == FAILED)
            continue;
        SundialRequest &request = it->second->request;
        SundialResponse &response = it->second->response;
        request.Clear();
        response.Clear();
        request.set_txn_id( get_txn_id() );
        request.set_node_id( it->first ); // used for response handling
        SundialRequest::RequestType type = (rc == COMMIT)?
                                           SundialRequest::MDCC_COMMIT_REQ :
                                           SundialRequest::MDCC_ABORT_REQ;
        request.set_request_type( type );
        rpc_client->sendRequestAsync(this, it->first, request, response);
        if (leader_id != -1)
            continue;
        for (size_t i = 0; i < g_num_storage_nodes; i++) {
            rpc_client->sendRequestAsync(this, i, request, response,
                                         true);
        }
        leader_id = (int) it->first;
    }
    _cc_manager->cleanup(rc);
    // wait for ack from all acceptors on all partitions
    while (get_replied_acceptors(leader_id) < quorum) {}
    _txn_state = (rc == COMMIT)? COMMITTED : ABORTED;
    return rc;
}

void
TxnManager::process_mdcc_local_phase1(RC rc, bool is_singlepart) {
    replied_acceptors[g_node_id] = 0;
    // self also acts as an acceptor
    string data = "[LSN] placehold:" + std::string('d', num_local_write * g_log_sz * 8);
    // only incr as redis/azure will decrement
    SundialRequest::RequestType type;
    State status;
    if (!is_singlepart) {
        status = PREPARED;
        type = SundialRequest::MDCC_Phase2a;
    } else {
        status = (rc == COMMIT)? COMMITTED : ABORTED;
        type = (rc == COMMIT)?
               SundialRequest::MDCC_COMMIT_REQ : SundialRequest::MDCC_ABORT_REQ;
    }
    rpc_log_semaphore->incr();
#if LOG_DEVICE == LOG_DVC_REDIS
    redis_client->log_async_data(g_node_id, get_txn_id(),
                                     status, data);
#elif LOG_DEVICE == LOG_DVC_AZURE_BLOB
    azure_blob_client->log_async_data(g_node_id, get_txn_id(),
    status, data);
#endif
    // act as a participant for local partiton, send 2a to acceptors
    // (copy and modified from phase2aclassic
    SundialRequest new_request;
    SundialResponse new_response;
    new_request.set_request_type(type);
    new_request.set_txn_id( get_txn_id() );
    new_request.set_node_id(g_node_id);
    assert(CC_ALG == OCC);
    ((CC_MAN *) _cc_manager)->build_local_req(new_request);
    for (size_t i = 0; i < g_num_storage_nodes; i++) {
        rpc_client->sendRequestAsync(this, i, new_request, new_response,
                                         true);
    }
}