function [ outPlot ] = plotSPVH_ExpFitTime( Plot )
% ########################################################################% 
% ## Calculate and plot exp functions of SPV
% ########################################################################%
% ## aktuell muss diese subroutine vor subroutinen ausgef�hrt werden
% ## welche die parameter der exponential funktion ben�tigen
% ########################################################################%
% ##        C A U T I O N
% ##        PreRotHR.SPV is goinf to be changed in this sub!!
% ##        PreRotHL.SPV is goinf to be changed in this sub!!
% ##        PoszRotHR.SPV is goinf to be changed in this sub!!
% ##        PostRotHL.SPV is goinf to be changed in this sub!!
% #########################################################################
    
    figure('Name',['SPVH_ExpFit ', Plot.Text.szPatient,' ',Plot.Text.szSession,' ',Plot.Text.szTest],'Position',[1, 1, 1920,1080]); % Fig 4
    ax1=subplot(2,1,1);
    hold on;
    % --- median filter to suppress outliers ---
    Local.PreRotHR.SPV=medfilt1(Plot.PreRotHR.SPV,3);
    Local.PreRotHL.SPV=medfilt1(Plot.PreRotHL.SPV,3);
    Local.PostRotHR.SPV=medfilt1(Plot.PostRotHR.SPV,3);
    Local.PostRotHL.SPV=medfilt1(Plot.PostRotHL.SPV,3);
    % --- do a second median filtering on PostRot Data ---
    Local.PostRotHR.SPV=medfilt1(Plot.PostRotHR.SPV,3);
    Local.PostRotHL.SPV=medfilt1(Plot.PostRotHL.SPV,3);

    title(['SPVH Nonlinear Exponential Fit ', Plot.Text.szPatient,' ',Plot.Text.szSession,' ',Plot.Text.szTest]);
    ylabel('SPV [\circ/s]');

    % --- chair rotation speed ---
    line(get(gca,'xlim'),[0,0],'Color',[0.0 0.0 0.0],'LineWidth',1.5);
    plot(ax1, Plot.headInertialTime,Plot.HeadMovVect/10,'color',[0.5 0.5 0.5],'linewidth', 1.2,'MarkerSize',7.0);   
    ylim([-80, 80]);
    grid on;

    % --- mark the rotation curve (start stop +end of data ---
    tx=text(Plot.startRotationTime-12,15.0,[ sprintf('Start %2.1f',Plot.startRotationTime), '\rightarrow ']);
    tx.Color='r';
    tx=text(Plot.stopRotationTime,15.0,['\leftarrow ', sprintf('Stopp %2.1f',Plot.stopRotationTime)]);
    tx.Color='r';
    tx=text(Plot.endRotationTime,15.0,['\leftarrow ', sprintf('End Data %2.1f',Plot.endRotationTime)]);
    tx.Color='r';

    % --- plot pre and post rotatoric SPV data ---
    plot(ax1,Plot.PreRotHR.dTime,Local.PreRotHR.SPV,'ro','linewidth', 1.2,'MarkerSize',7.0);
    plot(ax1,Plot.PreRotHL.dTime,Local.PreRotHL.SPV,'bo','linewidth', 1.2,'MarkerSize',7.0);
    plot(ax1,Plot.PostRotHR.dTime,Local.PostRotHR.SPV,'ro','linewidth', 1.2,'MarkerSize',7.0);
    plot(ax1,Plot.PostRotHL.dTime,Local.PostRotHL.SPV,'bo','linewidth', 1.2,'MarkerSize',7.0);

    % --- prepare fuction for nonlinear fitting pre rotation---
    Func=@(b,x)(b(1).*exp(-(x-Plot.startRotationTime)./b(2)));
    timePre=linspace(Plot.startRotationTime,Plot.stopRotationTime,200);
    
    % --- PreRotatoric Right Horizontal ---
    beta0 = [50 10]; % Anfangswerte f�r die Suche
    betaR = nlinfit(Plot.PreRotHR.dTime,Local.PreRotHR.SPV,Func,beta0); % Parameter sch�tzen    
    tx1=text(Plot.startRotationTime+30.0,-30.0,sprintf('Fitted Function YR= %2.1f * exp( -t/%2.1f) ',betaR(1),betaR(2)));
    tx1.Color=[1.0 0 0];
    plot(ax1,timePre,betaR(1).*exp(-(timePre-Plot.startRotationTime)./betaR(2)),'r','linewidth', 1.2,'MarkerSize',7.0);
    Plot.PreRotHR.betaR=betaR;
    
    % --- PreRotatoric Left Horizontal ---
    beta0 = [50 10]; % Anfangswerte f�r die Suche
    betaL = nlinfit(Plot.PreRotHL.dTime,Local.PreRotHL.SPV,Func,beta0); % Parameter sch�tzen    
    tx2=text(Plot.startRotationTime+30.0,-40.0,sprintf('Fitted Function YL= %2.1f * exp( -t/%2.1f) ',betaL(1),betaL(2)));
    plot(ax1,timePre,betaL(1).*exp(-(timePre-Plot.startRotationTime)./betaL(2)),'b','linewidth', 1.2,'MarkerSize',7.0);
    tx2.Color=[0 0 1.0];
    Plot.PreRotHL.betaL=betaL;
              
    % --- difference R L pre rotatoric---
    dDiffPre=betaR(1).*exp(-(timePre-Plot.startRotationTime)./betaR(2))-...
        betaL(1).*exp(-(timePre-Plot.startRotationTime)./betaL(2));
    plot(ax1,timePre,dDiffPre,'c','linewidth', 1.2,'MarkerSize',7.0);
    
    % --- average SPV pre rot ---
    dAvgPre=(betaR(1).*exp(-(timePre-Plot.startRotationTime)./betaR(2))+...
          betaL(1).*exp(-(timePre-Plot.startRotationTime)./betaL(2)))/2;
    plot(ax1,timePre,dAvgPre,'m','linewidth', 1.2,'MarkerSize',7.0);

    % --- prepare fuction for nonlinear fitting post rotation ---
    Func=@(b,x)(b(1).*exp(-(x-Plot.stopRotationTime)./b(2)));
    timePost=linspace(Plot.stopRotationTime,Plot.headInertialTime(end),200);
    
    % --- PostRotatoric Right Horizontal ---
    beta0 = [-50 10]; % Anfangswerte f�r die Suche
    betaR = nlinfit(Plot.PostRotHR.dTime,Local.PostRotHR.SPV,Func,beta0); % Parameter sch�tzen    
    plot(ax1,timePost,betaR(1).*exp(-(timePost-Plot.stopRotationTime)./betaR(2)),'r','linewidth', 1.2,'MarkerSize',7.0);
    tx1=text(Plot.stopRotationTime+30.0,40.0,sprintf('Fitted Function YR= %2.1f * exp( -t/%2.1f) ',betaR(1),betaR(2)));
    tx1.Color=[1.0 0 0];
    Plot.PostRotHR.betaR=betaR;
    
    % --- PostRotatoric Left Horizontal ---
    beta0 = [-50 10]; % Anfangswerte f�r die Suche
    betaL = nlinfit(Plot.PostRotHL.dTime,Local.PostRotHL.SPV,Func,beta0); % Parameter sch�tzen    
    plot(ax1,timePost,betaL(1).*exp(-(timePost-Plot.stopRotationTime)./betaL(2)),'b','linewidth', 1.2,'MarkerSize',7.0);
    tx2=text(Plot.stopRotationTime+30.0,30.0,sprintf('Fitted Function YL= %2.1f * exp( -t/%2.1f) ',betaL(1),betaL(2)));
    tx2.Color=[0 0 1.0];
    Plot.PostRotHL.betaL=betaL;
    
    % --- average SPV post rot ---
    dAvgPost=(betaR(1).*exp(-(timePost-Plot.stopRotationTime)./betaR(2))+...
          betaL(1).*exp(-(timePost-Plot.stopRotationTime)./betaL(2)))/2;
    plot(ax1,timePost,dAvgPost,'m','linewidth', 1.2,'MarkerSize',7.0);
    
    % --- difference R L post rotatoric---
    dDiffPost=betaR(1).*exp(-(timePost-Plot.stopRotationTime)./betaR(2))-...
          betaL(1).*exp(-(timePost-Plot.stopRotationTime)./betaL(2));
    plot(ax1,timePost,dDiffPost,'c','linewidth', 1.2,'MarkerSize',7.0);
    
    tx=text(Plot.stopRotationTime+30.0,50.0,sprintf('Average of R and L gaze         Yavg = (YR + YL)/2 ',betaL(1),betaL(2)));
    tx.Color='m';
    tx=text(Plot.stopRotationTime+30.0,60.0,sprintf('Difference between R and L gaze Ydiff = (YR - YL) ',betaL(1),betaL(2)));
    tx.Color='c';
    % ---------------------------------------------------------------------
    % --- SubPlot Bottom ---
    % ---------------------------------------------------------------------
    ax2=subplot(2,1,2);
    hold on;
    
    % --- chair rotation speed ---
    plot(ax2, Plot.headInertialTime,Plot.HeadMovVect,'color',[0.5 0.5 0.5],'linewidth', 1.2,'MarkerSize',7.0);   

    % --- average SPV pre rot ---
    plot(ax2,timePre,dAvgPre,'m','linewidth', 1.2,'MarkerSize',7.0);

    % --- average SPV post rot ---
    plot(ax2,timePost,dAvgPost,'m','linewidth', 1.2,'MarkerSize',7.0);

    % --- timeConstant R L ---
    Plot.timeConstPre=(Plot.meanPosHLpre-Plot.meanPosHRpre)./dDiffPre;
    Plot.timeConstPost = (Plot.meanPosHLpost-Plot.meanPosHRpost)./dDiffPost;
    plot(ax2,timePre,Plot.timeConstPre,'c','linewidth', 2.0,'MarkerSize',7.0);
    plot(ax2,timePost,Plot.timeConstPost,'c','linewidth', 2.0,'MarkerSize',7.0);

    title(['SPVH TimeConstant Y = (YR-YL) / \DeltaPosition ', Plot.Text.szPatient,' ',Plot.Text.szSession,' ',Plot.Text.szTest]);
    ylabel('TimeConstant [s]');
    xlabel('Time');
    legend('Rotation Velocity \circ/s','average pre','average post','TimeConst pre','TimeConst post');

    ylim([-100, 2000]);
    linkaxes([ax1, ax2], 'x');
    grid on;
    
    % --- save into picture and figure ---
    szSaveName =['..\Data\Pictures\',Plot.Text.szPatient,'_',Plot.Text.szTest,'_SPVH_ExpTimeFit.jpg'];%,'Nystagmus_PosData',szPicFile,'.jpg'];
    saveas(gcf,szSaveName);
    szSaveName =['..\Data\Figures\',Plot.Text.szPatient,'_',Plot.Text.szTest,'_SPVH_ExpTimeFit.fig'];%,'Nystagmus_PosData',szPicFile,'.jpg'];
    saveas(gcf,szSaveName);
    % --- timeConstant R L ---
    
    Plot.dDiffPre = dDiffPre;
    Plot.dDiffPost = dDiffPost;
    Plot.dAvgPre = dAvgPre;
    Plot.dAvgPost = dAvgPost;
	outPlot=Plot;
end

