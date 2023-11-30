
function [dev1,dev2,dev3,maxgoodness]=RMSFgoodnessdisp(u_all)

scale_time=0.5; %time between frames (seconds)

%%%%%%%%%%%%%%%%%
% calculating F %
%%%%%%%%%%%%%%%%%
trackLength = length(u_all);
step=125;
tc = floor(trackLength/step);
numseries=1;

exponents=zeros(tc,numseries);
goodness=zeros(tc,numseries);
ks=zeros(tc,numseries);
 
% clear title xlabel ylabel;
tc2=tc*step;
zz=1;

for time_max=step:step:tc2   % plot one graph every "step" data points
        
    umin=1;     
    nu=trackLength-1;
    du=1;
    u=u_all(umin:du:umin+nu);
   
    dim=size(u,1);
    l=zeros(dim,1);
  
    for j=2:dim
        
        l(j)=sqrt(  ( u(j)-u(j-1) ) * ( u(j)-u(j-1)) );
        
    end
    
    % calculates y, net displacement for each t
    
    y=zeros(dim,1);
            
    for j=1:dim
        
        y(j)=compute_y(l,j);
        
    end
    
    % root mean square fluctuation of the displacement
    
    F=zeros(dim,1);
    
    for j=1:dim
        
        F(j)=compute_F(y,j);
        
    end
   
    %%%%%%%%%%%%%
    % F fitting %
    %%%%%%%%%%%%%
     
    time=(1:dim)'.*scale_time*du;
    idx=find( time(1:time_max)>0 & F(1:time_max)>0 );
    [Rsq,slope,intercept]=rsquare (log10(time(idx)),log10(F(idx)));
    
    % alpha=slope;
    % v=time.^(alpha);
    % k=power(10,intercept/slope);
    % k=F(1);

    exponents(zz,1)=slope;
    goodness(zz,1)=Rsq;
    ks(zz,1)=power(10,intercept);
    junto(zz,:)=[slope Rsq time_max];  

    % Return only one row depending on R2 value (goodness of fit)
    % B=goodness>0.98;
    % res=junto(B,:);
    dev=junto(end,:);
    dev1=dev(:,1);
    dev2=dev(:,2);
    dev3=dev(:,3);
    % umin=umin+nu;

    % medias(zz)=mean(exponents(zz,:));
    % standard(zz)=std(exponents(zz,:));
    zz=zz+1;
end
maxgoodness = goodness(1);
end
