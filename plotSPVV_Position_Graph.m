%-------------------------------------------------------------------------
%   plotSPV_Postiton_Graph
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
%   SPV_Pos(:,2)= meanSPVH
%   SPV_Pos(:,3)= dTime
%
%-------------------------------------------------------------------------
function [ err ] = plotSPVV_Position_Graph(Plot,Out)

    clear meanPartSPV;
    
    figure('Name',['SPVV_Position ', Plot.Text.szFileName(1:end-4)],'Position',[1, 1, 1920,1080]); % Fig 4
    x=linspace(-40,40,100);
    subplot(2,1,1);

    cc=1;
    [~,endIdx]=size(Plot.meanSPVV);
    for jj = 1:endIdx-1
        if Plot.NystSignV(jj)==true && abs(Plot.meanSPVV(jj))>Plot.minSPV...
                && Plot.dTime(Plot.startSPVV_S(jj))<Plot.stopRotationTime
            
             if abs(Plot.SPVDeltaV(jj))<Plot.NystBeatDeltaMax
                if Plot.EyePosDeg(Plot.startSPVV_S(jj),2)> Plot.LRsV
                    plot(Plot.EyePosDeg(Plot.startSPVV_S(jj),2),Plot.meanSPVV(jj),'ro','linewidth', 1.2,'MarkerSize',7.0); hold on;
                else
                    plot(Plot.EyePosDeg(Plot.startSPVV_S(jj),2),Plot.meanSPVV(jj),'bo','linewidth', 1.2,'MarkerSize',7.0); hold on;
                end
             else
                plot(Plot.EyePosDeg(Plot.startSPVV_S(jj),2),Plot.meanSPVV(jj),'co','linewidth', 1.2,'MarkerSize',7.0); hold on;                   
             end                
                       
           pp(cc,1) =Plot.EyePosDeg(Plot.startSPVV_S(jj),2);
           pp(cc,2) = Plot.meanSPVV(jj);
           cc=cc+1;
        end
%         if Plot.NystSign(jj)==true && abs(SPV_Pos(jj+1,4))>Plot.minSPV
%            plot(SPV_Pos(jj,1),SPV_Pos(jj,4),'go','linewidth', 1.2,'MarkerSize',7.0); hold on; 
%            pp(cc,1) = SPV_Pos(jj+1,1);
%            pp(cc,2) = SPV_Pos(jj+1,4);
%            cc=cc+1;
%         end
        if Plot.NystSignV(jj)==false           
%            plot(SPV_Pos(jj,1),SPV_Pos(jj,4),'ro','linewidth', 1.2,'MarkerSize',7.0); hold on; 
        end
    end
    
    pm=polyfit(pp(:,1),pp(:,2),1);
    plot(x,pm(1)*x+pm(2),'g','linewidth', 1.2); hold on;
    
    title(['SPVV at Position ', Plot.Text.szFileName(1:end-4)]);
    xlabel('Vertical Position [\circ]');
    ylabel('SPV [\circ/s]');
    xlim([-40,40]);
    ylim([-Plot.dOutlierBoundary,Plot.dOutlierBoundary]);
    line([0,0],get(gca,'ylim'),'Color',[0.0 0.0 0.0],'LineWidth',1.5);hold on
    line(get(gca,'xlim'),[0,0],'Color',[0.0 0.0 0.0],'LineWidth',1.5);
    tx1=text(-35.0,-10.0,sprintf('Fitted Function Y= %2.1fX + %2.1f all',pm(1),pm(2)));
%     tx2=text(-35.0,-35.0,sprintf('Fitted Function Y= %2.1fX + %2.1f saccades',pm(1),pm(2)));
%     tx3=text(-35.0,-60.0,sprintf('Fitted Function Y= %2.1fX + %2.1f nystagmus',pb(1),pb(2)));
    tx1.Color=[1.0 0 0];
    tx2.Color='m';
    tx3.Color=[0 0 1.0];
%     text(-35.0,-0.9*Plot.dOutlierBoundary,sprintf('mean SPV = %2.1f',Plot.aNystSPVdataH_Smean(:,1)));    
    
