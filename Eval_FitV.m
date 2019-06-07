function [outPlot, outPlotL, outPlotR ] = Eval_FitV( Local, idxStart, idxStop, pre)

    iDataIdxR=1;
    iDataIdxL=1;
    clear RightV LeftV;
    % --- reset the NystSignV before start of rotation ---    
    for ii=1:idxStart-1
         Local.NystSignV(ii)=false;
    end
    % --- determine up down direction of V nystagmus       
    if Local.HeadMovVect(5000)>180
        rotDir=1;
    else
        rotDir=-1;
    end        

    for idx = idxStart:2:idxStop-1                                       % plot the position in deg   

        NystSign=0;
        % --- determine factors to calculate a meanSPV
        dTimeDiff=      Local.dTime(Local.stoppSPVV_S(idx))-Local.dTime(Local.startSPVV_S(idx));
        dTimeDiffPre=   Local.dTime(Local.stoppSPVV_S(idx-1))-Local.dTime(Local.startSPVV_S(idx-1));        
        SPVDiff=        Local.EyePosDeg(Local.stoppSPVV_S(idx),2)-Local.EyePosDeg(Local.startSPVV_S(idx),2);
        SPVDiffPre=     Local.EyePosDeg(Local.stoppSPVV_S(idx-1),2)-Local.EyePosDeg(Local.startSPVV_S(idx-1),2);
        meanSPV=        SPVDiff/dTimeDiff;
        meanSPV=        Local.meanSPVV(idx);
        meanSPVPre=     SPVDiffPre/dTimeDiffPre;

        if (meanSPVPre>0 && meanSPV>0) NystSign=1;   end
        if (meanSPVPre>0 && meanSPV<0) NystSign=2;   end
        if (meanSPVPre<0 && meanSPV>0) NystSign=3;   end
        if (meanSPVPre<0 && meanSPV<0) NystSign=4;   end
        
         if pre 
             startTime=Local.startRotationTime;
             endTime= Local.stopRotationTime;
         else
             startTime=Local.stopRotationTime;
             endTime= Local.endRotationTime;
         end
         
         if (abs(meanSPV)<abs(meanSPVPre) && ((NystSign==2  || NystSign==3)))...
                && Local.SPVDeltaV(idx)<Local.NystBeatDeltaMax && abs(Local.meanSPVV(idx))<Local.minSPV...
                && Local.dTime(Local.startSPVV_S(idx))<endTime

            Local.NystSignV(idx-1)=false;            
         end
         
         if (abs(meanSPV)>abs(meanSPVPre) && ((NystSign==2  || NystSign==3)))...
                && Local.SPVDeltaV(idx-1)<Local.NystBeatDeltaMax  && abs(Local.meanSPVV(idx-1))>Local.minSPV...
                && Local.dTime(Local.startSPVV_S(idx))<endTime && abs(Local.meanSPVV(idx-1))>Local.dSaccSPVsep
            Local.NystSignV(idx-1)=false;
%             Local.NystSignV(idx-1)=true;
            % eyey gaze to ....
        end
        
        if  Local.dTime(Local.stoppSPVV_S(idx))> endTime+20 && abs(Local.meanSPVV(idx))>Local.minSPV
            Local.NystSignV(idx)=false;
        end
        if  Local.dTime(Local.stoppSPVV_S(idx))> startTime+20 && abs(Local.meanSPVV(idx))>Local.minSPV
            Local.NystSignV(idx)=false;
        end
        
        if abs(Local.meanSPVV(idx))>Local.dSaccSPVsep
            Local.NystSignV(idx)=false;
        end
        if abs(Local.meanSPVV(idx-1))>Local.dSaccSPVsep
            Local.NystSignV(idx-1)=false;
        end
        % --- if chair rot right all negative prerot SPV are invalid ---
        if rotDir==1 && pre && meanSPV<0
            Local.NystSignV(idx)=false;            
        end
        
        if rotDir==1 && pre && meanSPVPre<0
            Local.NystSignV(idx-1)=false;
        end
        % --- if chair rot right all negative prerot SPV are invalid ---
        if rotDir==1 && ~pre && meanSPV>0
            Local.NystSignV(idx)=false;
        end
        
        if rotDir==1 && ~pre && meanSPVPre>0
            Local.NystSignV(idx-1)=false;
        end
        
        % --- if chair rot right all negative prerot SPV are invalid ---
        if rotDir==-1 && pre && meanSPV<0
            Local.NystSignV(idx)=false;
        end
        if rotDir==-1 && pre && meanSPVPre<0
            Local.NystSignV(idx-1)=false;
        end
        % --- if chair rot right all negative prerot SPV are invalid ---
        if rotDir==-1 && ~pre && meanSPV>0
            Local.NystSignV(idx)=false;
        end
        if rotDir==-1 && ~pre && meanSPVPre>0
             Local.NystSignV(idx-1)=false;
        end
        
        % error that two Nystagmus beats directly follow each other => deactivate both 
        if idx>2 && Local.NystSignV(idx-2) && Local.NystSignV(idx-1) && Local.SPVDeltaV(idx)<10.0
            Local.NystSignV(idx-2)=false;
            Local.NystSignV(idx-1)=false;          
        end
        
        if Local.NystSignV(idx)
            
             if Local.EyePosDeg(Local.startSPVV_S(idx),1)> Local.LRsV
                RightV.dTime(iDataIdxR) = Local.dTime(Local.startSPVV_S(idx));
                RightV.SPV(iDataIdxR) = meanSPV;
                RightV.Pos(iDataIdxR) = Local.EyePosDeg(Local.startSPVV_S(idx),1);
                RightV.idx(iDataIdxR) = idx;
                iDataIdxR=iDataIdxR+1;
            else
                LeftV.dTime(iDataIdxL)=Local.dTime(Local.startSPVV_S(idx));
                LeftV.SPV(iDataIdxL)=meanSPV;
                LeftV.Pos(iDataIdxL)=Local.EyePosDeg(Local.startSPVV_S(idx),1);
                LeftV.idx(iDataIdxL)=idx;
                iDataIdxL=iDataIdxL+1;
             end    
        end
        
        if Local.NystSignV(idx-1)
            
             if Local.EyePosDeg(Local.startSPVV_S(idx-1),1)> Local.LRsV
                RightV.dTime(iDataIdxR)=Local.dTime(Local.startSPVV_S(idx-1));
                RightV.SPV(iDataIdxR)=meanSPVPre;
                RightV.Pos(iDataIdxR)=Local.EyePosDeg(Local.startSPVV_S(idx-1),1);
                RightV.idx(iDataIdxR)=idx-1;
                iDataIdxR=iDataIdxR+1;
            else% eye gaze to the other side ;)
                LeftV.dTime(iDataIdxL)=Local.dTime(Local.startSPVV_S(idx-1));
                LeftV.SPV(iDataIdxL)=meanSPVPre;
                LeftV.Pos(iDataIdxL)=Local.EyePosDeg(Local.startSPVV_S(idx-1),1);
                LeftV.idx(iDataIdxL)=idx-1;
                iDataIdxL=iDataIdxL+1;
             end           
        end        
    end
   
    outPlot=Local;
    outPlotL=LeftV;
    outPlotR=RightV;
end