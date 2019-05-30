% ------------------------------------------------------------------------
%   Evaluate nystagmus data recorded with Rotation Chair                 #
%                                                                        #
%                                                                        #
%   Date:   22.06.2018 wyt                                               #
% ------------------------------------------------------------------------
% Data: 1 = Time                                                         #
%       2 = Left Eye horizontal                                          #
%       3 = Right Eye horizontal                                         #
%       4 = Left Eye vertical                                            #
%       5 = Right Eye vertical                                           #
%       6 = Chair Rotation Speed                                         #
% ------------------------------------------------------------------------

% selectdata
% clear all; 
clearvars;
close all;

bPlotAll = true;
bShowErrorMessage=false;
iNbrZeroCrossIndex=4.0;
dOutlierBoundary=220.0;

dSampleRate=220;        % Abtastrate EyeCam = 200 Hz

iWindow=5;              % windowbreite der Faltung Smooth Mittelwert
aWindow=ones(iWindow,1);
iWinF=floor(iWindow/2);
%minDauerSPV=0.05;       % minimale Dauer von SlowPhaseVelocity [s]
minDauerSPVVsmpl=5;      % minimale Dauer von SlowPhaseVelocity [samples] 
minDauerSPVHsmpl=5;      % minimale Dauer von SlowPhaseVelocity [samples] 
maxDauerSPVsmpl = 100;
minNystSPV = 7.0;

startShiftH=1;        % shift startpoint of nystagmus beat relative to
startShiftV=1; 
stopShiftH=-1;
stopShiftV=-1;

dSaccSPVsep=50.0;   % higher value means saccade
LRsV = -10.0;
LRsH = 5.0;
NystBeatDeltaMax=18.0;

% ##### get names of all data files #####
% FileName = dir('..\Data\*.csv');

% szFileName = '..\Data\Jorgos-alexander.csv';
% szFileName = 'Claudia Tilt 2019-01-22.csv';
% szFileName = 'Claudia 2019-01-22.csv';
% szFileName = 'Thomas 2019-01-22.csv';
% szFileName = '2018-06-01 ThomasDrehung Rechts.csv';
% szFileName = '2018-06-01 Thomas TrapezDummy.csv';
% szFileName = '..\Data\2018-06-01 Claudia_Rotation.csv';
% szFileName =  'Jorgos-alexander.CSV';

% Protokoll ADVOCATE ohne Fixation !!!jjj5j
% szFileName = 'p00414s001e022c002t002.mat';    % O.K. R + Rot
% szFileName = 'p00415s001e021c001t003.mat';    % O.K. R  
% szFileName = 'p00415s003e022c003t003.mat';      %    L
% szFileName = 'p00415s003e022c003t002.mat';    % NO.K R
% szFileName = 'p00415s003e022c003t001.mat';           L
% szFileName = 'p00415s002e022c003t003.mat';      % BAD
% szFileName = 'p00416s001e021c001t001.mat';      %   R
% szFileName = 'p00415s001e022c002t001';
% Waser
% szFileName = 'p00416s001e022c002t003';
% szFileName = 'p00416s001e022c002t002';
% szFileName = 'p00416s001e022c002t001';

% calib_file = 'p00414s001_calib.mat';

% ----- Jorgos März -----
% szFileName = 'p00001s001e022c002t011.mat';
% szFileName = 'p00001s001e022c002t014.mat';  % jORGOS
% szPathName = '..\Data\';
% szPathName = '..\Data\Jorgos\';
% szPathName = '..\Data\Waser\';

% ##### get names of one data file #####

[file,path] = uigetfile('..\Data\Data_2019_04_16\*e022*.mat');
szFileName=file;
szPathName=path;

iFileNbr =1;

% [iFileNbr,~]=size(FileName)
% coeffZeroCross=zeros(iFileNbr,1);
nn_out=1;
nn=1;

