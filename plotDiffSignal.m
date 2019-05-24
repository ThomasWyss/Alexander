function [ err ] = plotDiffSignal( dTime,EyePosSPVMedian, EyePosSPVConv, EyePosDeg, EyePosDiff, EyePosDiff2, SPVMedianAcc, szFileName, szType )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    Len=size(dTime);
    figure('Name',['Diff Signals ',szFileName,' velocity + acceleration']);  % Fig 2
    ax1=subplot(2,1,1);
    plot(ax1,dTime(1:end-1),EyePosDiff,'k'); hold on;
    plot(ax1,dTime(1:end-1),EyePosDeg(1:Len-1,1),'g','linewidth', 3.0); 
    plot(ax1,dTime(1:end-1),EyePosSPVMedian(1:Len-1,1),'r','linewidth', 1.2); 
%     plot(ax1,dTime(1:end-1),EyePosSPVMedian(1:Len-1,2),'linewidth', 1.2);
    plot(ax1,dTime(1:end-1),EyePosSPVConv(1:Len-1,1),'b','linewidth', 1.2); 
%     plot(ax1,dTime(1:end-1),EyePosSPVConv(1:Len-1,2),'linewidth', 1.2);     % V    

    %title([szFileName,'   ',fData.Examination, '   ', fData.Condition]);
    xlabel('Time [s]');
    ylabel('SPV');
    legend('SPV H','SPV V', 'pos', 'median H','median V','conv H' ,'conv V');
    xlim([16, 17.5]);
    ylim([-100, 100]);
    grid on;

    ax2=subplot(2,1,2);
    xlabel('Time [s]');
    plot(ax2,dTime(1:end-2),EyePosDiff2); hold on;
    plot(ax2,dTime(1:end-2),SPVMedianAcc,'linewidth', 1.2);
    linkaxes([ax1, ax2], 'x');
    ylabel('acceleration');
    xlabel('Time [s]');
    legend('accel. H','accel. V');
    xlim([16, 17.5]);
    ylim([-500, 500]);
    grid on;

err=-777;
end

