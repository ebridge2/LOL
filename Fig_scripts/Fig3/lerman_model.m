function X=lerman_model(N0,N1,D,d,noise)

true_direction=orth(rand(D,d));
X=randn(N0,d)*true_direction';
X=[X;rand(N1,D)];
X=X+rand(size(X))*noise;