for nn=1:iFileNbr      % if start at 2 because first is default !!
    bVDataValid=true;
    bHDataValid=true;

    %szFileName = FileName(nn).name;
    StrPos=strfind(szFileName,'s');
    szPatient=szFileName(1:StrPos-1);
    StrPosStrt=StrPos;
    StrPos=strfind(szFileName,'e');
    szSession=szFileName(StrPosStrt:StrPos-1);
    
    StrPosStrt=strfind(szFileName(1:end-4),'t');
    StrPos=strfind(szFileName,'.');
    szTest=szFileName(StrPosStrt:StrPos-1);

    f1=load([szPathName, szFileName]);

    [iSmpls, iSignals] = size(f1.Data);
    c1 = load([szPathName,szPatient,szSession,'_calib.mat']);

      
    [SizeData, ~] = size(f1.Data);
    
    if SizeData>500    % min 2.5s

        %----- read data from *.mat file ------
        clear EyePosDeg EyePosDegSmooth EyePosDiff EyePosSmoothDiff EyePosDiff2;
                 
        leftCol      = 'LeftPupilCol';
        leftRow      = 'LeftPupilRow';
        time         = 'Time';
        HeadInertialX = 'HeadInertialVelX';
        HeadInertialY = 'HeadInertialVelY';
        HeadInertialZ = 'HeadInertialVelZ';
        HeadInertialTime = 'LeftSystemTime'; % no HeadInertialTime

