function [ X ] = decode_basis( A, S )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    vec = [];
    for i=1:size(S,2),
        s = S(:,i);
        x = A * s;
        vec = horzcat(vec, x);
    end
    
    X = vec2img(vec);

end

