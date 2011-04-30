function [ Ix, Iy, It ] = mge( M, hx, hy, ht )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    
    [Ix, Iy, It] = gradient(M, hx, hy, ht);
end

