function rc = CalibrationLeftScript(Event,Params)
% rc = CalibrationScript(Event,Params) performs calibration.
%
% Event: Compulsory Event strings are:
%           ExaminationInit
%           MeasurementInit
%           TrialInit
%           Work
%           Analyze
%           TrialExit
%           MeasurementExit
%           ExaminationExit
%
% You can specify additional custom functions (their names are given by the
% corresponding event strings)
%
% NB: All the Event string have to be implemented as functions!!
%
% See also EmptyScript, EyeSeeMat, EyeSeeMex.

    % --------------- DO NOT EDIT -------------
    
    % check if the default event strings are implemented.
    thisName = strcat(mfilename('fullpath'),'.m');
    implFunctions = {'ExaminationInit' 'MeasurementInit' 'TrialInit' ...
                     'Work' 'Analyze' ...
                     'TrialExit' 'MeasurementExit' 'ExaminationExit'};
    for i=1:length(implFunctions)
        thisFunction = which(implFunctions{i});
        if isempty(thisFunction) || ~strcmp(thisName,thisFunction)
            warning('MATLAB:DefaultEventNotImplemented','Default event %s is not implemented in %s!',implFunctions{i},thisName);
        end
    end    
    % check if current events is implemented.
    thisFunction = which(Event);
    if isempty(thisFunction) || ~strcmp(thisName,thisFunction)
        warning('MATLAB:CurrentEventNotImplemented','Current event %s is not implemented in %s!',Event,thisName);
    end

    % check for string (TESTING only)
    if ~ischar(Event) || ~ischar(Params)
        warning('MATLAB:WrongArgIn','Event (%s) or Params (%s) is not a string',class(Event),class(Params));
    end
    
    % build command string
    cmd = [Event '(''' Params ''');'];
    % evaluate command string
    try
        rc = eval(cmd);
        if rc
            warning('ERROR:SaccadeScript: Return value is non-zero!');
        end
    catch
        lasterr = lasterror;
        disp(lasterr.message);
        disp(lasterr.identifier);
        rc = 1;
    end
    
    % --------------------------------------

return

% ----------- EDIT BELOW ----------------
%
% Be sure that all the functions / events you need are implemented here.
% You can simply add custom functions here as well.
%
% Note that customized functions have to preserve the syntax:
%   rc = myFun(Params)
%       [...]
%   return

function rc = ExaminationInit (Params)
   %%%==========================
    %if(~isempty(which('my_workspace.mat'))) load my_workspace; end;
    
    %%% use Screen: mode=0 ; use opengl: mode=1;
    rc_screen = initStimulusScreen ( 0 );
    
    % #############################################


    % ############## show init screen ###############################
    % show_param(1) 1=cross, 2=point, 3=cross+point
    show_par=1;
    show_text = 'Kalibration Links';
    ShowInitScreen (show_par,show_text);

    rc = 0;
return




function rc = MeasurementInit (Params)
  
    measurement_param = Params
    %save my_workspace.mat -append measurement_param;
    %%%============================
    %if(~isempty(which('my_workspace.mat'))) load my_workspace; end;
    load my_workspace window_h screenid;
    
    % ############## show init screen ###############################
    % show_param(1) 1=cross, 2=point, 3=cross+point
    show_par=3;
    show_text = 'Kalibration Links';
    ShowInitScreen (show_par,show_text);
    
    % #############################################
    str_out = ['0 0 0 0 ' measurement_param];
    [rc] = EyeSeeMex('WriteStringLocked',str_out, 0); %last param = offset
    
    rc = 0;
return




function rc = TrialInit (Params)
  
    %%%============================
    %if(~isempty(which('my_workspace.mat'))) load my_workspace; end;
    load my_workspace winRect;% measurement_param;
    
    %measurement_param
      
    %%####### Display Parameters #########
    % -- distance = 145 cm, display_w = 116,5 cm 
    % -- 24.34 grad = alpha = tan( (116,5/2) / 145)*180/pi
    screen_width = winRect(3);
    screen_height = winRect(4);
    disp_distance_cm = 120; %cm
    disp_width_cm = 116.5; %cm
    scan_params = sscanf(Params,'%f %f')
    if(~isempty(scan_params))
        disp_distance_cm = scan_params(1);
        disp_width_cm = scan_params(2);
    end;
    disp_grad_w = 2 * tan( (disp_width_cm/2) / disp_distance_cm)*180/pi; %% wieviel grad ist ein display
    faktor_grad_to_pixel = screen_width/disp_grad_w; %% wieviel pixel ist ein grad
    disp(sprintf('\n Par 1: distance=%f, width=%f',disp_distance_cm,disp_width_cm));
    
    %%####### Stimulus position (constant) #########
    stim_pos_grad = 17.0/2;

    %%####### Stimulus duration (constant) #########
    stim_dur = 2.0; %sec
    
    %%####### Stimulus profile ###############
    %% duration (sec) position (grad from middle point) velocity (grad/sec)
    %% position : positiv vert.=down, positiv hor.=to right
    %% stimulus type : 1=point static, 2=horizontal 3=vertical
    stimdata.duration_vec =      [ 1   1  1  1  1   1  1  1  1   1  1  1  1  1  1]; 
    stimdata.velocity_x_vec =    [ 0   0  0  0  0   0  0  0  0   0  0  0  0  0  0]; 
    stimdata.velocity_y_vec =    [ 0   0  0  0  0   0  0  0  0   0  0  0  0  0  0]; 
    stimdata.pos_x_vec =         [ 0   0 -1  0  1   0 -1  0  1   0 -1  0  1  0  0]; 
    stimdata.pos_y_vec =         [ 0  -1  0  1  0  -1  0  1  0  -1  0  1  0  0  0]; 
    stimdata.type_vec =          [ 1   1  1  1  1   1  1  1  1   1  1  1  1  1  1]; 
    
    stimdata.pos_x_vec    = stim_pos_grad * stimdata.pos_x_vec; 
    stimdata.pos_y_vec    = stim_pos_grad * stimdata.pos_y_vec;
    stimdata.duration_vec = stim_dur * stimdata.duration_vec;
  
    save my_workspace.mat -append screen_width screen_height faktor_grad_to_pixel stimdata;
    %WorkLoop ();
    %%%============================
  
    rc = 0;
return

function rc = Work (Params)
    rc = WorkLoop (Params);
return

function rc = Analyze (Params)

    params_find = strfind(Params,'params.mat')
    if(~isempty(params_find))
        f = load(Params);
        fname = deblank(f.filenames(1,:));
    else
        fname = Params;
    end
    
    calib_LR_flag = 1; %(1=left,2=right)
    
    %% -----check if calib_file exist---
    %% -----check if original_file in calib_file is eqal to fname ----
    calib_file_exist = 0;
    if(~isempty(params_find))
        try
            calib_file_name = get_calib_filename(fname);
            content=load(calib_file_name);
            if(strmatch(content.filename,fname,'exact'))
               calib_file_exist = 1;
            end
        catch
            calib_file_exist = 0;
        end
        calib_file_exist
    end
    
%    if(calib_file_exist == 0)
        [rc calib] = calibration (fname,'prctile','DoNotShowActCalib');
        if rc
            answ = questdlg(sprintf('Kalibration fehlgeschlagen! M%sglicherweise m%sssen Sie die Messung wiederholen! Was m%schten Sie tun?',createUmlaut(2),createUmlaut(3),createUmlaut(2)),...
                            'Kalibration fehlgeschlagen','Manuelle Kalibration','Standard-Kalibration laden','Rohdaten anzeigen','Manuelle Kalibration');
            switch answ
                case {'Manuelle Kalibration' ''}                    
                    show_not_calib_LR (fname,calib_LR_flag);
                case 'Standard-Kalibration laden'
                    [pname ffname] = fileparts(fname);
                    cfilename = get_default_calib_filename;
                    if exist(fullfile(pname,cfilename),'file')
                        show_calib_LR (fullfile(pname,cfilename),calib_LR_flag);
                    elseif exist(cfilename,'file')
                        show_calib_LR (cfilename,calib_LR_flag);
                    else
                        hWD = warndlg('Standard-Kalibration konnte nicht geladen werden!','WARNING: Default Calibration not available','modal');
                        figure_toFront (hWD);
                        uiwait(hWD);
                        px_plot(fname);
                        rc = 0;
                        return
                    end
                case 'Rohdaten anzeigen'
                    px_plot(fname);
                    rc = 0;
                    return
            end
        else
            show_calib_LR (calib, calib_LR_flag, 'AskForSaveChanges');
        end
    
%     else
%             % --- falls der test in calib_kalorik_analyze_and_plot hat
%             % ergeben, dass es eine calib datei schon gibt und sie wurde
%             % aus der gleichen quell-datei generiert (da muss man noch pfad
%             % abschneiden...) - dann nicht neu kalibrieren!!! (nur
%             % anzeigen) 
%             calib1 = get_calib_filename(fname)
%             [fg1 data1] = show_calib_from_file(calib1);
%             rc = 0
%     end;
    
return




function rc = TrialExit (Params)
   %%%============================
    %if(~isempty(which('my_workspace.mat'))) load my_workspace; end;

    load my_workspace;% measurement_param;
    measurement_param = '';
    % ############## show init screen ###############################
    % show_param(1) 1=cross, 2=point, 3=cross+point
    show_par=1;
    show_text = '';
    ShowInitScreen (show_par,show_text);
    
    str_out = ['0 0 0 0 ' measurement_param];
    [rc] = EyeSeeMex('WriteStringLocked',str_out, 0); %last param = offset
    
    %clear Params;
    %save my_workspace;
    %%%============================
    rc = 0;
return


function rc = MeasurementExit (Params)

    load my_workspace window_h;
    
    Screen('Flip', window_h);
    
    rc = 0;
    
return



function rc = ExaminationExit (Params)
   %%%============================
    %if(~isempty(which('my_workspace.mat'))) load my_workspace; end;
    try
        load my_workspace window_h init_open_gl_by_script;
    
        if(init_open_gl_by_script==1)
          %Priority (0);
          % Exit
          %Screen('Flip', window_h);
          %Screen ('CloseAll');

        end;
    catch
    end;
    
    %%%============================
    rc = 0;
return



function rc = WorkLoop ( Params )

    %%%============================
    %if(~isempty(which('my_workspace.mat'))) load my_workspace; end;
    %load my_workspace.mat
    measurement_param='';
    load my_workspace.mat window_h stimdata screen_width screen_height faktor_grad_to_pixel;
    
    %% recompute position and velocity from grad into pixel
    pos_x_pixel_vec      = screen_width/2  + (faktor_grad_to_pixel * stimdata.pos_x_vec);
    pos_y_pixel_vec      = screen_height/2 + (faktor_grad_to_pixel * stimdata.pos_y_vec);
    velocity_x_pixel_vec = (faktor_grad_to_pixel * stimdata.velocity_x_vec);
    velocity_y_pixel_vec = (faktor_grad_to_pixel * stimdata.velocity_y_vec);
      
    %% ----init start values-----
    stim_cnt = 1;
    x_pos_st     = pos_x_pixel_vec(stim_cnt);
    y_pos_st     = pos_y_pixel_vec(stim_cnt);
    stim_cnt_max = length(stimdata.duration_vec);
    stim_dur     = stimdata.duration_vec(stim_cnt);
    x_vel        = velocity_x_pixel_vec(stim_cnt);
    y_vel        = velocity_y_pixel_vec(stim_cnt);
    stim_type    = stimdata.type_vec(stim_cnt);
    
    rc_wait = wait_for_start_work ();
    if(rc_wait>0)
        rc=1;
        disp(sprintf('XXXXXXXXX WORK:::WaitForStart ERROR !!!'));
        %return;
    end;
    
    x_pos_out  = 0;
    y_pos_out  = 0;
    x_pos      = x_pos_st;
    y_pos      = y_pos_st;
    
    time_loop_abs   = 0;
    time_loop       = 0;
    time_loop_start = GetSecs;
    time_st         = time_loop_start;
    time_stim_start = time_loop_start;
    time_stim_dur   = 0;
    %time_loop_start = timestamp loop start
    %time_loop = each loop duration
    %time_stim_start = timestamp start of current profile item 
    %time_stim_dur = duration of current profile item
    %time_loop_abs = duration of stimulation
    
    do_loop=1;
    while (do_loop)
    
        time_now       = GetSecs;
        time_stim_dur  = time_now - time_stim_start;
        time_loop_abs  = time_now - time_loop_start;
        time_loop      = time_now - time_st;
        time_st        = time_now;
        
        %%################ Check next profile##############
        if(time_stim_dur >= stim_dur)
            
            stim_cnt=stim_cnt+1;
            if(stim_cnt > stim_cnt_max)
                [rc] = EyeSeeMex('SendVisualEvent'); % send event
                do_loop = 0;
                break;
            end;
            %---get new profile---
            time_offset     = (time_stim_dur - stim_dur);
            x_pos_st        = pos_x_pixel_vec(stim_cnt);
            y_pos_st        = pos_y_pixel_vec(stim_cnt);
            stim_dur        = stimdata.duration_vec(stim_cnt);
            x_vel           = velocity_x_pixel_vec(stim_cnt);
            y_vel           = velocity_y_pixel_vec(stim_cnt);
            stim_type       = stimdata.type_vec(stim_cnt);
            x_pos           = x_pos_st;
            y_pos           = y_pos_st;
            time_stim_start = time_now - time_offset;
            time_stim_dur   = time_offset;
        end;
        
        %%############## Compute new target position ############
        target_offs_x = time_loop * x_vel;
        target_offs_y = time_loop * y_vel;
        x_pos         = x_pos + target_offs_x;
        y_pos         = y_pos + target_offs_y;
        
        %########### draw stimulus #########################
        if(stim_type==1) 
            %----------stimulus POINT--------
            oval_size = 6;
            penWidth = 6;
            color_w=[250 250 250];
            pos_rect=[x_pos-oval_size y_pos-oval_size x_pos+oval_size y_pos+oval_size]; 
            Screen('FrameOval', window_h,color_w,pos_rect,penWidth);
            Txt_Out = ' ';
            Screen('DrawText',window_h,Txt_Out,1,1,[255, 255, 255]);  
        else
            %----------stimulus LINES--------
%              srcRect=[x_pos y_pos (x_pos + visiblesize) (y_pos + visiblesize)];
%              if(stim_type==2) 
%                Screen('DrawTexture', window_h, gratingtex_h, srcRect);
%              end;
%              if(stim_type==3) 
%                Screen('DrawTexture', window_h, gratingtex_v, srcRect);
%              end;
        end;
        Screen('Flip', window_h);
        
        
        %############ WRITE DATA ###################
        %% ----output velocity----------
        %x_pos_out     = x_vel / faktor_grad_to_pixel;
        %y_pos_out     = y_vel / faktor_grad_to_pixel;
        %% ----output position----------
        x_pos_out     = (x_pos - screen_width/2) / faktor_grad_to_pixel;
        y_pos_out     = (y_pos - screen_height/2) / faktor_grad_to_pixel;
        %% ----------------------------
        str1 = num2str(x_pos_out);
        str2 = num2str(y_pos_out);
        str3 = num2str(stim_cnt);
        str4 = num2str(time_loop_abs);
        str_out = [str1 ' ' str2 ' ' str3 ' ' str4 ' ' measurement_param];
        [rc] = EyeSeeMex('WriteStringLocked',str_out, 0); %last param = offset
        
        %disp(sprintf('XXXX %s, stim=%f',str_out, time_stim_dur));
        %disp(sprintf('XXXX xy= %.3f %.3f %.3f',x_pos_out,y_pos_out,stim_cnt));
        %disp(sprintf('XXXX xy= %.3f %.3f %.3f',x_pos,y_pos,stim_cnt));
        
        
        %####### WAIT FOR EYESEECAM EVENT (STOP RECORD BUTTON) ##########
        [rc] = EyeSeeMex('PeekEvent'); %rc=1 ==> :new event
        %disp(sprintf('XXXXXXXXX WORK:::PeekEvent rc = [%i] jump_cnt=%i', rc(1),jump_cnt));
        if rc~=0
            disp(sprintf('XXXXXXXXX WORK:::PeekEvent exit loop'));
            break;
        end
        %pause(0.5);
        %####### WAIT FOR USER EVENT SHIFT+ESC = MANUAL ABORT ##########
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
        if (keyCode(225) && keyCode(41)) % 225=SHIFT 41=ESC
            break;
        end;
    end % loop
    
    %%%============================
    rc = 0;
return;
