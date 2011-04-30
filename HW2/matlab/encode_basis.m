function [ S ] = encode_basis( i_A, X )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    S = [];
    A = pinv(i_A);
    img_vec = img2vec(X);
    for i=1:size(img_vec,2),
        v = img_vec(:,i);
        s = A*v;
        S = horzcat(S, s);
    end
end

