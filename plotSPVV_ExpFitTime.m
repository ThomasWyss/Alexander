function [ outPlot ] = plotSPVV_ExpFitTime( Plot )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    
    figure('Name',['SPVV_Fit ',Plot.Text.szPatient,' ',Plot.Text.szTest],'Position',[1, 1, 1920,1080]); % Fig 4
    ax1=subplot(2,1,1);
    hold on;
    % --- median filter to suppress outliers ---
    Plot.PreRotVR.SPV=medfilt1(Plot.PreRotVR.SPV,3);
    Plot.PreRotVL.SPV=medfilt1(Plot.PreRotVL.SPV,3);
    Plot.PostRotVR.SPV=medfilt1(Plot.PostRotVR.SPV,3);
    Plot.PostRotVL.SPV=medfilt1(Plot.PostRotVL.SPV,3);
    Plot.PostRotVR.SPV=medfilt1(Plot.PostRotVR.SPV,3);
    Plot.PostRotVL.SPV=medfilt1(Plot.PostRotVL.SPV,3);

    title(['SPVV Nonlinear Exponential Fit ', Plot.Text.szPatient,' ',Plot.Text.szTest]);
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
    plot(ax1,Plot.PreRotVR.dTime,Plot.PreRotVR.SPV,'ro','linewidth', 1.2,'MarkerSize',7.0);
    plot(ax1,Plot.PreRotVL.dTime,Plot.PreRotVL.SPV,'bo','linewidth', 1.2,'MarkerSize',7.0);
    plot(ax1,Plot.PostRotVR.dTime,Plot.PostRotVR.SPV,'ro','linewidth', 1.2,'MarkerSize',7.0);
    plot(ax1,Plot.PostRotVL.dTime,Plot.PostRotVL.SPV,'bo','linewidth', 1.2,'MarkerSize',7.0);

    % --- prepare fuction for nonlinear fitting pre rotation---
    Func=@(b,x)(-b(1).*exp(-(x-Plot.startRotationTime)./b(2)));
    timePre=linspace(Plot.startRotationTime,Plot.stopRotationTime,200);
    
    % --- PreRotatoric Right Horizontal ---
    beta0 = [50 10]; % Anfangswerte für die Suche
    betaR = nlinfit(Plot.PreRotVR.dTime,Plot.PreRotVR.SPV,Func,beta0); % Parameter schätzen    
    plot(ax1,timePre,-betaR(1).*exp(-(timePre-Plot.startRotationTime)./betaR(2)),'r','linewidth', 1.2,'MarkerSize',7.0);
    tx1=text(Plot.startRotationTime+30.0,-30.0,sprintf('Fitted Function Y= -%2.1fX * exp( -x/%2.1f) ',betaR(1),betaR(2)));
    tx1.Color=[1.0 0 0];
    Plot.PreRotVR.betaR=betaR;

    % --- PreRotatoric Left Horizontal ---
    beta0 = [50 10]; % Anfangswerte für die Suche
    betaL = nlinfit(Plot.PreRotVL.dTime,Plot.PreRotVL.SPV,Func,beta0); % Parameter schätzen    
    plot(ax1,timePre,-betaL(1).*exp(-(timePre-Plot.startRotationTime)./betaL(2)),'b','linewidth', 1.2,'MarkerSize',7.0);
    tx2=text(Plot.startRotationTime+50.0,-40.0,sprintf('Fitted Function Y= -%2.1fX * exp( -x/%2.1f) ',betaL(1),betaL(2)));
    tx2.Color=[0 0 1.0];
    Plot.PreRotVL.betaL=betaL;
              
    % --- difference R L ---
    dDiffPre=-betaR(1).*exp(-(timePre-Plot.startRotationTime)./betaR(2))+...
        betaL(1).*exp(-(timePre-Plot.startRotationTime)./betaL(2));
    plot(ax1,timePre,dDiffPre,'c','linewidth', 1.2,'MarkerSize',7.0);

    % --- average SPV pre rot ---
    dAvgPre=(betaR(1).*exp(-(timePre-Plot.startRotationTime)./betaR(2))+...
          betaL(1).*exp(-(timePre-Plot.startRotationTime)./betaL(2)))/2;
    plot(ax1,timePre,dAvgPre,'m','linewidth', 1.2,'MarkerSize',7.0);

    % --- prepare fuction for nonlinear fitting post rotation---
    Func=@(b,x)(b(1).*exp(-(x-Plot.stopRotationTime)./b(2)));
    timePost=linspace(Plot.stopRotationTime,Plot.headInertialTime(end),200);

    % --- PosRotatoric Right Horizontal ---
    beta0 = [50 10]; % Anfangswerte für die Suche
    betaR = nlinfit(Plot.PostRotVR.dTime,Plot.PostRotVR.SPV,Func,beta0); % Parameter schätzen    
    plot(ax1,timePost,betaR(1).*exp(-(timePost-Plot.stopRotationTime)./betaR(2)),'r','linewidth', 1.2,'MarkerSize',7.0);
    tx1=text(Plot.stopRotationTime+30.0,30.0,sprintf('Fitted Function Y= %2.1fX * exp( -x/%2.1f) ',betaR(1),betaR(2)));
    tx1.Color=[1.0 0 0];
    Plot.PostRotVR.betaR=betaR;
        
    % --- PostRotatoric Left Horizontal ---
    beta0 = [50 10]; % Anfangswerte für die Suche
    betaL = nlinfit(Plot.PostRotVL.dTime,Plot.PostRotVL.SPV,Func,beta0); % Parameter schätzen    
    plot(ax1,timePost,betaL(1).*exp(-(timePost-Plot.stopRotationTime)./betaL(2)),'b','linewidth', 1.2,'MarkerSize',7.0);
    tx2=text(Plot.stopRotationTime+30.0,40.0,sprintf('Fitted Function Y= %2.1fX * exp( -x/%2.1f) ',betaL(1),betaL(2)));
    tx2.Color=[0 0 1.0];
    Plot.PostRotVL.betaL=betaL;
                
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

    % --- difference R L ---
    plot(ax2,timePre,(Plot.meanPosVLpre-Plot.meanPosVRpre)./dDiffPre,'m','linewidth', 2.0,'MarkerSize',7.0);
    plot(ax2,timePost,(Plot.meanPosVLpost-Plot.meanPosVRpost)./dDiffPost,'m','linewidth', 2.0,'MarkerSize',7.0);

    title(['SPVH TimeConstant Y = (YR-YL) / \DeltaPosition ', Plot.Text.szPatient,' ',Plot.Text.szTest]);
    ylabel('TimeConstant [s]');
    xlabel('Time');
    legend('Rotation Velocity \circ/s','TimeConstant');

    ylim([-200, 1000]);
    linkaxes([ax1, ax2], 'x');
    grid on;

    % --- save into picture and figure ---
    szSaveName =['..\Data\Pictures\',Plot.Text.szPatient,'_',Plot.Text.szTest,'_SPVV_ExpTimeFit.jpg'];%,'Nystagmus_PosData',szPicFile,'.jpg'];
    saveas(gcf,szSaveName);
    szSaveName =['..\Data\Figures\',Plot.Text.szPatient,'_',Plot.Text.szTest,'_SPVV_ExpTimeFit.fig'];%,'Nystagmus_PosData',szPicFile,'.jpg'];
    saveas(gcf,szSaveName);

	outPlot=Plot;
end

