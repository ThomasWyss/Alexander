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
function [ err ] = plotSPVV_Time_Graph(Plot)
    
%     clear meanPartSPV;
    
    figure('Name',['SPVV_Time ',Plot.Text.szFileName(1:end-4)],'Position',[1, 1, 1920,1080]); % Fig 4
    ax1=subplot(2,1,1);
    
    [~,endIdx] = size(Plot.meanSPVV);
    cc=1;
    for jj = 2:endIdx-1       
%         if Plot.NystSignV(jj)==true && abs(Plot.meanSPVV(jj))>Plot.minSPV
        if abs(Plot.meanSPVV(jj))>Plot.minSPV
            if abs(Plot.SPVDeltaV(jj))<Plot.NystBeatDeltaMax
                if Plot.EyePosDeg(Plot.startSPVV_S(jj),2)> Plot.LRsV
                    plot(Plot.dTime(Plot.startSPVV_S(jj)),Plot.meanSPVV(jj),'ro','linewidth', 1.2,'MarkerSize',7.0); hold on;
                else
                    plot(Plot.dTime(Plot.startSPVV_S(jj)),Plot.meanSPVV(jj),'bo','linewidth', 1.2,'MarkerSize',7.0); hold on;
                end
            else
                plot(Plot.dTime(Plot.startSPVV_S(jj)),Plot.meanSPVV(jj),'co','linewidth', 1.2,'MarkerSize',7.0); hold on;                   
            end                
        
           pp(cc,1) = Plot.EyePosDeg(Plot.startSPVV_S(jj),2);
           pp(cc,2) = Plot.meanSPVV(jj);
           cc=cc+1;
        end
        if Plot.NystSignV(jj)==false && abs(Plot.meanSPVV(jj))>Plot.minSPV          
%            plot(Plot.dTime(Plot.startSPVH_S(jj)),meanSPV,'ro','linewidth', 1.2,'MarkerSize',7.0); hold on; 
        end
    end
    
    plot(ax1, Plot.headInertialTime,Plot.HeadMovVect,'r','linewidth', 1.2,'MarkerSize',7.0);
    ylim([-230 230]);
    title(['SPVV at Time ', Plot.Text.szFileName(1:end-4)]);
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
    plot(Plot.dTime,Plot.EyePosDeg(:,2),'.' )
    plot(Plot.dTime(Plot.idxZeroCrossV_S),Plot.EyePosDeg(Plot.idxZeroCrossV_S,2),'rd'); % zero crossings!!
    plot(Plot.dTime(Plot.startSPVV_S),Plot.EyePosDeg(Plot.startSPVV_S,2),'ko','linewidth', 1.2,'MarkerSize',10.0);   % start of nystagmus beat
    plot(Plot.dTime(Plot.stoppSPVV_S),Plot.EyePosDeg(Plot.stoppSPVV_S,2),'kx','linewidth', 1.2,'MarkerSize',10.0);   % start of nystagmus beat
    
    for idx = 2:endIdx-1                       % plot the position in deg   

%         if Plot.NystSignV(idx)==true % && abs(SPV_Pos(jj,4))>Plot.minSPV 
        if abs(Plot.meanSPVV(idx))>Plot.minSPV 
            if abs(Plot.SPVDeltaV(idx))<Plot.NystBeatDeltaMax
                if Plot.EyePosDeg(Plot.startSPVV_S(idx),2)> Plot.LRsV
                    plot(ax2, Plot.dTime(Plot.startSPVV_S(idx):Plot.stoppSPVV_S(idx)),Plot.aNystBeatV_S(idx,1:Plot.iNbrPointV(idx)),'r','linewidth', 3.0); 
                else
                    plot(ax2, Plot.dTime(Plot.startSPVV_S(idx):Plot.stoppSPVV_S(idx)),Plot.aNystBeatV_S(idx,1:Plot.iNbrPointV(idx)),'b','linewidth', 3.0); 
                end
            else
                plot(ax2, Plot.dTime(Plot.startSPVV_S(idx):Plot.stoppSPVV_S(idx)),Plot.aNystBeatV_S(idx,1:Plot.iNbrPointV(idx)),'c','linewidth', 3.0); 
            end
        end
        if Plot.NystSignV(idx)==false && abs(Plot.meanSPVV(idx))>Plot.minSPV     %Saccades
%             plot(Plot.dTime(Plot.startSPVH_S(idx):Plot.stoppSPVH_S(idx)),Plot.aNystBeatH_S(idx,1:iNbrPoint),'r','linewidth', 3.0); 
        end
            
        szMeanSPVV=sprintf('%3.1f  %3.1fms' ,Plot.meanSPVV(idx),Plot.dTimeDeltaV(idx)*1e3);       % text of mean SPV of each nystagmus beat
%         szMeanSPVH=sprintf('%3.1f  %3.1fms  %d %d' ,meanSPV,dTimeDiff*1e3,Plot.startSPVH_S(idx),Plot.stoppSPVH_S(idx));       % text of mean SPV of each nystagmus beat
        h1=text(Plot.dTime(Plot.startSPVV_S(idx)),1.1*Plot.EyePosDeg(Plot.startSPVV_S(idx),2),szMeanSPVV);
        set (h1, 'Clipping', 'on');     
    end
    
    grid on;
    title(['Horizontal Position ', Plot.Text.szFileName(1:end-4)]);
    ylabel('Pos [\circ]');
    xlabel('Time [s]');
    linkaxes([ax1, ax2], 'x');

    szSaveName =['..\Data\Pictures\',Plot.Text.szFileName(1:end-4),'_SPVV_Time.jpg'];%,'Nystagmus_PosData',szPicFile,'.jpg'];
    saveas(gcf,szSaveName);
    szSaveName =['..\Data\Figures\',Plot.Text.szFileName(1:end-4),'_SPVV_Time.fig'];%,'Nystagmus_PosData',szPicFile,'.jpg'];
    saveas(gcf,szSaveName);
    
     return    
end