%     tx=text(-35.0,-0.8*Plot.dOutlierBoundary,sprintf('ZeroCrossIdx %2.1f',size(Plot.EyePosDeg)/size(Plot.idxZeroCrossH)));
    tx.Color=[0 1.0 0];
    if ~Out.Nystagmus
        tx.Color=[1.0 0 0];     
    end
    grid on;
    
  
    subplot(2,1,2);

    hold on;
    plot(Plot.dTime,Plot.EyePosDeg(:,2),'.' )
    plot(Plot.dTime(Plot.idxZeroCrossV_S),Plot.EyePosDeg(Plot.idxZeroCrossV_S,2),'rd'); % zero crossings!!
    plot(Plot.dTime(Plot.startSPVV_S),Plot.EyePosDeg(Plot.startSPVV_S,2),'ko','linewidth', 1.2,'MarkerSize',10.0);   % start of nystagmus beat
    plot(Plot.dTime(Plot.stoppSPVV_S),Plot.EyePosDeg(Plot.stoppSPVV_S,2),'kx','linewidth', 1.2,'MarkerSize',10.0);   % start of nystagmus beat

    
    for idx = 2:endIdx-1                       % plot the position in deg   

        if Plot.NystSignV(idx)==true % && abs(SPV_Pos(jj,4))>Plot.minSPV 
            if Plot.SPVDeltaV(idx)<Plot.NystBeatDeltaMax
                if Plot.EyePosDeg(Plot.startSPVV_S(idx),2)> Plot.LRsV
                    plot(Plot.dTime(Plot.startSPVV_S(idx):Plot.stoppSPVV_S(idx)),Plot.aNystBeatV_S(idx,1:Plot.iNbrPointV(idx)),'r','linewidth', 3.0); 
                else
                    plot(Plot.dTime(Plot.startSPVV_S(idx):Plot.stoppSPVV_S(idx)),Plot.aNystBeatV_S(idx,1:Plot.iNbrPointV(idx)),'b','linewidth', 3.0); 
                end
            else
                plot(Plot.dTime(Plot.startSPVV_S(idx):Plot.stoppSPVV_S(idx)),Plot.aNystBeatV_S(idx,1:Plot.iNbrPointV(idx)),'c','linewidth', 3.0); 
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
    title(['Vertical Position ', Plot.Text.szFileName(1:end-4)]);
    ylabel('Position [\circ]');
    legend('Eye Pos. V','Zero Crossing V','Begin V','End V','Nystagmus Beat V,','ABC');
    ylim([-50,40]);

    szSaveName =['..\Data\Pictures\',Plot.Text.szFileName(1:end-4),'_SPVV_Pos.jpg'];%,'Nystagmus_PosData',szPicFile,'.jpg'];
    saveas(gcf,szSaveName);
    szSaveName =['..\Data\Figures\',Plot.Text.szFileName(1:end-4),'_SPVV_Pos.fig'];%,'Nystagmus_PosData',szPicFile,'.jpg'];
    saveas(gcf,szSaveName);

    return
     
     for idx = 2:2:size(Plot.endSPVV_S)-1                             % plot the position in deg   
        NystSignV(idx)=0;
        
        iNbrPoint =     Plot.stoppSPVV_S(idx)-Plot.startSPVV_S(idx)+1;
        iNbrPointPre =  Plot.stoppSPVV_S(idx-1)-Plot.startSPVV_S(idx-1)+1;
        dTimeDiff=      Plot.dTime(Plot.stoppSPVV_S(idx))-Plot.dTime(Plot.startSPVV_S(idx));
        dTimeDiffPre=   Plot.dTime(Plot.stoppSPVV_S(idx-1))-Plot.dTime(Plot.startSPVV_S(idx-1));
        SPVDiff=        Plot.EyePosDeg(Plot.stoppSPVV_S(idx))-Plot.EyePosDeg(Plot.startSPVV_S(idx),2);
        SPVDiffPre=     Plot.EyePosDeg(Plot.stoppSPVV_S(idx-1))-Plot.EyePosDeg(Plot.startSPVV_S(idx-1),2);
        meanSPV=SPVDiff/dTimeDiff;
        meanSPVPre=SPVDiffPre/dTimeDiffPre;
           
        if (meanSPVPre>0 && meanSPV>0)NystSign(idx)=1;   end
        if (meanSPVPre>0 && meanSPV<0)NystSign(idx)=2;   end
        if (meanSPVPre<0 && meanSPV>0)NystSign(idx)=3;   end
        if (meanSPVPre<0 && meanSPV<0)NystSign(idx)=4;   end

        if (abs(meanSPV)<abs(meanSPVPre) && ((NystSign(idx)==2  || NystSign(idx)==3)))      
            plot(Plot.dTime(Plot.startSPVV_S(idx):Plot.stoppSPVV_S(idx)),Plot.aNystBeatV_S(idx,1:iNbrPoint),'g','linewidth', 3.0); 
            plot(Plot.dTime(Plot.startSPVV_S(idx-1):Plot.stoppSPVV_S(idx-1)),Plot.aNystBeatV_S(idx-1,1:iNbrPointPre),'r','linewidth', 3.0); 

        elseif (abs(meanSPV)>abs(meanSPVPre) && ((NystSign(idx)==2  || NystSign(idx)==3)))
            plot(Plot.dTime(Plot.startSPVV_S(idx):Plot.stoppSPVV_S(idx)),Plot.aNystBeatV_S(idx,1:iNbrPoint),'r','linewidth', 3.0); 
            plot(Plot.dTime(Plot.startSPVV_S(idx-1):Plot.stoppSPVV_S(idx-1)),Plot.aNystBeatV_S(idx-1,1:iNbrPointPre),'g','linewidth', 3.0);             

        end
        szMeanSPVV=sprintf('%3.1f  %3.1fms',meanSPV,dTimeDiff*1e3);       % text of mean SPV of each nystagmus beat
        szMeanSPVPre=sprintf('%3.1f  %3.1fms',meanSPVPre,dTimeDiffPre*1e3);       % text of mean SPV of each nystagmus beat
        h1=text(Plot.dTime(Plot.startSPVV_S(idx)),1.2*Plot.EyePosDeg(Plot.idxZeroCrossV_S(Plot.endSPVV_S(idx)-1)),szMeanSPVV);
        h2=text(Plot.dTime(Plot.startSPVV_S(idx-1)),1.2*Plot.EyePosDeg(Plot.idxZeroCrossV_S(Plot.endSPVH_S(idx-1)-1),2),szMeanSPVVPre);
        set (h1, 'Clipping', 'on');     
        set (h2, 'Clipping', 'on');     
V
     end   


%     text(1,-40.0,sprintf('pos mean SPV = %2.2f [deg/s]    %2.1f [deg/s]    ',meanPartSPV(1,1),meanPartSPV(2,1)));    
%     text(1,-45.0,sprintf('neg mean SPV = %2.2f [deg/s]    %2.1f [deg/s]    ',meanPartSPV(1,2),meanPartSPV(2,2)));    
    grid on;
    
   

err=0;
end
