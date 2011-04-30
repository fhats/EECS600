function X=vec2img(xx)

C=size(xx,2);
R=size(xx,1);
S=sqrt(C*R);
s=sqrt(R);

X = zeros (S,S);

for i = 0:S/s - 1
  for j = 0:S/s - 1
    X(i * s + 1:i * s + s,j * s + 1:j * s + s) = ...
	reshape(xx(:,1 + i * S/s + j),s,s);
  end
end
