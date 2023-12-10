
function [Alpha1,D,F_n,z1,z2]=DFA_main2(DATA, input_type, axeshandle)
    % DATA should be a time series of length(DATA) greater than 2000,and of column vector.
    %A is the alpha in the paper
    %D is the dimension of the time series
    %n can be changed to your interest
    cc=[158 251 398 631 1000 1585 2512 3981];% 6310 10000 15849 25119 39811 63096 100000]; % tamaño óptimo es 100:~(length(DATA)/10)
    %cc=[100 126 158 200 251 316 398 501 631 794 1000 1259 1585 1995 2512 3162 3981]; % 100^n donde n aumenta de 0.05 en 0.05 en vez de 0.1 como arriba
    %%elegimos n para que haga ventanas desde el 2 hasta el 4 en escala
    %%logarítmica, separados de 0.2 en 0.2 (redondeados para ser un tamaño de
    %%ventana entero)
    n=cc(cc<length(DATA));
    N1=length(n); % use only n values smaller than track length
    F_n=zeros(N1,1);
    for i=1:N1
     F_n(i)=enu.DFA2(DATA,n(i),1);
    end
    
    n=n';
    A=polyfit(log10(n(1:end)),log10(F_n(1:end)),1);
    B=polyval(A,log10(n(1:end)));
    
    [z1,z2]=enu.rsquare(log10(F_n(1:end)),B);
    Alpha1=A(1);
    D=3-A(1);

    if ~isempty(input_type) & ~isempty(axeshandle)
        hold(axeshandle, 'on')
        
        if contains(input_type, 'Original')
            scatter(axeshandle,log10(n),log10(F_n), 'filled', 'ro');
        elseif contains(input_type, 'Shuffled')
            scatter(axeshandle,log10(n),log10(F_n), 'filled', 'bo');
        end
        
        hold on
        xlabel('log10(n)','FontSize',10)
        ylabel('log10(F(n))','FontSize',10)
        
        if strcmp(input_type, 'Original_DFA_')
            plot(axeshandle,log10(n(1:end)),A(1)*log10(n(1:end))+A(2), 'Color', [1 0 0], 'LineStyle','-')
        elseif strcmp(input_type, 'Shuffled_DFA_')
            plot(axeshandle,log10(n(1:end)),A(1)*log10(n(1:end))+A(2), 'Color', [0 0 1], 'LineStyle','-')
        end
    end
end