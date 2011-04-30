function [ A, S ] = bss( X )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    A = eye(size(X,1));
    eps = 0.0002;
    block_size = 1000;
    iterations = 3000;
    
    for i=1:iterations,
       
        rand_samples = X(:, unidrnd(size(X,2), 1, block_size));
        
        S = inv(A) * rand_samples;
        
        del_A = (-A * (-sign(S)) * S') - (size(X,1) * A);
        
        A = A + (eps * del_A);
        
        if mod(i,50) == 0
            figure(1);
            plot(i, loglike(A, S), '+');
            hold on;
            drawnow;
        end
        
        if mod(i, 1000) == 0
            eps = eps / 2;
        end
        
    end
    
    S = inv(A) * X;
    
    figure(2);
    plotA(A);
    
end

