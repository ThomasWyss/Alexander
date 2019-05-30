function [ outPlot ] = plotSPVH_ExpFit( Plot )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    
    figure('Name',['SPVH_ExpFit ', Plot.Text.szPatient,' ',Plot.Text.szTest],'Position',[1, 1, 1920,1080]); % Fig 4
    ax1=subplot(1,1,1);
    hold on;
    Local.PreRotHR.SPV=medfilt1(Plot.PreRotHR.SPV,3);
    Local.PreRotHL.SPV=medfilt1(Plot.PreRotHL.SPV,3);
    Local.PostRotHR.SPV=medfilt1(Plot.PostRotHR.SPV,3);
    Local.PostRotHL.SPV=medfilt1(Plot.PostRotHL.SPV,3);
    Local.PostRotHR.SPV=medfilt1(Plot.PostRotHR.SPV,3);
    Local.PostRotHL.SPV=medfilt1(Plot.PostRotHL.SPV,3);

    line(get(gca,'xlim'),[0,0],'Color',[0.0 0.0 0.0],'LineWidth',1.5);
    plot(ax1, Plot.headInertialTime,Plot.HeadMovVect/10,'color',[0.5 0.5 0.5],'linewidth', 1.2,'MarkerSize',7.0);   
    ylim([-70, 70]);
    grid on;

    tx1=text(Plot.startRotationTime-12,15.0,[ sprintf('Start %2.1f',Plot.startRotationTime), '\rightarrow ']);
    tx1.Color='r';
    tx1=text(Plot.stopRotationTime,15.0,['\leftarrow ', sprintf('Stopp %2.1f',Plot.stopRotationTime)]);
    tx1.Color='r';
    tx1=text(Plot.endRotationTime,15.0,['\leftarrow ', sprintf('End Data %2.1f',Plot.endRotationTime)]);
    tx1.Color='r';

    plot(ax1,Plot.PreRotHR.dTime,Local.PreRotHR.SPV,'ro','linewidth', 1.2,'MarkerSize',7.0);
    plot(ax1,Plot.PreRotHL.dTime,Local.PreRotHL.SPV,'bo','linewidth', 1.2,'MarkerSize',7.0);
    plot(ax1,Plot.PostRotHR.dTime,Local.PostRotHR.SPV,'ro','linewidth', 1.2,'MarkerSize',7.0);
    plot(ax1,Plot.PostRotHL.dTime,Local.PostRotHL.SPV,'bo','linewidth', 1.2,'MarkerSize',7.0);

    Func=@(b,x)(-b(1).*exp(-(x-Plot.startRotationTime)./b(2)));
    time=linspace(Plot.startRotationTime,Plot.endRotationTime,200);
    
    % --- PreRotatoric Right Horizontal ---
    beta0 = [50 10]; % Anfangswerte f�r die Suche
    betaR = nlinfit(Plot.PreRotHR.dTime,Local.PreRotHR.SPV,Func,beta0); % Parameter sch�tzen    
    plot(ax1,time,-betaR(1).*exp(-(time-Plot.startRotationTime)./betaR(2)),'r','linewidth', 1.2,'MarkerSize',7.0);
    tx1=text(Plot.startRotationTime+30.0,-30.0,sprintf('Fitted Function YR= -%2.1f * exp( -T/%2.1f) ',betaR(1),betaR(2)));
    tx1.Color=[1.0 0 0];
    Plot.PreRotHR.betaR=betaR;
    
    % --- PreRotatoric Left Horizontal ---
    beta0 = [50 10]; % Anfangswerte f�r die Suche
    betaL = nlinfit(Plot.PreRotHL.dTime,Local.PreRotHL.SPV,Func,beta0); % Parameter sch�tzen    
    plot(ax1,time,-betaL(1).*exp(-(time-Plot.startRotationTime)./betaL(2)),'b','linewidth', 1.2,'MarkerSize',7.0);
    tx2=text(Plot.startRotationTime+30.0,-35.0,sprintf('Fitted Function Y= -%2.1f * exp( -t/%2.1f) ',betaL(1),betaL(2)));
    tx2.Color=[0 0 1.0];
    Plot.PreRotHL.betaL=betaL;
              
    % --- difference R L ---
    dDiff=-betaR(1).*exp(-(time-Plot.startRotationTime)./betaR(2))+...
        betaL(1).*exp(-(time-Plot.startRotationTime)./betaL(2));
    plot(ax1,time,dDiff,'c','linewidth', 1.2,'MarkerSize',7.0);
    tx2=text(Plot.startRotationTime+30.0,-40.0,sprintf('Fitted Function Y= YR-YL) '));
    tx2.Color="c";
    
    Func=@(b,x)(b(1).*exp(-(x-Plot.stopRotationTime)./b(2)));
    time=linspace(Plot.stopRotationTime,Plot.headInertialTime(end),200);
    
    % --- PostRotatoric Right Horizontal ---
    beta0 = [50 10]; % Anfangswerte f�r die Suche
    betaR = nlinfit(Plot.PostRotHR.dTime,Local.PostRotHR.SPV,Func,beta0); % Parameter sch�tzen    
    plot(ax1,time,betaR(1).*exp(-(time-Plot.stopRotationTime)./betaR(2)),'r','linewidth', 1.2,'MarkerSize',7.0);
    tx1=text(Plot.stopRotationTime+30.0,50.0,sprintf('Fitted Function YR= %2.1f * exp( -t/%2.1f) ',betaR(1),betaR(2)));
    tx1.Color=[1.0 0 0];
    Plot.PostRotHR.betaR=betaR;
    
    % --- PostRotatoric Left Horizontal ---
    beta0 = [50 10]; % Anfangswerte f�r die Suche
    betaL = nlinfit(Plot.PostRotHL.dTime,Local.PostRotHL.SPV,Func,beta0); % Parameter sch�tzen    
    plot(ax1,time,betaL(1).*exp(-(time-Plot.stopRotationTime)./betaL(2)),'b','linewidth', 1.2,'MarkerSize',7.0);
    tx2=text(Plot.stopRotationTime+30.0,45.0,sprintf('Fitted Function YL= %2.1f * exp( -t/%2.1f) ',betaL(1),betaL(2)));
    tx2.Color=[0 0 1.0];
    Plot.PostRotHL.betaL=betaL;
    
    % --- difference R L ---
    dDiff=betaR(1).*exp(-(time-Plot.stopRotationTime)./betaR(2))-...
          betaL(1).*exp(-(time-Plot.stopRotationTime)./betaL(2));
    plot(ax1,time,dDiff,'c','linewidth', 1.2,'MarkerSize',7.0);
    tx2=text(Plot.stopRotationTime+30.0,40.0,sprintf('Fitted Function Y= YR-YL) '));
    tx2.Color='C';
    
    title(['SPVH Exponential Fit ', Plot.Text.szPatient,' ',Plot.Text.szTest]);
    ylabel('SPV [\circ/s]');
    xlabel('Time');
    legend('Right SPV H','Left SPV H');
%     xlim([108.8 110.4]);
    ylim([-70, 70]);
    grid on;
    % --- save into picture and figure ---
    szSaveName =['..\Data\Pictures\',Plot.Text.szPatient,'_',Plot.Text.szTest,'_SPVH_TimeFit.jpg'];%,'Nystagmus_PosData',szPicFile,'.jpg'];
    saveas(gcf,szSaveName);
    szSaveName =['..\Data\Figures\',Plot.Text.szPatient,'_',Plot.Text.szTest,'_SPVH_TimeFit.fig'];%,'Nystagmus_PosData',szPicFile,'.jpg'];
    saveas(gcf,szSaveName);

	outPlot=Plot;
end
