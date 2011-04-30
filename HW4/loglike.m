function [ likelihood ] = loglike( A,S )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    
    p_s = sum(-abs(S),2); %no log included because S follows a laplacian distribution
    [V, D] = eig(A);
    det_A = log(abs(prod(diag(D))));
    p_x = p_s - det_A;
    
    likelihood = sum(p_x);

end

