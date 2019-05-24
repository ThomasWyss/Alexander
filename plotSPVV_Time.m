function [ err ] = plotSPVV_Time( Plot )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    
    figure('Name',['SPVV_Fit ',Plot.Text.szFileName(1:end-4)],'Position',[1, 1, 1920,1080]); % Fig 4
    ax1=subplot(1,1,1);
    hold on;
    Plot.PreRotVR.SPV=medfilt1(Plot.PreRotVR.SPV,3);
    Plot.PreRotVL.SPV=medfilt1(Plot.PreRotVL.SPV,3);
    Plot.PostRotVR.SPV=medfilt1(Plot.PostRotVR.SPV,3);
    Plot.PostRotVL.SPV=medfilt1(Plot.PostRotVL.SPV,3);
    Plot.PostRotVR.SPV=medfilt1(Plot.PostRotVR.SPV,3);
    Plot.PostRotVL.SPV=medfilt1(Plot.PostRotVL.SPV,3);

    plot(ax1,Plot.PreRotVR.dTime,Plot.PreRotVR.SPV,'ro','linewidth', 1.2,'MarkerSize',7.0);
    plot(ax1,Plot.PreRotVL.dTime,Plot.PreRotVL.SPV,'bo','linewidth', 1.2,'MarkerSize',7.0);
    plot(ax1,Plot.PostRotVR.dTime,Plot.PostRotVR.SPV,'ro','linewidth', 1.2,'MarkerSize',7.0);
    plot(ax1,Plot.PostRotVL.dTime,Plot.PostRotVL.SPV,'bo','linewidth', 1.2,'MarkerSize',7.0);
    line(get(gca,'xlim'),[0,0],'Color',[0.0 0.0 0.0],'LineWidth',1.5);
    plot(ax1, Plot.headInertialTime,Plot.HeadMovVect/10,'color',[0.5 0.5 0.5],'linewidth', 1.2,'MarkerSize',7.0);
    %title([szFileName,'   ',fData.Examination, '   ', fData.Condition]);
    

    Func=@(b,x)(-b(1).*exp(-(x-Plot.startRotationTime)./b(2)));
    time=linspace(Plot.startRotationTime,Plot.stopRotationTime,200);
    
    % --- PreRotatoric Right Horizontal ---
    beta0 = [50 10]; % Anfangswerte für die Suche
    betaR = nlinfit(Plot.PreRotVR.dTime,Plot.PreRotVR.SPV,Func,beta0); % Parameter schätzen    
    plot(ax1,time,-betaR(1).*exp(-(time-Plot.startRotationTime)./betaR(2)),'r','linewidth', 1.2,'MarkerSize',7.0);
    tx1=text(Plot.startRotationTime+50.0,-30.0,sprintf('Fitted Function Y= -%2.1fX * exp( -x/%2.1f) ',betaR(1),betaR(2)));
    tx1.Color=[1.0 0 0];

    % --- PreRotatoric Left Horizontal ---
    beta0 = [50 10]; % Anfangswerte für die Suche
    betaL = nlinfit(Plot.PreRotVL.dTime,Plot.PreRotVL.SPV,Func,beta0); % Parameter schätzen    
    plot(ax1,time,-betaL(1).*exp(-(time-Plot.startRotationTime)./betaL(2)),'b','linewidth', 1.2,'MarkerSize',7.0);
    tx2=text(Plot.startRotationTime+50.0,-35.0,sprintf('Fitted Function Y= -%2.1fX * exp( -x/%2.1f) ',betaL(1),betaL(2)));
    tx2.Color=[0 0 1.0];
              
    % --- difference R L ---
    dDiff=-betaR(1).*exp(-(time-Plot.startRotationTime)./betaR(2))+...
        betaL(1).*exp(-(time-Plot.startRotationTime)./betaL(2));
    plot(ax1,time,dDiff,'c','linewidth', 1.2,'MarkerSize',7.0);

    Func=@(b,x)(b(1).*exp(-(x-Plot.stopRotationTime)./b(2)));
    time=linspace(Plot.stopRotationTime,Plot.headInertialTime(end),200);

    % --- PosRotatoric Right Horizontal ---
    beta0 = [50 10]; % Anfangswerte für die Suche
    betaR = nlinfit(Plot.PostRotVR.dTime,Plot.PostRotVR.SPV,Func,beta0); % Parameter schätzen    
    plot(ax1,time,betaR(1).*exp(-(time-Plot.stopRotationTime)./betaR(2)),'r','linewidth', 1.2,'MarkerSize',7.0);
    tx1=text(Plot.stopRotationTime+50.0,50.0,sprintf('Fitted Function Y= %2.1fX * exp( -x/%2.1f) ',betaR(1),betaR(2)));
    tx1.Color=[1.0 0 0];
        
    % --- PostRotatoric Left Horizontal ---
    beta0 = [50 10]; % Anfangswerte für die Suche
    betaL = nlinfit(Plot.PostRotVL.dTime,Plot.PostRotVL.SPV,Func,beta0); % Parameter schätzen    
    plot(ax1,time,betaL(1).*exp(-(time-Plot.stopRotationTime)./betaL(2)),'b','linewidth', 1.2,'MarkerSize',7.0);
    tx2=text(Plot.stopRotationTime+50.0,45.0,sprintf('Fitted Function Y= %2.1fX * exp( -x/%2.1f) ',betaL(1),betaL(2)));
    tx2.Color=[0 0 1.0];
                
    % --- difference R L ---
    dDiff=betaR(1).*exp(-(time-Plot.stopRotationTime)./betaR(2))-...
        betaL(1).*exp(-(time-Plot.stopRotationTime)./betaL(2));
    plot(ax1,time,dDiff,'c','linewidth', 1.2,'MarkerSize',7.0);

    title(['SPVV Exponential Fit ', Plot.Text.szFileName(1:end-4)]);
    ylabel('SPV [\circ/s]');
    xlabel('Time');
    legend('Right SPV V','Left SPV V');
%     xlim([108.8 110.4]);
    ylim([-70, 70]);
    grid on;
    % --- save into picture and figure ---
    szSaveName =['..\Data\Pictures\',Plot.Text.szFileName(1:end-4),'_SPVV_TimeFit.jpg'];%,'Nystagmus_PosData',szPicFile,'.jpg'];
    saveas(gcf,szSaveName);
    szSaveName =['..\Data\Figures\',Plot.Text.szFileName(1:end-4),'_SPVV_TimeFit.fig'];%,'Nystagmus_PosData',szPicFile,'.jpg'];
    saveas(gcf,szSaveName);

err=-777;
end

