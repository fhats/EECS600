function plotA(A)
% Plot basis vectors for 2x2 mixing matrix A.
    plot([0,A(1,1)], [0,A(2,1)]);
    axis equal
    hold on;
    plot([0,A(1,2)], [0,A(2,2)]);
    hold off;
    