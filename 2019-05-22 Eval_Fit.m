function [outPlot, outPlotL, outPlotR ] = Eval_Fit( Local, idxStart, idxStop, pre)

    iDataIdxR=1;
    iDataIdxL=1;
    clear RightH LeftH;
    
    endRotTime=Local.headInertialTime(Local.stoppSPVH_S(idxStop));
    if Local.HeadMovVect(5000)>180
        rotDir=1;
    else
        rotDir=-1;
    end

    for idx = idxStart:2:idxStop-1                                      
        if idx==185
            asb=0;
            Local.NystSignH(idx)
        end
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
        
        if (abs(meanSPV)<abs(meanSPVPre) && ((NystSign==2  || NystSign==3)))...
                && Local.SPVDeltaH(idx)<Local.NystBeatDeltaMax && abs(Local.meanSPVH(idx))>Local.minSPV...
                && Local.dTime(Local.startSPVH_S(idx))<endRotTime
            Local.NystSignH(idx)=true;
%             Local.NystSignH(idx-1)=false;
            
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
        
        if (abs(meanSPV)>abs(meanSPVPre) && ((NystSign==2  || NystSign==3)))...
                && Local.SPVDeltaH(idx-1)<Local.NystBeatDeltaMax  && abs(Local.meanSPVH(idx-1))>Local.minSPV...
                && Local.dTime(Local.startSPVH_S(idx))<endRotTime
%             Local.NystSignH(idx)=false;
            Local.NystSignH(idx-1)=true;
            % eyey gaze to ....
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
        % error that two Nystagmus beats directly follow each other => deactivate both 
        if idx>2 && Local.NystSignH(idx-2) && Local.NystSignH(idx-1) && Local.SPVDeltaH(idx)<10.0
            Local.NystSignH(idx-2)=false;
            Local.NystSignH(idx-1)=false;          
        end
        % --- if chair rot right all negative prerot SPV are invalid ---
        if rotDir==1 && pre && meanSPV>0
            Local.NystSignH(idx)=true;
        end
        if rotDir==1 && pre && meanSPVPre>0
            Local.NystSignH(idx-1)=true;
        end
        % --- if chair rot right all negative prerot SPV are invalid ---
        if rotDir==1 && ~pre && meanSPV<0
            Local.NystSignH(idx)=true;
        end
        if rotDir==1 && ~pre && meanSPVPre<0
            Local.NystSignH(idx-1)=true;
        end
        % --- if chair rot right all negative prerot SPV are invalid ---
        if rotDir==-1 && pre && meanSPV>0
            Local.NystSignH(idx)=true;
        end
        if rotDir==-1 && pre && meanSPVPre>0
            Local.NystSignH(idx-1)=true;
        end
        % --- if chair rot right all negative prerot SPV are invalid ---
        if rotDir==-1 && ~pre && meanSPV<0
            Local.NystSignH(idx)=true;
        end
        if rotDir==-1 && ~pre && meanSPVPre<0
            Local.NystSignH(idx-1)=true;
        end
        
        if Local.NystSignH(idx)
        
        end
        
    end
    
    ss=Local.NystSignH(185)
    outPlot=Local;
    outPlotL=LeftH;
    outPlotR=RightH;
end