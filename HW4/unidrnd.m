function r = unidrnd(n,mm,nn)
%UNIDRND Random matrices from the discrete uniform distribution.
%   R = UNIDRND(N) returns a matrix of random numbers chosen 
%   uniformly from the set {1, 2, 3, ... ,N}.
%
%   The size of R is the size of N. Alternatively, 
%   R = UNIDRND(N,MM,NN) returns an MM by NN matrix. 

    r = ceil(n .* rand(mm,nn));
