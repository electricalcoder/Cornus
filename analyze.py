#!/usr/bin/python3

import numpy as np

data = []

with open('terminate_result', 'r') as f:
    for line in f:
        try:
            data.append(int(line.split(' ')[2]))
        except IndexError:
            pass

data = np.array(data)
print('p99: {}'.format(np.percentile(data, 99)))
print('p50: {}'.format(np.percentile(data, 50)))
print('min: {}'.format(np.min(data)))
