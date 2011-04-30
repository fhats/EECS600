function xx=img2vec(X)

N=size(X,3);
C=size(X,2);
R=size(X,1);

L2 = floor(C / 8);
L1 = floor(R / 8);

xx=zeros(64,L2*L1*N);

for k=0:N-1
  for i=0:L1-1;
    for j=0:L2-1;
      xx(:,1 + k * L1 * L2 + i * L1 + j) = ...
	  reshape(X(i * 8 + 1: i * 8 + 8, j * 8 + 1:j * 8 + 8,k+1),64,1);
    end
  end
end