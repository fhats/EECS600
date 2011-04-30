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
                A = zeros(2, r*r)';
                B = zeros(1, r*r)';
                for x=x0:x1,
                    for y=y0:y1,
                       A(x*y,1) = Ix(x,y,t);
                       A(x*y,2) = Iy(x,y,t);
                       B(x*y) = It(x,y,t);
                    end
                end
                A
                B
                x = (pinv(A) * B)';
                U(i,j,t) = x(1);
                V(i,j,t) = x(2);
            end
        end
    end

end

