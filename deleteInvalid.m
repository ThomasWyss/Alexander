function [ outPlot ] = deleteInvalid( Local )


%     % --- determmine idx of outlier sample (NystSignH==false) ---
%     szFileNameOutlier=['..\Data\Outliers\',Local.Text.szPatient,'_Outlier_RH.mat'];
%     load(szFileNameOutlier);
      
%     xyz(1,1:2000)=Local.NystSignH(1:2000)
%     bla=Local.meanSPVH';
%     xyz(2,1:2000)=bla(1:2000)
    
    % determmine idx of invalid sample (NystSignH==false) prerot Left
    saveCountPreL=1;
    saveIdxPreL(1)=1;
    [~, idxEnd]=size(Local.PreRotHL.idx)
    for idx = 1:idxEnd                             
        if ~Local.NystSignH(Local.PreRotHL.idx(idx))
            saveIdxPreL(saveCountPreL)=idx;
            % delete the Plot.Left.xx and PlotRight.xx
            saveCountPreL=saveCountPreL+1;
        end              
    end
    % determmine idx of invalid sample (NystSignH==false) prerot Right
    saveCountPreR=1;
    saveIdxPreR(1)=1;
    [~, idxEnd]=size(Local.PreRotHR.idx)
    for idx = 1:idxEnd-1                              
        if ~Local.NystSignH(Local.PreRotHR.idx(idx))
            saveIdxPreR(saveCountPreR)=idx;
            % delete the Plot.Left.xx and PlotRight.xx
            saveCountPreR=saveCountPreR+1;
        end              
    end
    
    % determmine idx of invalid sample (NystSignH==false)
    saveCountPostR=1;
    saveIdxPostR(1)=1;
    [~, idxEnd]=size(Local.PostRotHR.idx)
    for idx = 1:idxEnd-1                               
        if ~Local.NystSignH(Local.PostRotHR.idx(idx))
            saveIdxPostR(saveCountPostR)=idx;
            % delete the Plot.Left.xx and PlotRight.xx
            saveCountPostR=saveCountPostR+1;
        end              
    end
    % determmine idx of invalid sample (NystSignH==false)
    saveCountPostL=1;
    saveIdxPostL(1)=1;
    [~, idxEnd]=size(Local.PostRotHL.idx)
    for idx = 1:idxEnd-1                               
        if ~Local.NystSignH(Local.PostRotHL.idx(idx))
            saveIdxPostL(saveCountPostL)=idx;
            % delete the Plot.Left.xx and PlotRight.xx
            saveCountPostL=saveCountPostL+1;
        end              
    end
    
%     clear aAllOutlierRH;
%     aAllOutlierRH=unique([saveIdxR, uOutlierRH(:,1)']);

    % --- remove invalid sample L ---  
    [~, idxEnd]=size(saveIdxPreL)
    for idx = idxEnd:-1:1
        Local.PreRotHL.idx(saveIdxPreL(idx)) =[]; 
        Local.PreRotHL.SPV(saveIdxPreL(idx)) =[];
        Local.PreRotHL.Pos(saveIdxPreL(idx)) =[];
        Local.PreRotHL.dTime(saveIdxPreL(idx)) =[];
    end
    % --- remove invalid sample L ---  
    [~, idxEnd]=size(saveIdxPreR)
    for idx = idxEnd:-1:1
        Local.PreRotHR.idx(saveIdxPreR(idx)) =[]; 
        Local.PreRotHR.SPV(saveIdxPreR(idx)) =[];
        Local.PreRotHR.Pos(saveIdxPreR(idx)) =[];
        Local.PreRotHR.dTime(saveIdxPreR(idx)) =[];
    end
    [~, idxEnd]=size(saveIdxPostL)
    for idx = idxEnd:-1:1
        Local.PostRotHL.idx(saveIdxPostL(idx)) =[]; 
        Local.PostRotHL.SPV(saveIdxPostL(idx)) =[];
        Local.PostRotHL.Pos(saveIdxPostL(idx)) =[];
        Local.PostRotHL.dTime(saveIdxPostL(idx)) =[];
    end
    [~, idxEnd]=size(saveIdxPostR)
    for idx = idxEnd:-1:1
        Local.PostRotHR.idx(saveIdxPostR(idx)) =[]; 
        Local.PostRotHR.SPV(saveIdxPostR(idx)) =[];
        Local.PostRotHR.Pos(saveIdxPostR(idx)) =[];
        Local.PostRotHR.dTime(saveIdxPostR(idx)) =[];
    end
        
%     % --- remove invalid sample R ---   
%     [~, idxEnd]=size(aAllOutlierRH)
%     for idx = idxEnd:-1:1
%         Local.RightH.idx(aAllOutlierRH(idx)) =[]; 
%         Local.RightH.SPV(aAllOutlierRH(idx)) =[];
%         Local.RightH.Pos(aAllOutlierRH(idx)) =[];
%         Local.RightH.dTime(aAllOutlierRH(idx)) =[];
%     end

    outPlot=Local;

end