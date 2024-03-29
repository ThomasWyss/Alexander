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
function [ err ] = plotSPVH_Position(Plot,Out)

    clear meanPartSPV;
    
    figure('Name',['SPVH_Position ', Plot.Text.szPatient,' ',Plot.Text.szSession,' ',Plot.Text.szTest],'Position',[1, 1, 1920,1080]); % Fig 4
    x=linspace(-40,40,100);
    subplot(2,1,1);

    cc=1;
    [~,endIdx]=size(Plot.meanSPVH);
    for jj = 1:endIdx-1
        if (Plot.NystSignH(jj)) %==true && abs(Plot.meanSPVH(jj))>Plot.minSPV...
                %&& Plot.dTime(Plot.startSPVH_S(jj))<Plot.stopRotationTime

             if abs(Plot.SPVDeltaH(jj))<Plot.NystBeatDeltaMax
                if Plot.EyePosDeg(Plot.startSPVH_S(jj),1)>Plot.LRsH
                    plot(Plot.EyePosDeg(Plot.startSPVH_S(jj)),Plot.meanSPVH(jj),'ro','linewidth', 1.2,'MarkerSize',7.0); hold on;
                else
                    plot(Plot.EyePosDeg(Plot.startSPVH_S(jj)),Plot.meanSPVH(jj),'bo','linewidth', 1.2,'MarkerSize',7.0); hold on;
                end
             else
                plot(Plot.EyePosDeg(Plot.startSPVH_S(jj)),Plot.meanSPVH(jj),'co','linewidth', 1.2,'MarkerSize',7.0); hold on;                   
             end
             
             pp(cc,1) = Plot.EyePosDeg(Plot.startSPVH_S(jj));
             pp(cc,2) = Plot.meanSPVH(jj);
             cc=cc+1;
        end
        if Plot.NystSignH(jj)==false           
%            plot(SPV_Pos(jj,1),SPV_Pos(jj,4),'ro','linewidth', 1.2,'MarkerSize',7.0); hold on; 
        end
    end
    
    pm=polyfit(pp(:,1),pp(:,2),1);
    plot(x,pm(1)*x+pm(2),'g','linewidth', 1.2); hold on;
    
    title(['SPVH at Position ', Plot.Text.szPatient,' ',Plot.Text.szSession,' ',Plot.Text.szTest]);
    xlabel('Horizontal Position [\circ]');
    ylabel('SPV [\circ/s]');
    xlim([-40,40]);
    ylim([-Plot.dOutlierBoundary,Plot.dOutlierBoundary]);
    line([0,0],get(gca,'ylim'),'Color',[0.0 0.0 0.0],'LineWidth',1.5);hold on
    line(get(gca,'xlim'),[0,0],'Color',[0.0 0.0 0.0],'LineWidth',1.5);
    tx1=text(-35.0,-10.0,sprintf('Fitted Function Y= %2.1fX + %2.1f all',pm(1),pm(2)));

    tx1.Color=[1.0 0 0];
    tx2.Color='m';
    tx3.Color=[0 0 1.0];
    grid on;
      
    subplot(2,1,2);

    hold on;
    plot(Plot.dTime,Plot.EyePosDeg(:,1),'.' )
    plot(Plot.dTime(Plot.idxZeroCrossH_S),Plot.EyePosDeg(Plot.idxZeroCrossH_S,1),'rd'); % zero crossings!!
    plot(Plot.dTime(Plot.startSPVH_S),Plot.EyePosDeg(Plot.startSPVH_S,1),'ko','linewidth', 1.2,'MarkerSize',10.0);   % start of nystagmus beat
    plot(Plot.dTime(Plot.stoppSPVH_S),Plot.EyePosDeg(Plot.stoppSPVH_S,1),'kx','linewidth', 1.2,'MarkerSize',10.0);   % start of nystagmus beat

    
    for idx = 2:endIdx-1                       % plot the position in deg   

        if Plot.NystSignH(idx)==true % && abs(SPV_Pos(jj,4))>Plot.minSPV 
            if Plot.SPVDeltaH(idx)<Plot.NystBeatDeltaMax
                if Plot.EyePosDeg(Plot.startSPVH_S(idx),1)>Plot.LRsH
                    plot(Plot.dTime(Plot.startSPVH_S(idx):Plot.stoppSPVH_S(idx)),Plot.aNystBeatH_S(idx,1:Plot.iNbrPointH(idx)),'r','linewidth', 3.0); 
                else
                    plot(Plot.dTime(Plot.startSPVH_S(idx):Plot.stoppSPVH_S(idx)),Plot.aNystBeatH_S(idx,1:Plot.iNbrPointH(idx)),'b','linewidth', 3.0); 
                end
            else
                plot(Plot.dTime(Plot.startSPVH_S(idx):Plot.stoppSPVH_S(idx)),Plot.aNystBeatH_S(idx,1:Plot.iNbrPointH(idx)),'c','linewidth', 3.0); 
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
    title(['Horizontal Position ', Plot.Text.szPatient,' ',Plot.Text.szSession,' ',Plot.Text.szTest]);
    ylabel('Position [\circ]');
    legend('Eye Pos. H','Zero Crossing H','Begin H','End H','Nystagmus Beat H,','ABC');
    ylim([-50,40]);

    szSaveName =['..\Data\Pictures\',Plot.Text.szPatient,' ',Plot.Text.szTest,'_SPVH_Pos.jpg'];%,'Nystagmus_PosData',szPicFile,'.jpg'];
    saveas(gcf,szSaveName);
    szSaveName =['..\Data\Figures\',Plot.Text.szPatient,' ',Plot.Text.szTest,'_SPVH_Pos.fig'];%,'Nystagmus_PosData',szPicFile,'.jpg'];
    saveas(gcf,szSaveName);

    return
end
