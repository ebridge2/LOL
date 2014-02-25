function Phat = LDA_train(X,Y)
% learns all the parameters necessary for LDA
% note that this function supports semi-supervised learning via encoding
% NaN's into Y
% 
% INPUT:
%   X in R^{D x n}: predictor matrix
%   Y in {0,1,NaN}^n: predictee matrix
% 
% OUTPUT: Phat, a structure of parameters 

n0=sum(Y==0);
n1=sum(Y==1);
n=length(Y);
nu=n-n0-n1;

X0 = X(:,Y==0);
X1 = X(:,Y==1);

% unlabled X's, if they exist
Ynan=isnan(Y);
if any(Ynan)
    Xu = X(:,Ynan);
else
    Xu=0;
end

Phat.pi0 = n0/n;
Phat.pi1 = n1/n;
Phat.lnpi0 = log(n0/n);
Phat.lnpi1 = log(n1/n);

Phat.mu0 = mean(X0,2);
Phat.mu1 = mean(X1,2);
Phat.Sigma = (n0*cov(X0') +  n1*cov(X1') + nu*cov(Xu'))/n;

Phat.mu = (Phat.mu0+Phat.mu1)/2;
Phat.del = (Phat.mu0-Phat.mu1);
Phat.InvSig = pinv(Phat.Sigma);
Phat.thresh = (Phat.lnpi0-Phat.lnpi1)/2;