clear all;
load sonar.mat;
B=A;

cla=1;
A=B(1:end,2:end);Max=max(max(A));
Min=min(min(A));
A=2*(A-Min)./(Max-Min)-1;
d=(B(1:end,1)==cla)*2-1;

ker='linear'
k=10;output=1;

[sm sn]=size(A);
accuIter = 0;

cpu_time = 0;
indx = [0:k];
indx = floor(sm*indx/k);    %last row numbers for all 'segments'
% split trainining set from test set

trainCorr=0;
testCorr=0;

a=11;%input('the state=');
rand('state',a);
r=randperm(size(d,1));
d=d(r,:);
A=A(r,:); 

for i = 1:k
Ctest = []; dtest = [];Ctrain = []; dtrain = [];

Ctest = A((indx(i)+1:indx(i+1)),:);
dtest = d(indx(i)+1:indx(i+1));
Ctrain = A(1:indx(i),:);
Ctrain = [Ctrain;A(indx(i+1)+1:sm,:)];
dtrain = [d(1:indx(i));d(indx(i+1)+1:sm,:)];

r=find(dtrain>0);
r1=setdiff(1:length(Ctrain(:,1)),r);
Y1=dtrain(r,:);
Y2=dtrain(r1,:);
cc=Ctrain(r,:);
dd=Ctrain(r1,:);

Result=hibiscus(dtrain,Ctrain,k);
C1=Result.Best_C1;

% GEPSVM classifier
tic
[w1,w2,bias1,bias2]=GEPSVM_svc(cc,dd,C1);
thistoc(i,1)=toc;

[err ]= svcerror(w1,w2,bias1,bias2,Ctest,dtest);
tmpTestCorr(i,1)=1-err/length(Ctest(:,1));

[err ]= svcerror(w1,w2,bias1,bias2,Ctrain,dtrain);
tmpTrainCorr(i,1)=1-err/length(Ctrain(:,1));

 if output==1
fprintf(1,'________________________________________________\n');
fprintf(1,'Fold %d\n',i);
fprintf(1,'Training set correctness: %3.2f%%\n',tmpTrainCorr(i,1)*100);
fprintf(1,'Testing set correctness: %3.2f%%\n',tmpTestCorr(i,1)*100);
fprintf(1,'Elapse time: %10.4f\n',thistoc(i,1));
 end

end % end of for (looping through test sets)

     trainCorr = sum(tmpTrainCorr*100)/k;
     testCorr = sum(tmpTestCorr*100)/k;
     cpu_time=sum(thistoc)/k;

if output == 1
fprintf(1,'==============================================');
fprintf(1,'\nTraining set correctness: %3.2f%%',trainCorr);
fprintf(1,'\nTesting set correctness: %3.2f%%',testCorr);
fprintf(1,'\nAverage cpu_time: %10.4f\n',cpu_time);
end

testcorrstd=std(100*tmpTestCorr,1)
clear;