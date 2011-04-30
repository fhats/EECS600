function [px,py,pt] = mmpixelcoords(nr,nc,nt,fps)
    
ar = nc/nr;
if nargout == 3 && nargin == 4
    [px,py,pt] = meshgrid(-ar:2*ar/(nc-1):ar, 1:-2/(nr-1):-1, (0:nt-1)/fps);
else
    [px,py] = meshgrid(-ar:2*ar/(nc-1):ar, 1:-2/(nr-1):-1);
end