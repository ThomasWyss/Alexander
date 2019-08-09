function [ outPlot ] = plotTimeConstH_avgSPV(Plot)
% ########################################################################
% ## aktuell muss diese subroutine vor subroutinen ausgeführt werden
% ## welche die parameter der exponential funktion benötigen
% ########################################################################

    figure('Name',['TimeConst_avgSPV ',Plot.Text.szPatient,' ',Plot.Text.szSession,' ',Plot.Text.szTest],'Position',[1, 1, 1920,1080]); % Fig 4
    ax1=subplot(2,1,1);
    hold on;

%     timePre=linspace(Plot.startRotationTime,Plot.stopRotationTime,200);
%     timePost=linspace(Plot.stopRotationTime,Plot.headInertialTime(end),200);

    % --- timeConstant R L ---
%     Plot.timeConstantPre = (Plot.meanPosHLpre-Plot.meanPosHRpre)./dDiffPre
    % --- average SPV pre rot ---
%     Plot.dAvgPre=(betaR(1).*exp(-(timePre-Plot.startRotationTime)./betaR(2))+...
%           betaL(1).*exp(-(timePre-Plot.startRotationTime)./betaL(2)))/2;

%       % --- average SPV post rot ---
%     Plot.dAvgPost=(Plot.PostRotHL.betaR(1).*exp(-(timePost-Plot.stopRotationTime)./Plot.PostRotHR.betaR(2))+...
%           Plot.PostRotHL.betaL(1).*exp(-(timePost-Plot.stopRotationTime)./Plot.PostRotHL.betaL(2)))/2;

    % --- PreRotatoric Horizontal avgSPV / timeConst---
    plot(ax1,Plot.dAvgPre, Plot.timeConstPre,'m','linewidth', 1.2,'MarkerSize',7.0);
    plot(ax1,Plot.dAvgPost,Plot.timeConstPost,'c','linewidth', 1.2,'MarkerSize',7.0);
    
    title(['SPVH TimeConstant / avgSPV ', Plot.Text.szPatient,' ',Plot.Text.szSession,' ',Plot.Text.szTest]);
    ylabel('TimeConstant [s]');
    xlabel('avgSPV');
    xlim([-60, 60]);
    ylim([-30, 30]);
    legend('Pre Rotation','Post Rotation');

%     % --- PreRotatoric Horizontal avgSPV / timeConst---
%     plot(ax1,timePre,Plot.dAvgPre,'c','linewidth', 1.2,'MarkerSize',7.0);
%     plot(ax1,timePost,Plot.dAvgPost,'c','linewidth', 1.2,'MarkerSize',7.0);
 
    grid on;

    

outPlot=Plot;
end