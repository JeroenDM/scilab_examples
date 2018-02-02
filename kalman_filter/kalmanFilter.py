# as a matlab/scilab/R user I stubbornly use import *
from numpy import *
from matplotlib.pyplot import *

dt = 0.1 # sample time [s]
Tsim = 10 # simulation length [s]
N = (Tsim/dt + 1) # number of samples

t = linspace(0, Tsim, N)
x = zeros_like(t)

for i in linspace(1, N-1, N):
    x[i] = x[i-1] + absolute(random.randn())

#print(t)

#plot(t, x)
#show()


print(a)