%         leftColInd = strcmp(leftCol,f1.DataNames,'exact');
        leftColInd = strmatch(leftCol,f1.DataNames,'exact');
        leftRowInd = strmatch(leftRow,f1.DataNames,'exact');
        timeInd = strmatch(time,f1.DataNames,'exact');
        HeadIndX = strmatch(HeadInertialX,f1.DataNames,'exact');
        HeadIndY = strmatch(HeadInertialY,f1.DataNames,'exact');
        HeadIndZ = strmatch(HeadInertialZ,f1.DataNames,'exact');
        HeadTimeIndX = strmatch(HeadInertialTime,f1.DataNames,'exact');
        EyePosPix = f1.Data(:,[leftColInd leftRowInd]);
        dTime = f1.Data(:,timeInd);
        % inertia sensor XYZ (not built in in all lenses)
        headMov(:,1) = f1.Data(:,HeadIndX);
        headMov(:,2) = f1.Data(:,HeadIndY);
        headMov(:,3) = f1.Data(:,HeadIndZ);
        HeadMovVect = sqrt(headMov(:,1).^2+headMov(:,2).^2+headMov(:,3).^2);
        HeadMovVect(1:30)=0;    % at the start there is always huge noise
        HeadMovVect(30000:end)=0;    % in the end there is always huge noise
        
        HeadMovVectMedian=medfilt1(HeadMovVect,10);
        HeadMovVectDiff = diff(HeadMovVect)*200;
        [maxXX,idxStartRotTime]=max(HeadMovVectDiff);
        [minXX,idxEndRotTime]=min(HeadMovVectDiff(idxStartRotTime+200:end));
        idxStartRotTime=idxStartRotTime+130;
        if idxStartRotTime>idxEndRotTime
           [idxEndRotTime, idxStartRotTime] = deal(idxStartRotTime,idxEndRotTime) 
        end
        idxEndRotTime=idxEndRotTime+idxStartRotTime+200;        
        headInertialTime = f1.Data(:,HeadTimeIndX);
        scaleRot=HeadMovVectDiff./headInertialTime(1:end-1);
        
        %----- calibration --------
        EyePosDeg =  atan(c1.LeftEyeCal *[EyePosPix  ones(size(EyePosPix(:,1))) ]')';
        EyePosDeg  = -rad2deg(EyePosDeg);    
        % --- remove outliers with median filter
        EyePosDegMedian(:,1) = medfilt1(EyePosDeg(:,1),10);   % median filter
        EyePosDegMedian(:,2) = medfilt1(EyePosDeg(:,2),10);   % median filter        
%         EyePosDeg=EyePosDegMedian;
        

        % --- smooth signal and diff of signals
%         EyePosDegSmooth(:,1) = conv(EyePosDegMedian(:,1),aWindow)/iWindow; % mean filter
%         EyePosDegSmooth(:,2) = conv(EyePosDegMedian(:,2),aWindow)/iWindow; % mean filter
        SPVRaw = diff(dSampleRate*EyePosDeg);                    % velocity in deg/s
        SPVConv(:,1) = conv(SPVRaw(:,1),aWindow)/iWindow; % mean filter
        SPVConv(:,2) = conv(SPVRaw(:,2),aWindow)/iWindow; % mean filter
        SPVMedian(:,1) = medfilt1(SPVRaw(:,1),10); % mean filter
        SPVMedian(:,2) = medfilt1(SPVRaw(:,2),10); % mean filter
        AccelrationRaw = diff(SPVRaw);                % acceleration in deg/s^2
        AccelrationMedian=diff(SPVMedian);
        % Returns Zero-Crossing Indices Of Argument Vector
        % vZeroCrossH = velocity            H = horizontal
        % aZeroCrossHdiff = acceleration    H = horizontal
        zci = @(v) find(v(:).*circshift(v(:), [-1 0]) <=0.0);  % Returns Zero-Crossing Indices Of Argument Vector
        idxZeroCrossH = zci(SPVRaw(:,1));
        idxZeroCrossV = zci(SPVRaw(:,2));
        idx_aZeroCrossHdiff = zci(AccelrationRaw(:,1));
        idx_aZeroCrossVdiff = zci(AccelrationRaw(:,2));
        iZCHDiff=diff(idxZeroCrossH);
        iZCVDiff=diff(idxZeroCrossV);
        
        len=size(SPVRaw);
        iIdx=1;
        for i=1:len
            withoutSaccade(i,1)=SPVRaw(i,1);
            useEyePosDeg(i,1)=1.0;
            if SPVMedian(i,1)>dSaccSPVsep || SPVRaw(i,1)<-dSaccSPVsep
                useEyePosDeg(i,1)=0.0;
                withoutSaccade(i,1)=NaN;
                SaccadeSPV(iIdx,2)=SPVRaw(i,1);
                SaccadeSPV(iIdx,1)=i;
                iIdx=iIdx+1;
            end           
        end
        withoutSaccade=medfilt1(withoutSaccade,10);
%         figure();
%         plot(dTime(1:end-1),withoutSaccade);
%         xlim([108.8 110.4]);

%         xlim([16, 17.5]);
%         grid on;
        % --- plot diff of signals --------------------------------
        if (bPlotAll)            
%             plotDiffSignal( dTime,EyePosSPVConv, EyePosSPVMedian, EyePosDeg, RawSPV, RawAccelration, SPVMedianAcc, szFileName);
%             plotDiffSignal_H( dTime,withoutSaccade, SPVMedian, EyePosDeg, SPVRaw, AccelrationRaw, AccelrationMedian, szFileName);
%             plotDiffSignal( dTime,EyePosSPVMedian,RawSPV, RawAccelration, szFileName,'median');
        end
        %############################################################################################        
%         plotPosSignal(dTime,EyePosDegMedian,EyePosDeg,'empty' );
%         plotPosSPVaccel(dTime, EyePosDeg, SPVRaw,AccelrationRaw);
        %############################################################################################
        
        % - if there are too many zero crossings -> no nystagmus -
        coeffZeroCross(nn)=size(SPVRaw)/size(idxZeroCrossH);
        if coeffZeroCross(nn)<=iNbrZeroCrossIndex; % 4!
           if bShowErrorMessage 
                mode = struct('WindowStyle','modal',... 
                              'Interpreter','tex');
                uiwait(errordlg('too many zero crossings -> no nystagmus','ERROR:',mode));
           end;
           Out(nn_out).Nystagmus=false; %NO Nystagmus detected
        else
           Out(nn_out).Nystagmus=true;
        end

        % Returns Zero-Crossing Indices Of Argument Vector
        % of the smoothed acceleration and velocity data
        idxZeroCrossH_S = zci(SPVConv(1:end-iWindow,1));   % array to big
        idxZeroCrossV_S = zci(SPVConv(1:end-iWindow,2));   % due to convolution 

        iZCHDiff_S=diff(idxZeroCrossH_S);
        iZCVDiff_S=diff(idxZeroCrossV_S);

        % --- get end of SPV ---
        endSPVH =  find(iZCHDiff >minDauerSPVHsmpl & iZCHDiff <maxDauerSPVsmpl)+1;
        endSPVV =  find(iZCVDiff >minDauerSPVVsmpl & iZCVDiff <maxDauerSPVsmpl)+1;
%         endSPVH =  find(iZCHDiff >minDauerSPVsmpl)+1;
%         endSPVV =  find(iZCVDiff >minDauerSPVsmpl)+1;
        [sizSPVH, ~]=size(endSPVH);
        [sizSPVV, ~]=size(endSPVV);
        if (sizSPVH<=2) 
            bHDataValid=false; 
        end
        if (sizSPVV<=2) bVDataValid=false; end
        if (sizSPVH<=2 || sizSPVV<=2)
           if bShowErrorMessage 
                mode = struct('WindowStyle','modal',... 
                              'Interpreter','tex');
                uiwait(errordlg('no SPV >25 smpls -> no nystagmus','ERROR:',mode));
           end;
%                    continue; % NOT enough Data Points
        end
        Out(nn_out).NbrNystBeat=sizSPVH;  
        % ----- Preparation of arrays -----
        if bHDataValid
            endValidSignalH = idxZeroCrossH(endSPVH(end-1));
        end

        if bVDataValid
%             endValidSignalV = idxZeroCrossV(endSPVV(end-1));
            startSPVV =idxZeroCrossV(endSPVV-1)+startShiftV;
            aNystBeatV = zeros (size(endSPVV,1),100);
        end
        % --- get end of smooth SPV ---
        endSPVH_S =  find(iZCHDiff_S >minDauerSPVHsmpl & iZCHDiff_S<maxDauerSPVsmpl)+1;
        endSPVV_S =  find(iZCVDiff_S >minDauerSPVVsmpl & iZCVDiff_S<maxDauerSPVsmpl)+1;
        [sizSPV_S, ~]=size(endSPVH_S);
        if sizSPV_S<=minDauerSPVHsmpl; 
           if bShowErrorMessage 
                mode = struct('WindowStyle','modal',... 
                              'Interpreter','tex');
                uiwait(errordlg('SMOOTH: no SPV >25 smpls -> no nystagmus','ERROR:',mode));
           end;
           Out(nn_out).DataPointsV=sizSPV_S;  %NOT enough Data Points
        end

        startSPVH_S =idxZeroCrossH_S(endSPVH_S-1)+startShiftH;
        startSPVV_S =idxZeroCrossV_S(endSPVV_S-1)+startShiftV;
        stoppSPVH_S =idxZeroCrossH_S(endSPVH_S)+stopShiftH;
        stoppSPVV_S =idxZeroCrossV_S(endSPVV_S)+stopShiftV;

% ------------------------------------------------------------------------
%   statistically evaluate all SPV points between start and end of one   #
%   nystagmus beat and save in array "aNystSPVdata"                      #
%                                                                        #
%   aNystBeat holds the position data of the nystagmus beat in deg.      #
%                                                                        #
%   aNystSPVdata(ii,7) is SPV linear between start and end point of      #
%   current nystagmus beat                                               #
%   1 = mean, 2 = std, 3 = median, 4 = IQR, 5 = max,                     #
%   6 = min 8 LMS fit 9 = 95% confidence interval                                  #
% ------------------------------------------------------------------------
%   plot evaluation with row and smooth velocity data
% ------------------------------------------------------------------------

% --- Horizontal ---------------------------------------------------------
        for ii = 1: size(endSPVH_S)-1
            iNbrPointH(ii) = stoppSPVH_S(ii)-startSPVH_S(ii)+1;
            dTimeDeltaH(ii)= dTime(stoppSPVH_S(ii))-dTime(startSPVH_S(ii));
            SPVDeltaH(ii)=   EyePosDeg(stoppSPVH_S(ii),1)-EyePosDeg(startSPVH_S(ii),1);
            meanSPVH(ii)=    SPVDeltaH(ii)/dTimeDeltaH(ii);
            
            xyz=mean(meanSPVH);
            
            aNystBeatH_S(ii,1:iNbrPointH(ii))...
            = EyePosDeg(startSPVH_S(ii):stoppSPVH_S(ii),1);
        end
% ------------------------------------------------------------------------
% --- Vertical -----------------------------------------------------------
        
        for ii = 1: size(endSPVV_S)-1
            iNbrPointV(ii) = stoppSPVV_S(ii)-startSPVV_S(ii)+1;
            dTimeDeltaV(ii)= dTime(stoppSPVV_S(ii))-dTime(startSPVV_S(ii));
            SPVDeltaV(ii)=   EyePosDeg(stoppSPVV_S(ii),2)-EyePosDeg(startSPVV_S(ii),2);
            meanSPVV(ii)=    SPVDeltaV(ii)/dTimeDeltaV(ii);
            
            aNystBeatV_S(ii,1:iNbrPointV(ii))...
            = EyePosDeg(startSPVV_S(ii):stoppSPVV_S(ii),2);
        end
% ------------------------------------------------------------------------
% -- load outlier data time / SPV --
%     aOutlierHL(1)=3
%     aOutlierHR(1)=1
%     aOutlierVL(1)=4
%     aOutlierVR(1)=2
    szOutlierFileName =['..\Data\',szFileName(1:end-4),'_Outlier'];
%     save(szOutlierFileName,'aOutlierHL','aOutlierVL','aOutlierHR','aOutlierVR');
%     load([szOutlierFileName,'.mat']);
% ------------------------------------------------------------------------
% -- plot all position signals -------------------------------------------
% ------------------------------------------------------------------------
% ------------------------------------------------------------------------
% -- Plot Nystagmus relative to its Positioin in degree                  -
% -- determine mean nystagmus velocity in 10s parts of signal            -
% ------------------------------------------------------------------------
        Plot.minSPV=5.0;
        Plot.dTime=dTime;
        Plot.EyePosDeg=EyePosDeg;
        Plot.SPVRaw=SPVRaw;
        Plot.AccelrationRaw=AccelrationRaw;
        Plot.NystBeatDeltaMax=NystBeatDeltaMax;
        
        Plot.dOutlierBoundary=dOutlierBoundary;
        Plot.iSignals=iSignals;
        Plot.Text.szFileName=szFileName;
        Plot.Text.szPatient=szPatient;
        Plot.Text.szTest=szTest;
        Plot.HeadMovVect=HeadMovVect;
        Plot.headInertialTime=headInertialTime;
        Plot.dSaccSPVsep=dSaccSPVsep;
        Plot.idxStartRotTime=idxStartRotTime;
        Plot.idxEndRotTime=idxEndRotTime;
                
%         Plot.aOutlierVL=aOutlierVL;
%         Plot.aOutlierHL=aOutlierHL;
%         Plot.aOutlierVR=aOutlierVR;
%         Plot.aOutlierHR=aOutlierHR;
        % --- all horizontal data ---
        if bHDataValid
            Plot.iNbrPointH=iNbrPointH;
            Plot.dTimeDeltaH=dTimeDeltaH;
            Plot.meanSPVH=meanSPVH;
            Plot.SPVDeltaH=SPVDeltaH;
            Plot.LRsH=LRsH;
            
            Plot.LeftH.dTime=zeros(1,1);
            Plot.RightH.dTime=zeros(1,1);
            Plot.LeftH.SPV=zeros(1,1);
            Plot.RightH.SPV=zeros(1,1);
            Plot.LeftH.Pos=zeros(1,1);
            Plot.RightH.Pos=zeros(1,1);
            Plot.LeftH.idx=zeros(1,1);
            Plot.RightH.idx=zeros(1,1);
            
            Plot.startShiftH=startShiftH;
            Plot.stopShiftH=stopShiftH;
            Plot.idxZeroCrossH=idxZeroCrossH;
            Plot.idxZeroCrossH_S=idxZeroCrossH_S;
            Plot.endSPVH=endSPVH;
            Plot.endSPVH_S=endSPVH_S;
            Plot.startSPVH_S=startSPVH_S;
            Plot.stoppSPVH_S=stoppSPVH_S;
            Plot.aNystBeatH_S=aNystBeatH_S;

%             Plot.OutlierLeftH.idx=[1,2,3,4];    % All outliers H Left
%             Plot.OutlierLeftH.SPV=[1,2,3,4];
%             Plot.OutlierLeftH.Pos=[1,2,3,4];
%             Plot.OutlierLeftH.dTime=[1,2,3,4];
%             Plot.OutlierRightH.idx=[1,2,3,4];   % All outliers H Right
%             Plot.OutlierRightH.SPV=[1,2,3,4];
%             Plot.OutlierRightH.Pos=[1,2,3,4];
%             Plot.OutlierRightH.dTime=[1,2,3,4];

            
            [iTmp,~]=size(Plot.endSPVH_S(:,1));
            NystSignH=ones(iTmp,1);
            Plot.NystSignH=NystSignH;                       
            Plot=calcSaccNystH(Plot);
%             Plot=deleteInvalid(Plot);

            plotSPVH_Time(Plot);
            plotSPVH_Position(Plot,Out(nn_out)); 
            Plot=plotSPVH_ExpFitTime(Plot);
%             plotSPVH_TimeConst(Plot);
%             timeBinning(Plot);
        end
        
        % --- all vertical data ---
        if bVDataValid
            Plot.iNbrPointV=iNbrPointV;
            Plot.dTimeDeltaV=dTimeDeltaV;
            Plot.meanSPVV=meanSPVV;
            Plot.SPVDeltaV=SPVDeltaV;
            Plot.LRsV=LRsV;
            
            Plot.LeftV.dTime=zeros(1,1);
            Plot.RightV.dTime=zeros(1,1);
            Plot.LeftV.SPV=zeros(1,1);
            Plot.RightV.SPV=zeros(1,1);
            Plot.LeftV.Pos=zeros(1,1);
            Plot.RightV.Pos=zeros(1,1);
            Plot.LeftV.idx=zeros(1,1);
            Plot.RightV.idx=zeros(1,1);
            
            Plot.startShiftV=startShiftV;
            Plot.stopShiftV=stopShiftV;
            Plot.idxZeroCrossV=idxZeroCrossV;
            Plot.idxZeroCrossV_S=idxZeroCrossV_S;
            Plot.endSPVV=endSPVV;
            Plot.startSPVV=startSPVV;
            Plot.endSPVV_S=endSPVV_S;
            Plot.startSPVV_S=startSPVV_S;
            Plot.stoppSPVV_S=stoppSPVV_S;
            Plot.aNystBeatV_S=aNystBeatV_S;
            Plot.aNystBeatV=aNystBeatV;
            
            Plot.OutlierLeftV.idx=[1,2,3,4];    % All outliers V Left
            Plot.OutlierLeftV.SPV=[1,2,3,4];
            Plot.OutlierLeftV.Pos=[1,2,3,4];
            Plot.OutlierLeftV.dTime=[1,2,3,4];
            Plot.OutlierRightV.idx=[1,2,3,4];   % All outliers V Right
            Plot.OutlierRightV.SPV=[1,2,3,4];
            Plot.OutlierRightV.Pos=[1,2,3,4];
            Plot.OutlierRightV.dTime=[1,2,3,4];

            [iTmp,~]=size(Plot.endSPVV_S(:,1));
            NystSignV=ones(iTmp,1);
            Plot.NystSignV=NystSignV;         
            Plot=calcSaccNystV(Plot);
            
            plotSPVV_Time(Plot);
            plotSPVV_Time_Graph(Plot);
            plotSPVV_Position_Graph(Plot,Out(nn_out));  
%             VerticalTimeBinning(SPVV_Pos,Plot);
 %             plotSPVV_TimeConst(Plot);
       end
        
        nn_out=nn_out+1;
        close all;
    end           
%   struct2csv(Out,[szPathName, 'Out.csv']);

end

aaa=1;
