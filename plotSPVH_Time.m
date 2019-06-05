%-------------------------------------------------------------------------
%   plotSPV_Time_Graph
%   Plot Slow Phase Velocity and (horizontal) eye position
%   
%   ZeroCrossIndex: Number of samples  divided by number of
%                   zero crossings. Will be printed in red
%                   when below 4.0 and green when above 4.0
%                   (bNyst)
%   aNystSPVdataH_S:    ,1) mean of velocity points
%                       ,7) dy/dx
%
%   pre selected data concerning outliers
%   SPV_Pos(:,1)= EyPosDeg
%   SPV_Pos(:,2)= (rotspeed)
%   SPV_Pos(:,3)= dTime
%   SPV_Pos(:,3)= meanSPVH
%
%   Date:   06.07.2018 wyt  separate line for each LED position
%-------------------------------------------------------------------------
function [ err ] = plotSPVH_Time(Plot)
    
%     clear meanPartSPV;
    
    figure('Name',['SPVH_Time ', Plot.Text.szPatient,' ',Plot.Text.szTest],'Position',[1, 1, 1920,1080]); % Fig 4
    ax1=subplot(2,1,1);
    
    [~,endIdx] = size(Plot.meanSPVH);
    cc=1;
    for jj = 2:endIdx-1       

        if abs(Plot.meanSPVH(jj))>Plot.minSPV
            if abs(Plot.SPVDeltaH(jj))<Plot.NystBeatDeltaMax
                if Plot.EyePosDeg(Plot.startSPVH_S(jj),1)> Plot.LRsH
                    plot(Plot.dTime(Plot.startSPVH_S(jj)),Plot.meanSPVH(jj),'ro','linewidth', 1.2,'MarkerSize',7.0); hold on;
                else
                    plot(Plot.dTime(Plot.startSPVH_S(jj)),Plot.meanSPVH(jj),'bo','linewidth', 1.2,'MarkerSize',7.0); hold on;
                end               
            else
                plot(Plot.dTime(Plot.startSPVH_S(jj)),Plot.meanSPVH(jj),'co','linewidth', 1.2,'MarkerSize',7.0); hold on;                   
            end                
        
           pp(cc,1) = Plot.dTime(Plot.startSPVH_S(jj));
           pp(cc,2) = Plot.meanSPVH(jj);
           cc=cc+1;
        end
        if Plot.NystSignH(jj)==false && abs(Plot.meanSPVH(jj))>Plot.minSPV          
%            plot(Plot.dTime(Plot.startSPVH_S(jj)),meanSPV,'ro','linewidth', 1.2,'MarkerSize',7.0); hold on; 
        end
    end
    
    plot(ax1, Plot.headInertialTime,Plot.HeadMovVect,'r','linewidth', 1.2,'MarkerSize',7.0);
%     xlim([108.8 110.4]);
    ylim([-230 230]);
    title(['SPVH at Time ', Plot.Text.szPatient,' ',Plot.Text.szTest]);
    xlabel('Time [s]');
    ylabel('SPV [\circ/s]');

    line([0,0],get(gca,'ylim'),'Color',[0.0 0.0 0.0],'LineWidth',1.5);hold on
    line(get(gca,'xlim'),[0,0],'Color',[0.0 0.0 0.0],'LineWidth',1.5);
    grid on;
    
    % ---------------------------------------------------------------------
    % Horizontal: Plot all points (dot blue)
    %             Plot zero crossings (diamond red)
    %             Plot start of nyst beat (circle black)
    %             Plot end of nyst beat (X black)
    % ---------------------------------------------------------------------
    ax2 = subplot(2,1,2);   
    hold on;
    plot(Plot.dTime,Plot.EyePosDeg(:,1),'k.' )
    plot(Plot.dTime(1:end-1),Plot.SPVRaw(:,1)/20,'.' )
    plot(Plot.dTime(1:end-2),Plot.AccelrationRaw(:,1)/20,'.' )
    plot(Plot.dTime(Plot.idxZeroCrossH_S),Plot.EyePosDeg(Plot.idxZeroCrossH_S,1),'rd'); % zero crossings!!
    plot(Plot.dTime(Plot.startSPVH_S),Plot.EyePosDeg(Plot.startSPVH_S,1),'ko','linewidth', 1.2,'MarkerSize',10.0);   % start of nystagmus beat
    plot(Plot.dTime(Plot.stoppSPVH_S),Plot.EyePosDeg(Plot.stoppSPVH_S,1),'kx','linewidth', 1.2,'MarkerSize',10.0);   % start of nystagmus beat
    
    for idx = 2:endIdx-1                       % plot the position in deg   

        if abs(Plot.meanSPVH(idx))>Plot.minSPV 
            if abs(Plot.SPVDeltaH(idx))<Plot.NystBeatDeltaMax
                if Plot.EyePosDeg(Plot.startSPVH_S(idx),1)> Plot.LRsH
                    plot(Plot.dTime(Plot.startSPVH_S(idx):Plot.stoppSPVH_S(idx)),Plot.aNystBeatH_S(idx,1:Plot.iNbrPointH(idx)),'r','linewidth', 3.0); 
                else
                    plot(ax2,Plot.dTime(Plot.startSPVH_S(idx):Plot.stoppSPVH_S(idx)),Plot.aNystBeatH_S(idx,1:Plot.iNbrPointH(idx)),'b','linewidth', 3.0); 
                end
            else
                plot(ax2, Plot.dTime(Plot.startSPVH_S(idx):Plot.stoppSPVH_S(idx)),Plot.aNystBeatH_S(idx,1:Plot.iNbrPointH(idx)),'c','linewidth', 3.0); 
            end
        end
        if Plot.NystSignH(idx)==false && abs(Plot.meanSPVH(idx))>Plot.minSPV     %Saccades
%             plot(Plot.dTime(Plot.startSPVH_S(idx):Plot.stoppSPVH_S(idx)),Plot.aNystBeatH_S(idx,1:iNbrPoint),'r','linewidth', 3.0); 
        end
            
        szMeanSPVH=sprintf('%3.1f  %3.1fms' ,Plot.meanSPVH(idx),Plot.dTimeDeltaH(idx)*1e3);       % text of mean SPV of each nystagmus beat
%         szMeanSPVH=sprintf('%3.1f  %3.1fms  %d %d' ,meanSPV,dTimeDiff*1e3,Plot.startSPVH_S(idx),Plot.stoppSPVH_S(idx));       % text of mean SPV of each nystagmus beat
        h1=text(Plot.dTime(Plot.startSPVH_S(idx)),1.1*Plot.EyePosDeg(Plot.startSPVH_S(idx),1),szMeanSPVH);
        set (h1, 'Clipping', 'on');     
    end
    
    grid on;
    title(['Horizontal Position ', Plot.Text.szPatient,' ',Plot.Text.szTest]);
    ylabel('Pos [\circ]');
    xlabel('Time [s]');
    ylim([-100 100]);
%     xlim([108.8 110.4]);
    linkaxes([ax1, ax2], 'x');

    szSaveName =['..\Data\Pictures\',Plot.Text.szFileName(1:end-4),'_SPVH_Time.jpg'];%,'Nystagmus_PosData',szPicFile,'.jpg'];
    saveas(gcf,szSaveName);
    szSaveName =['..\Data\Figures\',Plot.Text.szFileName(1:end-4),'_SPVH_Time.fig'];%,'Nystagmus_PosData',szPicFile,'.jpg'];
    saveas(gcf,szSaveName);
    
     return    
end
