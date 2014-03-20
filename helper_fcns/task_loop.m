function loop = task_loop(task)
% this function implements a parloop for Ntrials iterations and outputs the
% results

loop = cell(1,task.Ntrials);
parfor k=1:task.Ntrials
    
    
    if mod(k,10)==0, display(['trial # ', num2str(k)]); end
    
    % prepare data
    [task1, X, Y, P] = get_task(task);
    Z = parse_data(X,Y,task1.ntrain,task1.ntest,task1.percent_unlabeled);
    
    tic % get delta and eigenvectors
    Phat = estimate_parameters(Z.Xtrain,Z.Ytrain,task1.Kmax);
    loop{k}.svdtime = toc;
    
    % center data
    Xtrain_centered = bsxfun(@minus,Z.Xtrain,Phat.mu);
    Xtest_centered = bsxfun(@minus,Z.Xtest,Phat.mu);
    
    % classify
    for i=1:task1.Nalgs
        if strcmp(task1.algs{i},'LDA')
            tic
            D = size(Xtrain_centered,1);
            if D<1000 % skip LDA if the # of dimensions is too large such that pinv takes forever!
                Yhat = LDA_train_and_predict(Xtrain_centered,Z.Ytrain,Xtest_centered);
            else
                Yhat = nan(size(Z.Ytest));
            end
            loop{k}.time(i,1)=toc;
            loop{k}.out(i,1) = get_task_stats(Yhat,Z.Ytest);              % get accuracy
        elseif strcmp(task1.algs{i},'PDA')
            for l=1:task1.Nks
                tic
                Yhat = PDA_train_and_predict(Xtrain_centered,Z.Ytrain,Xtest_centered,Phat.V(1:task1.ks(l),:));
                loop{k}.time(i,l)=toc+loop{k}.svdtime;
                loop{k}.out(i,l) = get_task_stats(Yhat,Z.Ytest);              % get accuracy
            end
            
        elseif strcmp(task1.algs{i},'RF')
            tic
            B = TreeBagger(100,Z.Xtrain',Z.Ytrain');
            [~, scores] = predict(B,Z.Xtest');
            Yhat=scores(:,1)<scores(:,2);
            loop{k}.time(i,1)=toc;
            loop{k}.out(i,1) = get_task_stats(Yhat,Z.Ytest);  
            % get accuracy
            for ii=1:B.NTrees
                loop{k}.NumParents=length(unique(B.Trees{ii}.Parent));
            end
        elseif strcmp(task1.algs{i},'LOL')
            for l=1:task1.Nks
                tic
                Yhat = LOL_train_and_predict(Xtrain_centered,Z.Ytrain,Xtest_centered,Phat.delta,Phat.V(1:task1.ks(l),:));
                loop{k}.time(i,l)=toc+loop{k}.svdtime;
                loop{k}.out(i,l) = get_task_stats(Yhat,Z.Ytest);              % get accuracy
            end
            
        elseif strcmp(task1.algs{i},'SLOL')
            for l=1:task1.Nks
                tic
                Yhat = LOL_train_and_predict(Xtrain_centered,Z.Ytrain,Xtest_centered,Phat.sdelta,Phat.V(1:task1.ks(l),:));
                loop{k}.time(i,l)=toc+loop{k}.svdtime;
                loop{k}.out(i,l) = get_task_stats(Yhat,Z.Ytest);              % get accuracy
            end
            
        elseif strcmp(task1.algs{i},'RLOL')
            for l=1:task1.Nks
                tic
                Yhat = LOL_train_and_predict(Xtrain_centered,Z.Ytrain,Xtest_centered,Phat.rdelta,Phat.rV(1:task1.ks(l),:));
                loop{k}.time(i,l)=toc+loop{k}.svdtime;
                loop{k}.out(i,l) = get_task_stats(Yhat,Z.Ytest);              % get accuracy
            end
            
        elseif strcmp(task1.algs{i},'QOL')
            for l=1:task1.Nks
                tic
                Yhat = QOL_train_and_predict(Xtrain_centered,Z.Ytrain,Xtest_centered,Phat.delta,task1.ks(l));
                loop{k}.time(i,l)=toc+loop{k}.svdtime;
                loop{k}.out(i,l) = get_task_stats(Yhat,Z.Ytest);              % get accuracy
            end
            
        elseif strcmp(task1.algs{i},'QOQ')
            for l=1:task1.Nks
                tic
                QDAhat = QOQ_train(Xtrain_centered, Z.Ytrain,Phat.delta,task1.ks(l));
                Yhat = QOQ_predict(Xtest_centered,QDAhat);
                loop{k}.time(i,l)=toc+loop{k}.svdtime;
                loop{k}.out(i,l) = get_task_stats(Yhat,Z.Ytest);              % get accuracy
            end
            
        elseif strcmp(task1.algs{i},'RDA')
            for l=1:task1.Nks
                tic
                Yhat = RDA_train_and_predict(Xtrain_centered,Z.Ytrain,Xtest_centered,task1.ks(l));
                loop{k}.time(i,l)=toc;
                loop{k}.out(i,l) = get_task_stats(Yhat,Z.Ytest);              % get accuracy
            end
            
        elseif strcmp(task1.algs{i},'DRDA')
            for l=1:task1.Nks
                tic
                Yhat = DRDA_train_and_predict(Xtrain_centered,Z.Ytrain,Xtest_centered,Phat.delta,task1.ks(l));
                loop{k}.time(i,l)=toc;
                loop{k}.out(i,l) = get_task_stats(Yhat,Z.Ytest);              % get accuracy
            end
            
            %         elseif strcmp(task1.algs{i},'knn')
            %
            %             d=bsxfun(@minus,Z.Xtrain,Z.Xtest).^2;
            %             [~,IX]=sort(d);
            %
            %             for l=1:tasks1.Nks
            %                 Yhat(i)=sum(Z.Ytrain(IX(1:l,:)))>k/2;
            %                 loop{k}.out(i,l) = get_task_stats(Yhat,Z.Ytest);              % get accuracy
            %             end
            
        elseif strcmp(task1.algs{i},'NaiveB')
            tic
            nb = NaiveBayes.fit(Z.Xtrain',Z.Ytrain);
            Yhat = predict(nb,Z.Xtest');
            loop{k}.time(i,1)=toc;
            loop{k}.out(i,1) = get_task_stats(Yhat,Z.Ytest);              % get accuracy
            
        elseif strcmp(task1.algs{i},'svm')
            tic
            SVMStruct = svmtrain(Z.Xtrain',Z.Ytrain);
            Yhat = svmclassify(SVMStruct,Z.Xtest');
            loop{k}.time(i,1)=toc;
            loop{k}.out(i,1) = get_task_stats(Yhat,Z.Ytest);              % get accuracy
        end
    end
    
    % chance
    pihat = sum(Z.Ytrain)/task1.ntrain;
    Yhatchance=pihat>0.5;
    loop{k}.Lchance=sum(Yhatchance*ones(size(Z.Ytest))~=Z.Ytest)/task1.ntest;
    
    % Bayes optimal under QDA model
    if task1.QDA_model
        yhats=nan(task1.ntest,1);
        lnp1=log(1-pihat);
        lnp0=log(pihat);
        
        a1= -0.5*logdet(P.Sig1)+lnp1;
        a0= -0.5*logdet(P.Sig0)+lnp0;
        
        d1 = bsxfun(@minus,P.mu1,Z.Xtest);
        d0 = bsxfun(@minus,P.mu0,Z.Xtest);
        
        for mm=1:task1.ntest
            l1=-0.5*d1(:,mm)'*(P.Sig1\d1(:,mm))-a1;
            l0=-0.5*d0(:,mm)'*(P.Sig0\d0(:,mm))-a0;
            yhats(mm)= l1 > l0;
        end
        loop{k}.Lbayes=sum(yhats~=Z.Ytest)/task1.ntest;
    end
end