function [ err ] = plotPosSignal( dTime,EyePosDegMedian, EyePosDeg, szPatient )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    figure('Name',['Position ',szPatient,' plotPosSignal']);  % Fig 2
    ax1=subplot(1,1,1);
    plot(ax1,dTime(1:end),EyePosDeg,'k'); hold on;
    plot(ax1,dTime(1:end-1),EyePosDegMedian(1:end-1,1),'r','linewidth', 1.2); hold on;
    plot(ax1,dTime(1:end-1),EyePosDegMedian(1:end-1,2),'g','linewidth', 1.2); hold on;
    %title([szFileName,'   ',fData.Examination, '   ', fData.Condition]);
    xlabel('Time [s]');
    ylabel('Position');
    legend('Pos H','Pos V', 'median Pos H','median Pos V');
    xlim([108.8 110.4]);
    ylim([-50, 50]);
    grid on;

err=-777;
end

