function [lx,ly,lt] = mmlatticecoords(nr,nc,nt,fps)

ar = nc/nr;

% There is one more lattice point for each x and y dimension.
% Also, assume that the pixel square is centered on the point used to
% calculate the motion.

h = 1/(nr-1);

if nargout == 3 && nargin == 4
    [lx,ly,lt] = meshgrid(-ar-h : 2*ar/(nc-1) : ar+h, ...
        1+h : -2/(nr-1) : -1-h, (0:nt-1)/fps);
else
    [lx,ly] = meshgrid(-ar-h : 2*ar/(nc-1) : ar+h, 1+h : -2/(nr-1) : -1-h);
end


    