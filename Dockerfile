# syntax=docker/dockerfile:1.3-labs

FROM ubuntu:18.04

RUN DEBIAN_FRONTEND=noninteractive apt update && DEBIAN_FRONTEND=noninteractive apt install -y vim git net-tools emacs python3 python3-pip wget curl sudo openssh-server rsync iperf iptables inetutils-ping pssh

RUN pip3 install --upgrade pip

RUN cd /home && git clone https://github.com/electricalcoder/Cornus

RUN echo root > /home/Cornus/info.txt
RUN echo /home/Cornus/ >> /home/Cornus/info.txt

RUN cd /home/Cornus && DEBIAN_FRONTEND=noninteractive python3 install.py install_local 0
RUN cd /home/Cornus && python3 install.py config_local 0

RUN echo 'root:123' | chpasswd

RUN mkdir /run/sshd

RUN echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config
RUN echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
