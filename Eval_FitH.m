function [outPlot, outPlotL, outPlotR ] = Eval_FitH( Local, idxStart, idxStop, pre)

    iDataIdxR=1;
    iDataIdxL=1;
    clear RightH LeftH;
    % --- reset the NystSignH before start of rotation ---    
    for ii=1:idxStart-1
         Local.NystSignH(ii)=false;
    end
           
    if Local.HeadMovVect(5000)>180
        rotDir=1;
    else
        rotDir=-1;
    end

    for idx = idxStart:2:idxStop-1                                      

        NystSign=0;
        % --- determine factors to calculate a meanSPV
        dTimeDiff=      Local.dTime(Local.stoppSPVH_S(idx))-Local.dTime(Local.startSPVH_S(idx));
        dTimeDiffPre=   Local.dTime(Local.stoppSPVH_S(idx-1))-Local.dTime(Local.startSPVH_S(idx-1));        
        SPVDiff=        Local.EyePosDeg(Local.stoppSPVH_S(idx),1)-Local.EyePosDeg(Local.startSPVH_S(idx),1);
        SPVDiffPre=     Local.EyePosDeg(Local.stoppSPVH_S(idx-1),1)-Local.EyePosDeg(Local.startSPVH_S(idx-1),1);
        meanSPV=        SPVDiff/dTimeDiff;
        meanSPV=        Local.meanSPVH(idx);
        meanSPVPre=     SPVDiffPre/dTimeDiffPre;
        % --- classify the NystSign ---
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
                && Local.SPVDeltaH(idx)<Local.NystBeatDeltaMax && abs(Local.meanSPVH(idx))>Local.minSPV...
                && Local.dTime(Local.startSPVH_S(idx))<endTime
%             Local.NystSignH(idx)=true;
            Local.NystSignH(idx-1)=false;            
        end
        
        if (abs(meanSPV)>abs(meanSPVPre) && ((NystSign==2  || NystSign==3)))...
                && Local.SPVDeltaH(idx-1)<Local.NystBeatDeltaMax  && abs(Local.meanSPVH(idx-1))>Local.minSPV...
                && Local.dTime(Local.startSPVH_S(idx))<endTime && abs(Local.meanSPVH(idx-1))>Local.dSaccSPVsep
            Local.NystSignH(idx-1)=false;
%             Local.NystSignH(idx-1)=true;
            % eyey gaze to ....
        end
        
        if  Local.dTime(Local.stoppSPVH_S(idx))> endTime+20 && abs(Local.meanSPVH(idx))>Local.minSPV
            Local.NystSignH(idx)=false;
        end
        if  Local.dTime(Local.stoppSPVH_S(idx))> startTime+20 && abs(Local.meanSPVH(idx))>Local.minSPV
            Local.NystSignH(idx)=false;
        end
        
        if abs(Local.meanSPVH(idx))>Local.dSaccSPVsep
            Local.NystSignH(idx)=false;
        end
        if abs(Local.meanSPVH(idx-1))>Local.dSaccSPVsep
            Local.NystSignH(idx-1)=false;
        end
        % --- if chair rot right all negative prerot SPV are invalid ---
        if rotDir==1 && pre && meanSPV<0
            Local.NystSignH(idx)=false;            
        end
        
        if rotDir==1 && pre && meanSPVPre<0
            Local.NystSignH(idx-1)=false;
        end
        % --- if chair rot right all negative prerot SPV are invalid ---
        if rotDir==1 && ~pre && meanSPV>0
            Local.NystSignH(idx)=false;
        end
        
        if rotDir==1 && ~pre && meanSPVPre>0
            Local.NystSignH(idx-1)=false;
        end
        
        % --- if chair rot right all negative prerot SPV are invalid ---
        if rotDir==-1 && pre && meanSPV<0
            Local.NystSignH(idx)=false;
        end
        if rotDir==-1 && pre && meanSPVPre<0
            Local.NystSignH(idx-1)=false;
        end
        % --- if chair rot right all negative prerot SPV are invalid ---
        if rotDir==-1 && ~pre && meanSPV>0
            Local.NystSignH(idx)=false;
        end
        if rotDir==-1 && ~pre && meanSPVPre>0
             Local.NystSignH(idx-1)=false;
        end
        
        % error that two Nystagmus beats directly follow each other => deactivate both 
        if idx>2 && Local.NystSignH(idx-2) && Local.NystSignH(idx-1) && Local.SPVDeltaH(idx)<10.0
            Local.NystSignH(idx-2)=false;
            Local.NystSignH(idx-1)=false;          
        end
        
        if Local.NystSignH(idx)
            
             if Local.EyePosDeg(Local.startSPVH_S(idx),1)> Local.LRsH
                RightH.dTime(iDataIdxR) = Local.dTime(Local.startSPVH_S(idx));
                RightH.SPV(iDataIdxR) = meanSPV;
                RightH.Pos(iDataIdxR) = Local.EyePosDeg(Local.startSPVH_S(idx),1);
                RightH.idx(iDataIdxR) = idx;
                iDataIdxR=iDataIdxR+1;
            else
                LeftH.dTime(iDataIdxL)=Local.dTime(Local.startSPVH_S(idx));
                LeftH.SPV(iDataIdxL)=meanSPV;
                LeftH.Pos(iDataIdxL)=Local.EyePosDeg(Local.startSPVH_S(idx),1);
                LeftH.idx(iDataIdxL)=idx;
                iDataIdxL=iDataIdxL+1;
             end    
        end
        
        if Local.NystSignH(idx-1)
            
             if Local.EyePosDeg(Local.startSPVH_S(idx-1),1)> Local.LRsH
                RightH.dTime(iDataIdxR)=Local.dTime(Local.startSPVH_S(idx-1));
                RightH.SPV(iDataIdxR)=meanSPVPre;
                RightH.Pos(iDataIdxR)=Local.EyePosDeg(Local.startSPVH_S(idx-1),1);
                RightH.idx(iDataIdxR)=idx-1;
                iDataIdxR=iDataIdxR+1;
            else% eye gaze to the other side ;)
                LeftH.dTime(iDataIdxL)=Local.dTime(Local.startSPVH_S(idx-1));
                LeftH.SPV(iDataIdxL)=meanSPVPre;
                LeftH.Pos(iDataIdxL)=Local.EyePosDeg(Local.startSPVH_S(idx-1),1);
                LeftH.idx(iDataIdxL)=idx-1;
                iDataIdxL=iDataIdxL+1;
             end           
        end        
    end
    
    outPlot=Local;
    outPlotL=LeftH;
    outPlotR=RightH;
end