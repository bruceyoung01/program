import numpy as np
def running_average(x, N):
    y = np.zeros((len(x),))
    for i in range(len(x)):
        y[i] = np.sum(x[i:(i+N)])
    return y/N
