function [rc calib] = calibration(filename, varargin)
%CALIBRATION computes and saves the calibration data for the relation
%between pupil pixel and rotation data.
%
%   RC = CALIBRATION(FILENAME, ['PRCTILE']) loads the pupil pixel data found in the data file
%   FILENAME, performs a segmentation according to the stimulus data and
%   feeds a calibration process with the resulting median filtered data.
%   ['PRCTILE'] performs an alternative calibration algorithm using
%   prctiles instead of median.
%
%   See also get_calib_filename

%   Florian Dibiasi, Department of Neurology, Klinikum Großhadern, Munich
%   dibiasi@eyeseecam.com
%   08.09.2008
    rc = 1;
    calib = [];
    prctl_order_x = [50,25,75,50,50];
    prctl_order_y = [50,50,50,25,75];
    twindow_sec = 0.3; % length (in sec) to cut after change in stimulus
    thresh_deg = 5; % +- deg
    thresh_calib = 0.4; % ratio of data points which differ of a maximal amount of thresh_deg of the calibration points
    medianfilter_w = 20;
    % ---------- data loading -----------
    % load data
    data.content = load (filename);
    twindow_samples = round(twindow_sec*data.content.SamplingRate);
    % get pupil px data
    [LeftPupilPx RightPupilPx] = get_pupil_px(data.content.Data, data.content.DataNames);
    % get stimulus
    stimulus = get_stimulus(data.content.Data, data.content.DataNames);
    % get calibtarget (assume symmetric stimulus)
    eps = 1e-2;
    calibtarget = stimulus(abs(stimulus)>eps);
    calibtarget = mean(abs(calibtarget));
    
    if ~any(calibtarget)
        warning('Could not get calibration target angle [%f] from stimulus',calibtarget);
        return
    end
    
    % ---------- prepare data ----------
    % zeros
    idx = abs(stimulus(:,1))<eps & abs(stimulus(:,2))<eps;
    if isempty(idx)
        warning('Stimulus in [%s] is zero',filename);
        return
    end
    ind1 = find(diff(idx)==1);
    ind2 = find(diff(idx)==-1);
    if idx(1)==1
        ind1 = [0; ind1];
    end
    if idx(end)==1
        ind2 = [ind2; length(idx)];
    end
    % get 1 value each second
    ind1_old = ind1;
    ind2_old = ind2;
    ind1 = [];
    ind2 = [];
    for i=1:length(ind1_old)
        for j=1:ceil((ind2_old(i)-ind1_old(i))/data.content.SamplingRate)
            ind1(end+1) = ind1_old(i)+floor((j-1)*data.content.SamplingRate);
            ind2(end+1) = min(ind1_old(i)+floor(j*data.content.SamplingRate),ind2_old(i));
        end
    end
    LeftZeroMed = nan(length(ind1),2);
    RightZeroMed = nan(length(ind1),2);
    for i=1:length(ind1)
        LeftZeroMed(i,:) = nanmedian(LeftPupilPx(ind1(i)+1:ind2(i),:));
        RightZeroMed(i,:)= nanmedian(RightPupilPx(ind1(i)+1:ind2(i),:));
    end
    
    % segment stimulus
    HorPosInd = find(diff(stimulus(:,1))>eps) + 1;
    HorNegInd = find(diff(stimulus(:,1))<-eps) + 1;
    VerPosInd = find(diff(stimulus(:,2))>eps) + 1;
    VerNegInd = find(diff(stimulus(:,2))<-eps) + 1;
    % compute median of segments
    LeftHorPosMed = data_comp_px_stim_med (HorPosInd, HorNegInd, LeftPupilPx);
    LeftHorNegMed = data_comp_px_stim_med (HorNegInd, HorPosInd, LeftPupilPx);
    LeftVerPosMed = data_comp_px_stim_med (VerPosInd, VerNegInd, LeftPupilPx);
    LeftVerNegMed = data_comp_px_stim_med (VerNegInd, VerPosInd, LeftPupilPx);
    RightHorPosMed = data_comp_px_stim_med (HorPosInd, HorNegInd, RightPupilPx);
    RightHorNegMed = data_comp_px_stim_med (HorNegInd, HorPosInd, RightPupilPx);
    RightVerPosMed = data_comp_px_stim_med (VerPosInd, VerNegInd, RightPupilPx);
    RightVerNegMed = data_comp_px_stim_med (VerNegInd, VerPosInd, RightPupilPx);
    % catenate the medians
    data_left = [LeftZeroMed; LeftHorPosMed; LeftHorNegMed; LeftVerPosMed; LeftVerNegMed];
    data_right = [RightZeroMed; RightHorPosMed; RightHorNegMed; RightVerPosMed; RightVerNegMed]; 
    data_left = data_left(~isnan(data_left(:,1)),:);
    data_right = data_right(~isnan(data_right(:,1)),:);    
    
    
    % remove supposed "saccades"
    idx_toremove = false(size(stimulus,1),1);
    ind_toremove = unique([HorPosInd; HorNegInd; VerPosInd; VerNegInd]);
    for i=1:length(ind_toremove)
        idx_toremove(ind_toremove(i):min(length(idx_toremove),ind_toremove(i)+twindow_samples))=true;
    end
    
    if isempty(LeftPupilPx), LeftPupilPx_cleaned = LeftPupilPx; else LeftPupilPx_cleaned = LeftPupilPx(~idx_toremove,:); end
    if isempty(RightPupilPx), RightPupilPx_cleaned = RightPupilPx; else RightPupilPx_cleaned = RightPupilPx(~idx_toremove,:); end
    % remove NaNs
    LeftPupilPx_cleaned = LeftPupilPx_cleaned(~isnan(LeftPupilPx_cleaned(:,1)),:);
    RightPupilPx_cleaned = RightPupilPx_cleaned(~isnan(RightPupilPx_cleaned(:,1)),:);
    % --- prepare data end ---
                
    try
        % ---------- perform calibration (taken from S. Glasauer) ------------
        % target is at +-N deg
        Cr0 = [ 0  0;...
                0 -1;...
                0  1;...
               -1  0;...
                1  0];
        Cr = sin(Cr0 * calibtarget * pi/180);
        if isempty(data_left)
            warning('Calibration for left eye set to NaN');
            C_left = nan(5,2);
            LeftEyeCal = nan(2,3);
            diff_left = NaN;
        else
            % Left Eye
            N = 5;

            [minValHor minIdxHor] = nanmin(data_left(:,1));
            [maxValHor maxIdxHor] = nanmax(data_left(:,1));
             medValHor = nanmedian(LeftZeroMed(:,1));
            [minValVer minIdxVer] = nanmin(data_left(:,2));
            [maxValVer maxIdxVer] = nanmax(data_left(:,2));
             medValVer = nanmedian(LeftZeroMed(:,2));
                
            if ~isempty(strmatch('prctile',varargin,'exact'))      
                % using prctiles

                startValue = [medValHor medValVer;
                              data_left(minIdxHor,:);
                              data_left(maxIdxHor,:);
                              data_left(minIdxVer,:);
                              data_left(maxIdxVer,:)]
                try        
                    idx_left = kmeans(LeftPupilPx_cleaned,N,'Start',startValue,'EmptyAction','error');
                    C = nan(N,2);
                    % compute center over medians, rest over raw data
                    C(1,:) = [prctile(data_left(:,1),prctl_order_x(1)) prctile(data_left(:,2),prctl_order_y(1))];
                    for i=2:N
                        C(i,:) = [prctile(LeftPupilPx_cleaned(idx_left==i,1),prctl_order_x(i)) prctile(LeftPupilPx_cleaned(idx_left==i,2),prctl_order_y(i))];
                    end
                catch
                    C = startValue;
                end
            else                
                % conventional method using median over medians
                
                startValue = [medValHor medValVer;
                              minValHor medValVer;
                              maxValHor medValVer;
                              medValHor minValVer;
                              medValHor maxValVer];
                try
                    idx_left = kmeans(data_left,N,'Start',startValue,'EmptyAction','error');
                    C = nan(N,2);
                    for i=1:N
                        C(i,:) = median(data_left(idx_left==i,:));
                    end
                catch
                    C = startValue;
                end
            end

            i0_left = 1:N;
            [y(1) i1] = max(C(:,2));
            [y(2) i2] = min(C(:,2));
            [y(3) i3] = min(C(:,1));
            [y(4) i4] = max(C(:,1));
            i0 = setdiff(1:N,[i1 i2 i3 i4]);
            if length(i0)==1        
                C = C([i0 i1 i2 i3 i4],:);
                i0_left=[i0 i1 i2 i3 i4];
            end
            Ce = [C ones(size(C(:,1)))];
            LeftEyeCal = Cr' / Ce';
            C_left = C;
            
            % calibration rating
            Cr_deg = -Cr0*calibtarget;
            if ~isempty(strmatch('prctile',varargin,'exact'))
                data_est_left = asin((LeftEyeCal*[LeftPupilPx_cleaned ones(size(LeftPupilPx_cleaned(:,1)))]')') * 180 / pi;
                diff_left = nan(N,1);
                for i=1:N
                    diff_left(i) = nanmean(hypot(data_est_left(idx_left==i,1)-Cr_deg(i0_left(i),1),...
                                                 data_est_left(idx_left==i,2)-Cr_deg(i0_left(i),2)) <thresh_deg);
                end
            else
                data_est_left = asin((LeftEyeCal*[data_left ones(size(data_left(:,1)))]')') * 180 / pi;
                diff_left = nan(N,1);
                for i=1:N
                    diff_left(i) = nanmean(hypot(data_est_left(idx_left==i,1)-Cr_deg(i0_left(i),1),...
                                                  data_est_left(idx_left==i,2)-Cr_deg(i0_left(i),2)) <thresh_deg);
                end
            end
        end
        
        
        if isempty(data_right)
            warning('Calibration for right eye set to NaN');
            C_right = nan(5,2);
            RightEyeCal = nan(2,3);
            diff_right = NaN;
        else

            % Right Eye
            N = 5;
            
            [minValHor minIdxHor] = nanmin(data_right(:,1));
            [maxValHor maxIdxHor] = nanmax(data_right(:,1));
             medValHor = nanmedian(RightZeroMed(:,1));
            [minValVer minIdxVer] = nanmin(data_right(:,2));
            [maxValVer maxIdxVer] = nanmax(data_right(:,2));
             medValVer = nanmedian(RightZeroMed(:,2));
                
            if ~isempty(strmatch('prctile',varargin,'exact'))              
                % using prctiles
                
                startValue = [medValHor medValVer;
                              data_right(minIdxHor,:);
                              data_right(maxIdxHor,:);
                              data_right(minIdxVer,:);
                              data_right(maxIdxVer,:)];
                try                    
                    idx_right = kmeans(RightPupilPx_cleaned,N,'Start',startValue,'EmptyAction','error');
                    C = nan(N,2);
                    % compute center over medians, rest over raw data
                    C(1,:) = [prctile(data_right(:,1),prctl_order_x(1)) prctile(data_right(:,2),prctl_order_y(1))];
                    for i=2:N
                        C(i,:) = [prctile(RightPupilPx_cleaned(idx_right==i,1),prctl_order_x(i)) prctile(RightPupilPx_cleaned(idx_right==i,2),prctl_order_y(i))];
                    end
                catch
                    C = startValue;
                end
            else                
                % conventional method using median over medians
                
                startValue = [medValHor medValVer;
                              minValHor medValVer;
                              maxValHor medValVer;
                              medValHor minValVer;
                              medValHor maxValVer];
                try
                    idx_right = kmeans(data_right,N,'Start',startValue,'EmptyAction','error');
                    C = nan(N,2);
                    for i=1:N
                        C(i,:) = median(data_right(idx_right==i,:));
                    end
                catch
                    C = startValue;
                end
            end

            i0_right = 1:N;
            [y(1) i1] = max(C(:,2));
            [y(2) i2] = min(C(:,2));
            [y(3) i3] = min(C(:,1));
            [y(4) i4] = max(C(:,1));
            i0 = setdiff(1:N,[i1 i2 i3 i4]);
            if length(i0)==1
                C = C([i0 i1 i2 i3 i4],:);
                i0_right = [i0 i1 i2 i3 i4];
            end
            Ce = [C ones(size(C(:,1)))];
            RightEyeCal = Cr' / Ce';
            C_right = C;
            
            % calibration rating
            Cr_deg = -Cr0*calibtarget;
            if ~isempty(strmatch('prctile',varargin,'exact'))
                data_est_right = asin((RightEyeCal*[RightPupilPx_cleaned ones(size(RightPupilPx_cleaned(:,1)))]')') * 180 / pi;
                diff_right = nan(N,1);
                for i=1:N
                    diff_right(i) = nanmean(hypot(data_est_right(idx_right==i,1)-Cr_deg(i0_right(i),1),...
                                                  data_est_right(idx_right==i,2)-Cr_deg(i0_right(i),2)) <thresh_deg);
                end
            else
                data_est_right = asin((RightEyeCal*[data_right ones(size(data_right(:,1)))]')') * 180 / pi;
                diff_right = nan(N,1);
                for i=1:N
                    diff_right(i) = nanmean(hypot(data_est_right(idx_right==i,1)-Cr_deg(i0_right(i),1),...
                                                  data_est_right(idx_right==i,2)-Cr_deg(i0_right(i),2)) <thresh_deg);
                end
            end
        end
        
    catch
        error_msg(lasterror);
        return
    end
                
    % parse filename
    cfilename = get_calib_filename(filename);
    % create structure
    calib.LeftEyeCal = LeftEyeCal;
    calib.RightEyeCal = RightEyeCal;
    calib.LeftPupilPx = LeftPupilPx;
    calib.RightPupilPx = RightPupilPx;
    calib.C_left = C_left;
    calib.C_right = C_right;
    calib.Cr = Cr;
    calib.calibtarget = calibtarget;
    calib.filename = filename;
    calib.cfilename = cfilename;
    calib.medianfilter_w = medianfilter_w;
    % consider calibration rating
    disp(sprintf('Calibration rating: left: [%.2f], right: [%.2f], range: [%.1f], rating threshold: [%.2f]',...
                                mean(diff_left),mean(diff_right),thresh_deg,thresh_calib));
    if(0)
    if ~(mean(diff_left)>=thresh_calib && mean(diff_right)>=thresh_calib)
        hWD = warndlg(sprintf('Die Kalibration muss m%sglicherweise wiederholt oder angepasst werden!\n(Links: [%.2f], Rechts: [%.2f], Bereich: [%.1f deg], Güteschwelle: [%.2f])',...
                                createUmlaut(2),mean(diff_left),mean(diff_right),thresh_deg,thresh_calib));
        figure_toFront(hWD);
        uiwait(hWD);
    end
    end
    % show calibration
%     [fg calib_new] = show_calib (calib, 'AskForSaveChanges');
    % update calibration
%     LeftEyeCal = calib_new.LeftEyeCal;
%     RightEyeCal = calib_new.RightEyeCal;
% 	C_left = calib_new.C_left;
%     C_right = calib_new.C_right;
%     calibtarget = calib_new.calibtarget;
%     Cr = calib_new.Cr;
    % -----save calibration--------
%     if exist (cfilename,'file')
%         answer = questdlg('Soll die bestehende Kalibration überschrieben werden?','Kalibration schon vorhanden','Ja','Nein','Nein');
%         switch answer
%             case 'Ja'
%                 save(cfilename,'LeftEyeCal','RightEyeCal','LeftPupilPx','RightPupilPx','C_left','C_right','Cr','calibtarget','filename','-V4');                
%             case 'Nein'
%                 if isempty(strmatch('DoNotShowActCalib',varargin))
%                     show_calib(cfilename,'AlignRight');
%                 end
%         end
%     else
%         save(cfilename,'LeftEyeCal','RightEyeCal','LeftPupilPx','RightPupilPx','C_left','C_right','Cr','calibtarget','filename','-V4');  
%     end
    % ----save calibration end----
    rc = 0;
return





