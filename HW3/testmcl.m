hold on
[Ix, Iy, It] = mge(M,1,1,1);

for x=1:size(M,1),
    for y=1:size(M,2),
        for t=1:size(M,3),
            plotmcl(Ix,Iy,It,x,y,t);
        end
    end
end

