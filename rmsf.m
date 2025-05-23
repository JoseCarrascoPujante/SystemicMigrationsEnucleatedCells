
function [dev1,dev2,dev3,tc2,goodness]=rmsf(u_all, rmsfhandle)

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
    umin=1;
    
    for time_max=step:step:tc2   % plot one graph every "step" data points
             
        nu=trackLength; 
        du=1;
        u=u_all(umin:du:nu);
       
        dim=size(u,1);
        l=zeros(dim,1);
      
        for j=2:dim
            
            l(j)=sqrt(  ( u(j)-u(j-1) ) * ( u(j)-u(j-1)) );
            
        end
        
        % calculates y, net displacement for each t
        
        y=zeros(dim,1);
                
        for j=1:dim
            
            y(j)=enu.compute_y(l,j);
            
        end
        
        % root mean square fluctuation of the displacement
        
        F=zeros(dim,1);
        
        for j=1:dim
            
            F(j)=enu.compute_F(y,j);
            
        end
       
        %%%%%%%%%%%%%
        % F fitting %
        %%%%%%%%%%%%%
         
        time=(1:dim)'.*scale_time*du;
        idx=find( time(1:time_max)>0 & F(1:time_max)>0 );
        [Rsq,slope,intercept]=enu.rsquare(log10(time(idx)),log10(F(idx)));
        
        % alpha=slope;
        % v=time.^(alpha);
        % k=power(10,intercept/slope);
        k=F(1);
    
        exponents(zz,1)=slope;
        goodness(zz,1)=Rsq;
        ks(zz,1)=power(10,intercept);
        junto(zz,:)=[slope Rsq time_max];  
    
        % Return only one row depending on R2 value (goodness of fit)
        B=goodness>0.98;
        res=junto(B,:);
        dev=res(end,:);
        dev1=dev(:,1);
        dev2=dev(:,2);
        dev3=dev(:,3); 
        % umin=umin+nu;
        % medias(zz)=mean(exponents(zz,:));
        % standard(zz)=std(exponents(zz,:));
        zz=zz+1;
    
        %%%%%%%%%%%%
        % Plotting %
        %%%%%%%%%%%%
    
        % loglog plot of rmsf F versus l step non-shuffled coordinates
        if time_max == tc2 && isempty(rmsfhandle) == 0
            max_corr = res(end,3); % Use max tc2 when R2>0.99   
            hold(rmsfhandle, 'on')
            % if strcmp(type,'original')
            loglog(time(1:max_corr), F(1:max_corr), 'ro', 'MarkerSize', 2,'LineWidth', .3);
            rmsfhandle.FontSize = 6.5;
            % elseif strcmp(type,'shuffled')
                % loglog(time(1:max_corr), F(1:max_corr), 'bo', 'MarkerSize', 2);
            % end
            % xlabel('Log({\itl}(s))',"FontSize",8);
            % ylabel('Log(F({\itl}))',"FontSize",8);
            
            % Plot regression fit line for the original data
            vmax=time.^(res(end,1));
            loglog(time(1:max_corr),(k/vmax(1))*vmax(1:max_corr),'k--',...
                'LineWidth',.5);
            text(time(15),(k/vmax(1))*vmax(150),strcat('\alpha=',...
                num2str(round(res(end,1),3))),"HorizontalAlignment","left", ...
                "FontSize",8)

            % Plot alpha=0.5 line with the original data
            v2 = time.^(.5);
            loglog(time(1:max_corr),(k/v2(1))*v2(1:max_corr),'k--','LineWidth',.5);
            text(time(15),(k/v2(1))*v2(4),'\alpha=0.5, uncorrelated', ...
                "HorizontalAlignment","left","FontSize",8)
            set(rmsfhandle,'xscale','log')
            set(rmsfhandle,'yscale','log')
            axis padded
        end
    end
end
