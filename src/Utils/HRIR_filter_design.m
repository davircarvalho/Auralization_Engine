function HRIR_filter_design(app, azim, elev, ch)
%%% Por interpolação
interp_method = app.InterpolationDropDown.Value;
if any(strcmp(interp_method, {'VBAP', 'Bilinear'}))      
% %               [azim,elev] = nav2sph(-azim,elev);
%     idx_pos = dsearchn(app.posi(:,1:2), [azim,elev]);
%     % num da pra usar parallax com interpolacao da forma como ta implementado aqui (acho)            
%     posL = dsearchn(app.samplingGrid(:,1:2), app.parallax_pos_L(idx_pos,:));
%     posR = dsearchn(app.samplingGrid(:,1:2), app.parallax_pos_R(idx_pos,:));
%     % miinterolateHRTF possui pequenas correcoes na função original (valido para <= rR2020a)
%     interpolatedIR_L = miinterpolateHRTF(shiftdim(app.Obj_HRTF.Data.IR,1),...
%                                      app.posi(:,[1,2]),app.parallax_pos_L(idx_pos),...
%                                      'Algorithm', app.InterpolationDropDown.Value); 
%     interpolatedIR_R = miinterpolateHRTF(shiftdim(app.Obj_HRTF.Data.IR,1),...
%                                      app.posi(:,[1,2]),app.parallax_pos_R(idx_pos),...
%                                      'Algorithm', app.InterpolationDropDown.Value);
%     idx_pos = length(app.posi) + 1;
%     app.idx_FIR.(ch) = [idx_pos, idx_pos];
%     app.dspHRIR_L.(ch) = squeeze(interpolatedIR(:,1,:)).';
%     app.dspHRIR_R.(ch) = squeeze(interpolatedIR(:,2,:)).'; 
%     % Caso erro na interpolação use nearest 
%     if any(isnan(interpolatedIR(:)))
%         app.flag_interp = 'Empty';                        
%     end
    
    % get the parallax coordinate coorection
    [posiL, posiR] = parallax_interp(app, azim, elev);

    % do interpolation
    interH_L = squeeze(interpolateHRTF(app.Obj_HRTF.Data.IR, app.posi(:,1:2),...
                                       posiL,...
                                       'Algorithm', interp_method));
    Hl = interH_L(1,:).';
    if posiL ~= posiR
        interH_R = squeeze(interpolateHRTF(app.Obj_HRTF.Data.IR, app.posi(:,1:2),...
                                           posiR,...
                                           'Algorithm', interp_method));    
        Hr = interH_R(1,:).';
    else
        Hr = interH_L(2,:).';
    end
    
    % Set index positions
    app.posi = [app.posi(:,1:2); 
                       posiL;
                       posiR];
    posL = length(app.posi)-1; 
    posR = length(app.posi);
    app.idx_FIR.(ch) = [posL, posR];
    app.dspHRIR_L(posL,:) = Hl;
    app.dspHRIR_R(posR,:) = Hr;
end

%%% Pela posição mais próxima
if  any(strcmp(interp_method, 'Nearest')) ||...
                      any(strcmp(app.flag_interp, 'Empty')) 
    idx_pos = dsearchn(app.posi(:,1:2), [azim,elev]); % azim/elev here are taken in navigational coordinates
    posL = dsearchn(app.samplingGrid(:,1:2), app.parallax_pos_L(idx_pos,:));
    posR = dsearchn(app.samplingGrid(:,1:2), app.parallax_pos_R(idx_pos,:));

    app.idx_FIR.(ch) = [posL, posR];
    
    Hl = app.HRTFs(:,posL,1);
    Hr = app.HRTFs(:,posR,2);
    if strcmp(app.InterpolationDropDown.Value, {'VBAP', 'Bilinear'})
        % Reseta flag em interpolação caso tenha dado errado
        app.flag_interp = ''; 
    end
end



%%%% Atenuacao com a distancia --------------------------------------------
if app.flag_DistChanged || app.ROI_flag
    get_DistNorm(app, azim, elev, ch)                    
end
%%%% Absorcao do ar ------------------------------------------------------
% caso queira absorcao do ar e num tenha HT ativado
if ~app.flag_HeadTracker && app.AirabsorptionCheckBox.Value && ...
    app.DistValue > 2 % only apply for distances larger than 2m
       apply_air_abs(app, Hl, Hr, posL, posR);                                         
end
end       



function apply_air_abs(app, Hl, Hr, idx_L, idx_R)                       
    idx_air_abs = dsearchn(app.abs_dist_vec', app.DistValue);
    air_filter = app.AirAbsFilter{idx_air_abs};
    app.dspHRIR_L(idx_L,:) = air_filter(Hl);
    app.dspHRIR_R(idx_R,:) = air_filter(Hr);
end    




function get_DistNorm(app, azim, elev, name)
    msrd_dist = app.Obj_HRTF.SourcePosition(1,3);
    method = app.DistancevariationmethodListBox.Value;
    
    source_radius = app.radius.(name);

    
    if source_radius <= app.headradius
        source_radius = app.headradius+0.12;
    end
    
    source_nb = sscanf(name,'CH%d');
    if strcmpi(method, 'Inverse Law') 
        L_ear = app.Obj_HRTF.ReceiverPosition(1,:);
        R_ear = app.Obj_HRTF.ReceiverPosition(2,:);
        [tx, ty, tz] = sph2cart(azim, elev, source_radius);       
        Ldist = sqrt((L_ear(1) - tx)^2 + (L_ear(2) - ty)^2 + (L_ear(3) - tz)^2);
        Rdist = sqrt((R_ear(1) - tx)^2 + (R_ear(2) - ty)^2 + (R_ear(3) - tz)^2);
        % Calculate distance normalization                   
        app.DistNorm(source_nb,:) = [msrd_dist/Ldist, msrd_dist/Rdist];     
    else
        sg = [azim, elev, msrd_dist;
              azim, elev, source_radius];
        ear=[90 0];

        h = AKsphericalHead(sg, ear, false, app.headradius,...
                            sg(1,3), 40, 512, app.fs_SOFA, 342);
        %Get distance variation functions for left and right ear
        h_freq = fft(h);
        H_eq = squeeze(ifft(h_freq(:,2,:)./h_freq(:,1,:))).';
        
        % aplicar sobre hrtfs
        app.dist_FIR.(name) = {dsp.FIRFilter('Numerator', H_eq(1,:)),...
                               dsp.FIRFilter('Numerator', H_eq(2,:))};
    end
    markersize(app);
end     


function markersize(app)
    app.MarkerSize = app.headradius/(app.DistValue)*100;
    if app.MarkerSize < 7               
        app.MarkerSize = 7;
    end
end


function [posiL, posiR] = parallax_interp(app, azim, elev)         
    if app.DistValue < app.Obj_HRTF.SourcePosition(1,3)
        [posiL, posiR] = hrtf_parallax([azim, elev],...
                                        app.DistValue,...
                                        app.headradius); 
    else
        posiL = [azim, elev];
        posiR = [azim, elev];
    end
end 