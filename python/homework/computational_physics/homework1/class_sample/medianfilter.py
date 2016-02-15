# median filter


def medianfilter(L=None):
    import numpy as np
    with open('test.txt') as file:
        xin = [float(element) for line in file for element in line.split()]
        xout = np.zeros(len(xin))
        L=int(L)
        Lwing = (L-1)/2
        N=len(xin)
        for i in range(N):
            print i
            if i < Lwing:
                xpart=xin[0:i+Lwing+1]
                xout[i]=sum(xpart)/len(xpart)
            elif i>= N - Lwing:
                xpart=xin[i-Lwing:N]
                xout[i]=sum(xpart)/len(xpart)
            else:
                xpart=xin[i-Lwing:i+Lwing+1]
                xout[i]=sum(xpart)/len(xpart)
    return xout
            
    