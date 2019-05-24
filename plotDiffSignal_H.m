function [ err ] = plotDiffSignal( dTime,withoutSaccade, EyePosSPVConv, EyePosDeg, EyePosDiff, EyePosDiff2, SPVMedianAcc, szFileName, szType )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    Len=size(dTime);
    figure('Name',['Diff Signals ',szFileName,' velocity + acceleration']);  % Fig 2
    
    hold on;
    yyaxis right;
    plot(dTime(1:end-1),EyePosDeg(1:Len-1,1),'g','linewidth', 3.0); 
    ylabel('SPV');

    yyaxis left;
%     plot(dTime(1:end-1),medfilt1(EyePosDiff(1:Len-1,1),5) ,'r','linewidth', 1.2); 
    plot(dTime(1:end-1),EyePosDiff(1:Len-1,1) ,'r','linewidth', 1.2); 
    plot(dTime(1:end-1),medfilt1(EyePosDiff(1:Len-1,1),5) ,'y','linewidth', 1.2); 
    plot(dTime(1:end-2),medfilt1(EyePosDiff2(1:Len-2,1),5),'b','linestyle','-','linewidth', 1.2);
    plot(dTime(1:end-1),withoutSaccade,'c','linestyle','-','linewidth', 3.0);
    %title([szFileName,'   ',fData.Examintion, '   ', fData.Condition]);
    xlabel('Time [s]');
    ylabel('SPV');
    legend('SPV H',  'Acc H', 'sacc','Pos H');
    xlim([16, 17.5]);
    ylim([-200, 200]);
    grid on;

%     ax2=subplot(2,1,2);
%     xlabel('Time [s]');
%     plot(ax2,dTime(1:end-2),EyePosDiff2); hold on;
%     plot(ax2,dTime(1:end-2),SPVMedianAcc,'linewidth', 1.2);
%     linkaxes([ax1, ax2], 'x');
%     ylabel('acceleration');
%     xlabel('Time [s]');
%     legend('accel. H','accel. V');
%     xlim([16, 17.5]);
%     ylim([-500, 500]);
%     grid on;

err=-777;
end

