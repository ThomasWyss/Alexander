function [outPlot, outPlotL, outPlotR ] = Eval_FitV( Local, idxStart, idxStop, prepost)

    iDataIdxR=1;
    iDataIdxL=1;
        
    endRotTime=Local.headInertialTime(Local.stoppSPVV_S(idxStop));

    for idx = idxStart:2:idxStop-1                                       % plot the position in deg   
        NystSign=0;
        % --- determine factors to calculate a meanSPV
        dTimeDiff=      Local.dTime(Local.stoppSPVV_S(idx))-Local.dTime(Local.startSPVV_S(idx));
        dTimeDiffPre=   Local.dTime(Local.stoppSPVV_S(idx-1))-Local.dTime(Local.startSPVV_S(idx-1));        
        SPVDiff=        Local.EyePosDeg(Local.stoppSPVV_S(idx),2)-Local.EyePosDeg(Local.startSPVV_S(idx),2);
        SPVDiffPre=     Local.EyePosDeg(Local.stoppSPVV_S(idx-1),2)-Local.EyePosDeg(Local.startSPVV_S(idx-1),2);
        meanSPV=        SPVDiff/dTimeDiff;
        meanSPVPre=     SPVDiffPre/dTimeDiffPre;

        if (meanSPVPre>0 && meanSPV>0) NystSign=1;   end
        if (meanSPVPre>0 && meanSPV<0) NystSign=2;   end
        if (meanSPVPre<0 && meanSPV>0) NystSign=3;   end
        if (meanSPVPre<0 && meanSPV<0) NystSign=4;   end
        
        if (abs(meanSPV)<abs(meanSPVPre) && ((NystSign==2  || NystSign==3)))...
                && Local.SPVDeltaV(idx)<Local.NystBeatDeltaMax && abs(Local.meanSPVV(idx))>Local.minSPV...
                && Local.dTime(Local.startSPVV_S(idx))<endRotTime
            Local.NystSignV(idx)=true;
            Local.NystSignV(idx-1)=false;
            
            if Local.EyePosDeg(Local.startSPVV_S(idx),2)> Local.LRsV
                Local.RightV.dTime(iDataIdxR)= Local.dTime(Local.startSPVV_S(idx))
                Local.RightV.SPV(iDataIdxR)=   meanSPV;
                Local.RightV.Pos(iDataIdxR) =  Local.EyePosDeg(Local.startSPVV_S(idx),2);
                Local.RightV.idx(iDataIdxR)=idx;
                iDataIdxR=iDataIdxR+1;
            else
                Local.LeftV.dTime(iDataIdxL)=Local.dTime(Local.startSPVV_S(idx));
                Local.LeftV.SPV(iDataIdxL)=meanSPV;
                Local.LeftV.Pos(iDataIdxL)=Local.EyePosDeg(Local.startSPVV_S(idx),2);
                Local.LeftV.idx(iDataIdxL)=idx;
                iDataIdxL=iDataIdxL+1;
            end            
        end
        
        if (abs(meanSPV)>abs(meanSPVPre) && ((NystSign==2  || NystSign==3)))...
                && Local.SPVDeltaV(idx-1)<Local.NystBeatDeltaMax  && abs(Local.meanSPVV(idx-1))>Local.minSPV...
                && Local.dTime(Local.startSPVV_S(idx))<endRotTime
            Local.NystSignV(idx)=false;
            Local.NystSignV(idx-1)=true;
            
            if Local.EyePosDeg(Local.startSPVV_S(idx-1),2)> Local.LRsV
                Local.RightV.dTime(iDataIdxR)=Local.dTime(Local.startSPVV_S(idx-1));
                Local.RightV.SPV(iDataIdxR)=meanSPVPre;
                Local.RightV.Pos(iDataIdxR)=Local.EyePosDeg(Local.startSPVV_S(idx-1),2);
                Local.RightV.idx(iDataIdxR)=idx-1;
                iDataIdxR=iDataIdxR+1;
            else
                Local.LeftV.dTime(iDataIdxL)=Local.dTime(Local.startSPVV_S(idx-1));
                Local.LeftV.SPV(iDataIdxL)=meanSPVPre;
                Local.LeftV.Pos(iDataIdxL)=Local.EyePosDeg(Local.startSPVV_S(idx-1),2);
                Local.LeftV.idx(iDataIdxL)=idx-1;
                iDataIdxL=iDataIdxL+1;
            end
        end
        % error that two Nystagmus beats directly follow each other => deactivate both 
        if idx>2 && Local.NystSignV(idx-2) && Local.NystSignV(idx-1) && Local.SPVDeltaV(idx)<10.0
            Local.NystSignV(idx-2)=false;
            Local.NystSignV(idx-1)=false;          
        end
    end 
    % determmine idx of invalid sample (NystSignV==false)
    saveCountL=1;
    saveIdxL(1)=1;
    for idx = 1:size(Local.LeftV.idx)-1                
        if ~Local.NystSignV(Local.LeftV.idx(idx))
            saveIdxL(saveCountL)=idx;
            % delete the Plot.Left.xx and PlotRight.xx
            saveCountL=saveCountL+1;
        end              
    end
    % determmine idx of invalid sample (NystSignV==false)
    saveCountR=1;
    saveIdxR(1)=1
    for idx = 1:size(Local.RightV.idx)-1                               
        if ~Local.NystSignV(Local.RightV.idx(idx))
            saveIdxR(saveCountR)=idx;
            % delete the Plot.Left.xx and PlotRight.xx
            saveCountR=saveCountR+1;
        end              
    end
       
    for idx=size(saveIdxL):-1:1
        Local.LeftV.idx(saveIdxL(idx)) =[]; 
        Local.LeftV.SPV(saveIdxL(idx)) =[];
        Local.LeftV.Pos(saveIdxL(idx)) =[];
        Local.LeftV.dTime(saveIdxL(idx)) =[];
    end
        
    for idx=size(saveIdxR):-1:1
        Local.RightV.idx(saveIdxR(idx)) =[]; 
        Local.RightV.SPV(saveIdxR(idx)) =[];
        Local.RightV.Pos(saveIdxR(idx)) =[];
        Local.RightV.dTime(saveIdxR(idx)) =[];
    end
    
    outPlot=Local;
    outPlotL=Local.LeftV;
    outPlotR=Local.RightV;
end