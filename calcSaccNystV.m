function [ outPlot ] = calcSaccNystV(Plot)


    for jj=30:size(Plot.HeadMovVect)
        if Plot.HeadMovVect(jj) >190
            Plot.startRotationIdx=jj;
            Plot.startRotationTime=Plot.headInertialTime(jj);
            aaa=Plot.startSPVV_S(Plot.startSPVV_S>Plot.startRotationIdx);
            break
        end
    end
    
    [jjEnd, ~] = size(Plot.HeadMovVect);
    if jjEnd>=24000.0
        jjEnd=24000.0;
    end  
    for jj=jjEnd:-1:30
        if Plot.HeadMovVect(jj) >190
            Plot.stopRotationIdx=jj;
            Plot.stopRotationTime=Plot.headInertialTime(jj);
            bbb=Plot.stoppSPVV_S(Plot.stoppSPVV_S>Plot.stopRotationIdx);
            break
        end
    end
    % --- find idx of SPVH_S for time idx
    idxStart=find  (Plot.startSPVV_S==aaa(1));
    idxStop=find  (Plot.stoppSPVV_S==bbb(1));
    [idxEnd,~]=size(Plot.stoppSPVV_S);
    endRotationTime=Plot.headInertialTime(end);
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