
function callSOFAload(app)
%% LOAD SOFA
if app.startUP
    baseName = 'individuo_141.sofa';
   app.objSOFA = SOFAload(baseName, 'nochecks');
   app.SOFApath.Value = baseName; 
   app.startUP = 0;
else 
    [baseName, folder] = uigetfile([pwd, filesep, '*.sofa'], 'Load SOFA HRTF:');
    app.SOFApath.Value = baseName;  
    figure(app.UIFigure) %keep focus on app window
    app.objSOFA = SOFAload(fullfile(folder, baseName), 'nochecks');
end

convention = app.objSOFA.GLOBAL_SOFAConventions;


%% Calculate ITD and save delay in the object
if length(app.objSOFA.Data.Delay) ~= length(app.objSOFA.SourcePosition) && ...
                                 strcmpi(convention, 'SimpleFreeFieldHRIR')
    [~, app.objSOFA] = SOFAgetITD(app.objSOFA,'samples');% save ITD in Obj.Data.Delay
end


%% Positions 
%%% Set HATO if available
if strcmpi(convention, 'MultiSpeakerBRIR')  % MultiSpeakerBRIR
    app.flag_HATO = true;
    % Check if coordinates are cartesian or spheric
    if strcmp(app.objSOFA.ListenerView_Type, 'cartesian')
        EmitterPos_cart = app.objSOFA.ListenerView;
        [EmitterPos_sph(:,1),EmitterPos_sph(:,2),EmitterPos_sph(:,3)] = ...
                                            cart2sph(EmitterPos_cart(:,1),...
                                                     EmitterPos_cart(:,2),...
                                                     EmitterPos_cart(:,3));
        EmitterPos_sph(:,1:2)= rad2deg(EmitterPos_sph(:,1:2));
        app.objSOFA.ListenerView = EmitterPos_sph;
    end
    
    app.HATO = -sph2nav(app.objSOFA.ListenerView);
    app.HATO = app.HATO(:, 1);
    app.posi = app.objSOFA.EmitterPosition;
    
    app.objSOFA = truncate_IR(app.objSOFA);
else
    % check if source position is in degree or radians
    if range(app.objSOFA.SourcePosition(:,1)) < 4 
        app.objSOFA = ITA2spheric(app.objSOFA);
    end
    app.flag_HATO = false;
    app.posi = app.objSOFA.SourcePosition;
    
    if size(app.objSOFA.Data.IR,3) > 4096
        % Truncate HRIR length (Ludenby)
         app.objSOFA = truncate_IR(app.objSOFA);
    end
end

%%%% Set source positions 
app.samplingGrid = app.posi(:,1:2);
% convert coordinates for ploting
[app.posi(:,1), app.posi(:,2)] = sph2nav(-app.posi(:,1),app.posi(:,2));


%% Head radius
app.headradius = app.objSOFA.ReceiverPosition(1, 2); % raio da cabeça
if app.headradius >= 0.25
    app.headradius = app.headradius/10;
end


%% Distance slider update
app.DistanceSlider.Limits(1) = app.headradius+0.1;
app.DistValue = app.DistanceSlider.Value;
app.DistanceSlider.Value = app.posi(1,3);


%% Save meta to app 
app.fs_SOFA = app.objSOFA.Data.SamplingRate;
app.N = app.objSOFA.API.N;
if strcmpi(convention, 'SimpleFreeFieldHRIR')
   app.HRTFs = shiftdim(app.objSOFA.Data.IR, 2);  
   app.dspHRIR_L = app.HRTFs(:,:,1).';
   app.dspHRIR_R = app.HRTFs(:,:,2).';
   % size (source_pos x samples)
else % MultiSpeakerBRIR
   app.BRIRs = permute(app.objSOFA.Data.IR, [3,4,1,2]);  
   app.dspHRIR_L = app.BRIRs(:,:,:,1);
   app.dspHRIR_R = app.BRIRs(:,:,:,2);
   % size (source_pos x samples x hato)
end


%% Extra disable functionality 
if strcmpi(convention, 'MultiSpeakerBRIR')  % MultiSpeakerBRIR
    app.AirabsorptionCheckBox.Enable = false;
    app.AirabsorptionpropertiesISO96131Panel.Enable = 'off';
    app.ViewType.Enable = 'off';
    app.DistanceSlider.Enable = 'off'; 
    app.ViewType.Value = 'Frontal';
else
    app.AirabsorptionCheckBox.Enable = 'on';
    app.AirabsorptionpropertiesISO96131Panel.Enable = 'on';
    app.ViewType.Enable = 'on';
    app.DistanceSlider.Enable = 'on'; 
end