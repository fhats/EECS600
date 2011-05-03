function [ U,V ] = optflow( M, hx, hy, ht, r )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    [Ix, Iy, It] = mge(M, hx, hy, ht);
    U = [];
    V = [];
    for i=1:size(M,1),
        for j=1:size(M,2),
            for t=1:size(M,3),
                x0 = max(1, round(i - (r/2)));
                y0 = max(1, round(j - (r/2)));
                x1 = min(size(M,1), round(i + (r/2)));
                y1 = min(size(M,2), round(j + (r/2)));
                
                ix_seg = Ix(x0:x1, y0:y1, t);
                iy_seg = Iy(x0:x1, y0:y1, t);
                it_seg = It(x0:x1, y0:y1, t);
                
                size_ix = numel(ix_seg);
                size_iy = numel(iy_seg);
                size_it = numel(it_seg);
                
                A(1:size_ix, 1) = reshape(ix_seg', size_ix, 1);
                A(1:size_iy, 2) = reshape(iy_seg', size_iy, 1);
                B(1:size_it, 1) = reshape(it_seg', size_it, 1);
                
                x = (pinv(A) * B);

                U(i,j,t) = x(1);
                V(i,j,t) = x(2);
            end
        end
    end

end

