function [ output_args ] = plotmcl( Ix, Iy, It, x, y, t )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    u = -5:.1:5;
    v = mcleq(Ix,Iy,It,x,y,t,u);
    plot(u,v);
end

