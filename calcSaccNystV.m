function [ outPlot ] = calcSaccNystV(Plot)


    idxStart=1;
    while Plot.startSPVV_S(idxStart)<Plot.idxStartRotTime
        idxStart=idxStart+1;
    end
    
    [idxStop, ~] = size(Plot.startSPVH_S);
    while Plot.startSPVV_S(idxStop)>Plot.idxEndRotTime
        idxStop=idxStop-1;
    end
    [idxEnd,~]=size(Plot.stoppSPVV_S);
    startRotationTime=Plot.headInertialTime(Plot.stoppSPVV_S(idxStart));
    stopRotationTime=Plot.headInertialTime(Plot.stoppSPVV_S(idxStop));
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

    [Plot, PreRotL , PreRotR]= Eval_FitV(Plot, idxStart, idxStop, 'pre');
    [Plot, PostRotL , PostRotR] =Eval_FitV(Plot, idxStop, idxEnd, 'post');
    Plot.LRsV=median([PreRotL.Pos,PreRotR.Pos,PostRotL.Pos,PostRotR.Pos]);
    [Plot, PreRotL , PreRotR]= Eval_FitV(Plot, idxStart, idxStop, 'pre');
    Plot.PreRotVL=PreRotL;
    Plot.PreRotVR=PreRotR;
    
    % --- send end time
    Plot.LRsV=mean([PostRotL.Pos,PostRotR.Pos]);
    [Plot, PostRotL , PostRotR] =Eval_FitV(Plot, idxStop, idxEnd, 'post');
    Plot.PostRotVL=PostRotL;
    Plot.PostRotVR=PostRotR;
    Plot.endRotationTime=endRotationTime;

    outPlot=Plot;     
        
end