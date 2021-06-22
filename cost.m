clear all
clc
close all
S=[100 125 80 110];
W=[3 2 3 2];
set=10;
C_c=[162 110 202 150];
C_p=[36.75 23.75 46.75 33.75];
ti=[0 0 0 0];%The last time each components get maintained
St=0;%The current time step, St+1 is the first time step
time=1; %one time step length is 1 month/time
T=121*time; %consider 80 month
Wh=240*time; %the whole life time of the wind turbine

% d=1;
d=zeros(1300,2);
ds=zeros(1200,2);
for i=1:100
    d(12*(i-1)+1,2)=15;
    d(12*(i-1)+2,2)=13;
    d(12*(i-1)+3,2)=11;
    d(12*(i-1)+4,2)=9;
    d(12*(i-1)+5,2)=7;
    d(12*(i-1)+6,2)=5;
    d(12*(i-1)+7,2)=5;
    d(12*(i-1)+8,2)=7;
    d(12*(i-1)+9,2)=9;
    d(12*(i-1)+10,2)=11;
    d(12*(i-1)+11,2)=13;
    d(12*(i-1)+12,2)=15;
end
for i=1:1200
            d(i,2)=d(i,2)/2;
     d(i,2)=10;
end
lambda=3;
K=10;
L=500000;%how many times we generate
L2=20;
tic
LL=floor(L/L2);
    F=zeros(L,4);
    for i=1:4
        F(:,i)=time*wblrnd(S(i),W(i),[1 L]);
    end
% load Fsmall.dat
% F=Fsmall;
o=zeros(10,4);
n=zeros(10,4);
cc=1; %how many times we test it to see do we have enough scenarios or not.
for c=1:cc
    b=zeros(T-St,4);

    M=zeros(T-St,4);
    for i=1:4
        for t=1:T-St
            for k=1:floor(L/K)
                if F(k,i)>St-ti(i)
                    b(t,i)=b(t,i)+1;
                    if F(k,i)<t+St-ti(i)
                        M(t,i)=M(t,i)+(C_c(i)+d(t,2))-(F(k,i)/(t+St-ti(i)))^lambda*(C_p(i)+d(t,2));
                        %M is the a in the paper
                    end
                    for l=2:K
                        a=0;
                        for m=1:l
                            a=a+F(K*(k-1)+m,i);
                        end
                        if a<t+St-ti(i)
                            M(t,i)=M(t,i)+(C_c(i)+d(t,2))-(F(k,i)/(t+St-ti(i)))^lambda*(C_p(i)+d(t,2));
%                             EM(t,i)=EM(t,i)+(C_c(i)+d(t,2))-(F(k,i)/(t+St-ti(i)))^lambda*(C_p(i)+d(t,2));
                        end
                    end
                end
            end
        end
    end
    C_t=zeros(T-St,4);
    for i=1:4
        for j=1:T-St
            if b(j,i)==0
                C_t(j,i)=C_p(i);
            else
            C_t(j,i)=C_p(i)+M(j,i)/b(j,i);
            end
        end
    end
    H=zeros(T-St,4);%i.e. v in the paper
    
    for Te=1:T-St
        for i=1:4
            for j=1:L2
                G=zeros(LL,1);
                g=zeros(LL,1);
                for k=1:LL
                    for l=1:j
                        g(k)=g(k)+F(l+(k-1)*j,i);
                    end
                    if F(1+(k-1)*j,i)>St-ti(i)
                        for l=1:j
                            G(k)=G(k)+F(l+(k-1)*j,i);
                        end
                    end
                end
                G(G==0)=[];
                H(Te,i)=H(Te,i)-numel(g(g<Wh-Te-St+1))/length(g);
                if (~isempty(G))
                H(Te,i)=H(Te,i)+numel(G(G<Wh-ti(i)+1))/length(G);
                end
            end
        end
    end
    
    D=zeros(T-St,5);
    cc=zeros(T-St,5);
    dd=1:T-St;
    dd=dd';
    D(:,1)=dd;
    cc(:,1)=dd;
    for Te=1:T-St
        for i=2:5
            D(Te,i)=((C_c(i-1))*H(Te,i-1)-C_t(Te,i-1))/Te;
            cc(Te,i)=C_t(Te,i-1)/Te;
        end
    end
%     [o(c,:),n(c,:)]=min(cc(:,2:5));
%     c
end
% save D12101.dat -ascii D
% save w5.dat -ascii cc
toc

    for Te=1:T-St
        for i=2:5
%E(Te,i)=((C_c(i-1))*H(Te,i-1))/Te;
E(Te,i)=((C_c(i-1)+1)*H(Te,i-1))/Te;
B(Te,i)=C_t(Te,i-1)/Te;
        end
    end
%     figure (1)
plot(E(20:T,4),'b') 
xlabel('time (month)')
ylabel('cost per month (k $)')
hold on
plot(B(20:T,4),'r')
title('Preventive versus corrective maintenance for a gearbox')
legend('CM','PM')
set(gca,'XTicklabel',20:10:90) 
hold off
figure (2)
plot(B(20:T,4),'r')
 xlabel('time (month)')
 ylabel('cost per month (k $)')
 title('PM cost of Gearbox')
 set(gca,'XTicklabel',20:10:90) 




