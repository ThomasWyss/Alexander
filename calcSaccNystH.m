function [ outPlot ] = calcSaccNystH(Plot)


    idxStart=1;
    while Plot.startSPVH_S(idxStart)<Plot.idxStartRotTime
        idxStart=idxStart+1;
    end
    
    [idxStop, ~] = size(Plot.startSPVH_S);
    while Plot.startSPVH_S(idxStop)>Plot.idxEndRotTime
        idxStop=idxStop-1;
    end
    [idxEnd,~]=size(Plot.stoppSPVH_S);
    startRotationTime=Plot.headInertialTime(Plot.stoppSPVH_S(idxStart));
    stopRotationTime=Plot.headInertialTime(Plot.stoppSPVH_S(idxStop));
    endRotationTime=Plot.headInertialTime(end);
    Plot.endRotationTime=endRotationTime;    
    Plot.startRotationTime=startRotationTime;    
    Plot.stopRotationTime=stopRotationTime;    
 %-------------------------------------------------------------------------   
 %  seperate Left & Right gaze pre rotatorical nystagmus
 %  differentiate nystagmus & saccades
 %  dTimeDiff time length of nystagmus beat
 %  dTimeDiffPre time length of previous nystagmus beat 
 %-------------------------------------------------------------------------   
    
 %--- Eval_Fit is called twice : workaround to get mean position
    [Plot, PreRotL , PreRotR]= Eval_Fit(Plot, idxStart, idxStop,true);
    [Plot, PostRotL , PostRotR] =Eval_Fit(Plot, idxStop, idxEnd, false);
    Plot.LRsH=mean([PreRotL.Pos,PreRotR.Pos,PostRotL.Pos,PostRotR.Pos]);
    
    [iTmp,~]=size(Plot.endSPVH_S(:,1));
    NystSignH=ones(iTmp,1);
    Plot.NystSignH=NystSignH;   
    
    [Plot, PreRotL , PreRotR]= Eval_Fit(Plot, idxStart, idxStop, true);
    Plot.PreRotHL=PreRotL;
    Plot.PreRotHR=PreRotR;
    
    [Plot, PostRotL , PostRotR] =Eval_Fit(Plot, idxStop, idxEnd, false);
    Plot.PostRotHL=PostRotL;
    Plot.PostRotHR=PostRotR;
    
    % --- determine mean position of all pre/post
    Plot.meanPosHLpre=  mean(PreRotL.Pos);    
    Plot.meanPosHRpre=  mean(PreRotR.Pos);  
    Plot.meanPosHLpost=  mean(PostRotL.Pos);    
    Plot.meanPosHRpost=  mean(PostRotR.Pos);  
    
    outPlot=Plot;    
end