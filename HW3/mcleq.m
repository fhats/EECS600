function ret = mcleq( Ix, Iy, It, x, y, t, u)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    ret = 0;
    ret = (-(Ix(x,y,t)*u) - It(x,y,t))/Iy(x,y,t);
end

