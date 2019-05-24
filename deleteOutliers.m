function [ outPlot ] = deleteOutliers( Local )


    % --- determmine idx of outlier sample (NystSignH==false) ---
    szFileNameOutlier=['..\Data\Outliers\',Local.Text.szPatient,'_Outlier_RH.mat'];
    load(szFileNameOutlier);
      
    
    % determmine idx of invalid sample (NystSignH==false)
    saveCountL=1;
    saveIdxL(1)=1;
    [~, idxEnd]=size(Local.LeftH.idx)
    for idx = 1:idxEnd-1                             % plot the position in deg   
        if ~Local.NystSignH(Local.LeftH.idx(idx))
            saveIdxL(saveCountL)=idx;
            % delete the Plot.Left.xx and PlotRight.xx
            saveCountL=saveCountL+1;
        end              
    end
%     aAllOutlierL=saveIdxL+uOutlierRH;
    
    % determmine idx of invalid sample (NystSignH==false)
    saveCountR=1;
    saveIdxR(1)=1
    [~, idxEnd]=size(Local.RightH.idx)
    for idx = 1:idxEnd-1                               
        if ~Local.NystSignH(Local.RightH.idx(idx))
            saveIdxR(saveCountR)=idx;
            % delete the Plot.Left.xx and PlotRight.xx
            saveCountR=saveCountR+1;
        end              
    end
    clear aAllOutlierRH;
    aAllOutlierRH=unique([saveIdxR, uOutlierRH(:,1)']);



    % --- remove invalid sample L ---  
    [~, idxEnd]=size(saveIdxL)
    for idx = idxEnd:-1:1
        Local.LeftH.idx(saveIdxL(idx)) =[]; 
        Local.LeftH.SPV(saveIdxL(idx)) =[];
        Local.LeftH.Pos(saveIdxL(idx)) =[];
        Local.LeftH.dTime(saveIdxL(idx)) =[];
    end
        
    % --- remove invalid sample R ---   
    [~, idxEnd]=size(aAllOutlierRH)
    for idx = idxEnd:-1:1
        Local.RightH.idx(aAllOutlierRH(idx)) =[]; 
        Local.RightH.SPV(aAllOutlierRH(idx)) =[];
        Local.RightH.Pos(aAllOutlierRH(idx)) =[];
        Local.RightH.dTime(aAllOutlierRH(idx)) =[];
    end

    outPlot=Local;

end