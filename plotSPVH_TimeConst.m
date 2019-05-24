function [ err ] = plotSPVH_TimeConst( Plot )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    
    figure('Name',['SPVH_Fit ', Plot.Text.szFileName(1:end-4)],'Position',[1, 1, 1920,1080]); % Fig 4
    ax1=subplot(1,1,1);
    hold on;
    Local.PreRotHR.SPV=diff(medfilt1(Plot.PreRotHR.SPV,3));
    Local.PreRotHL.SPV=diff(medfilt1(Plot.PreRotHL.SPV,3));
    Local.PostRotHR.SPV=diff(medfilt1(Plot.PostRotHR.SPV,3));
    Local.PostRotHL.SPV=diff(medfilt1(Plot.PostRotHL.SPV,3));
    
    Local.PreRotHR.Pos=diff(medfilt1(Plot.PreRotHR.Pos,3));
    Local.PreRotHL.Pos=diff(medfilt1(Plot.PreRotHL.Pos,3));
    Local.PostRotHR.Pos=diff(medfilt1(Plot.PostRotHR.Pos,3));
    Local.PostRotHL.Pos=diff(medfilt1(Plot.PostRotHL.Pos,3));
    
    % --- PreRotatoric Horizontal ---
    time=linspace(Plot.startRotationTime,Plot.stopRotationTime,200);
    deltaHRSPV=-Plot.PreRotHR.betaR(1).*exp(-(time-Plot.startRotationTime)./Plot.PreRotHR.betaR(2));
    deltaHLSPV=-Plot.PreRotHL.betaL(1).*exp(-(time-Plot.startRotationTime)./Plot.PreRotHL.betaL(2));
    Tau=36./(deltaHRSPV-deltaHLSPV);
%     plot(ax1,time,deltaHRSPV,'g','linewidth', 1.2,'MarkerSize',7.0);
%     plot(ax1,time,deltaHLSPV,'g','linewidth', 1.2,'MarkerSize',7.0);
%     plot(ax1,time,(deltaHRSPV+deltaHLSPV)/2,'k.','linewidth', 1.2,'MarkerSize',7.0);
%     plot(ax1,time,(deltaHRSPV-deltaHLSPV),'m','linewidth', 1.2,'MarkerSize',7.0);
    plot(ax1,time,Tau,'k','linewidth', 1.2,'MarkerSize',7.0);
    
    % --- PostRotatoric Horizontal ---
    time=linspace(Plot.stopRotationTime,Plot.headInertialTime(end),200);
    deltaHRSPV=Plot.PostRotHR.betaR(1).*exp(-(time-Plot.stopRotationTime)./Plot.PostRotHR.betaR(2));
    deltaHLSPV=Plot.PostRotHL.betaL(1).*exp(-(time-Plot.stopRotationTime)./Plot.PostRotHL.betaL(2));
    Tau=36./(deltaHRSPV-deltaHLSPV);
%     plot(ax1,time,deltaHRSPV,'g','linewidth', 1.2,'MarkerSize',7.0);
%     plot(ax1,time,deltaHLSPV,'g','linewidth', 1.2,'MarkerSize',7.0);
%     plot(ax1,time,(deltaHRSPV+deltaHLSPV)/2,'k.','linewidth', 1.2,'MarkerSize',7.0);
%     plot(ax1,time,(deltaHRSPV-deltaHLSPV),'m','linewidth', 1.2,'MarkerSize',7.0);
    plot(ax1,time,Tau,'k','linewidth', 1.2,'MarkerSize',7.0);

    plot(ax1,Plot.PreRotHR.dTime(1:end-1),mean(Local.PreRotHR.Pos)./Local.PreRotHR.SPV,'ro','linewidth', 1.2,'MarkerSize',7.0);
    plot(ax1,Plot.PreRotHL.dTime(1:end-1),mean(Local.PreRotHL.Pos)./Local.PreRotHL.SPV,'bo','linewidth', 1.2,'MarkerSize',7.0);
    plot(ax1,Plot.PostRotHR.dTime(1:end-1),mean(Local.PostRotHR.Pos)./Local.PostRotHR.SPV,'ro','linewidth', 1.2,'MarkerSize',7.0);
    plot(ax1,Plot.PostRotHL.dTime(1:end-1),mean(Local.PostRotHL.Pos)./Local.PostRotHL.SPV,'bo','linewidth', 1.2,'MarkerSize',7.0);
    line(get(gca,'xlim'),[0,0],'Color',[0.0 0.0 0.0],'LineWidth',1.5);
    plot(ax1, Plot.headInertialTime,Plot.HeadMovVect/10,'color',[0.5 0.5 0.5],'linewidth', 1.2,'MarkerSize',7.0);   
    
    title(['SPVH TimeConst ', Plot.Text.szFileName(1:end-4)]);
    ylabel('TimeConst [s]');
    xlabel('Time');
    legend('Right Tau H','Left Tau H');
%     xlim([108.8 110.4]);
    ylim([-200, 200]);
    grid on;
    % --- save into picture and figure ---
    szSaveName =['..\Data\Pictures\',Plot.Text.szFileName(1:end-4),'_SPVH_TimeConst.jpg'];%,'Nystagmus_PosData',szPicFile,'.jpg'];
    saveas(gcf,szSaveName);
    szSaveName =['..\Data\Figures\',Plot.Text.szFileName(1:end-4),'_SPVH_TimeConst.fig'];%,'Nystagmus_PosData',szPicFile,'.jpg'];
    saveas(gcf,szSaveName);

err=-778;
end

