
function HRIR_filter_design(app, azim, elev, ch)
%%% Por interpolação
interp_method = app.InterpolationDropDown.Value;
if any(strcmp(interp_method, {'VBAP', 'Bilinear'}))      

end

%%% Pela posição mais próxima
if  any(strcmp(interp_method, 'Nearest')) ||...
                      any(strcmp(app.flag_interp, 'Empty')) 
    idx_pos = dsearchn(app.posi(:,1:2), [azim,elev]); % azim/elev here are taken in navigational coordinates
    if strcmpi(app.objSOFA.GLOBAL_SOFAConventions, 'SimpleFreeFieldHRIR')        
        posL = dsearchn(app.samplingGrid(:,1:2), app.parallax_pos_L(idx_pos,:));
        posR = dsearchn(app.samplingGrid(:,1:2), app.parallax_pos_R(idx_pos,:));
        Hl = app.HRTFs(:,posL,1);
        Hr = app.HRTFs(:,posR,2);
    else
        posL = idx_pos;
        posR = idx_pos;
    end

    app.idx_FIR.(ch) = [posL, posR];

    if strcmp(app.InterpolationDropDown.Value, {'VBAP', 'Bilinear'})
        % Reseta flag em interpolação caso tenha dado errado
        app.flag_interp = ''; 
    end
end



%%%% Atenuacao com a distancia --------------------------------------------
if app.flag_DistChanged || app.ROI_flag
    msrd_dist = app.posi(idx_pos,3);
    get_DistNorm(app, azim, elev, ch, msrd_dist)                    
end
%%%% Absorcao do ar ------------------------------------------------------
% caso queira absorcao do ar e num tenha HT ativado
if ~app.flag_HeadTracker && app.AirabsorptionCheckBox.Value && ...
    app.DistValue > 2 % only apply for distances larger than 2m
       apply_air_abs(app, Hl, Hr, posL, posR, app.radius.(ch));                                         
end
end


function apply_air_abs(app, Hl, Hr, idx_L, idx_R, dist)                       
%             idx_air_abs = dsearchn(app.abs_dist_vec', app.DistValue);
    [~,idx_air_abs] = min(abs(app.abs_dist_vec-dist));
    air_filter = app.AirAbsFilter{idx_air_abs};
    app.dspHRIR_L(idx_L,:) = air_filter(Hl);
    app.dspHRIR_R(idx_R,:) = air_filter(Hr);
end    




function get_DistNorm(app, azim, elev, name, msrd_dist)
%     msrd_dist = app.objSOFA.SourcePosition(1,3);
    method = app.DistancevariationmethodNearfieldListBox.Value;

    source_radius = app.radius.(name);                  
    if source_radius <= app.headradius
        source_radius = app.headradius+0.12;
    end

    if strcmpi(method, 'Inverse Law') || source_radius>2
        source_nb = sscanf(name,'CH%d');
        L_ear = app.objSOFA.ReceiverPosition(1,:);
        R_ear = app.objSOFA.ReceiverPosition(2,:);
        [tx, ty, tz] = sph2cart(azim, elev, source_radius);       
        Ldist = sqrt((L_ear(1) - tx)^2 + (L_ear(2) - ty)^2 + (L_ear(3) - tz)^2);
        Rdist = sqrt((R_ear(1) - tx)^2 + (R_ear(2) - ty)^2 + (R_ear(3) - tz)^2);
        % Calculate distance normalization                   
        app.DistNorm(source_nb,:) = [msrd_dist/Ldist, msrd_dist/Rdist];     
    else % dist equalization 
        if app.fs_SOFA == 44100 || ...
                app.fs_SOFA == 48000 || ...
                app.fs_SOFA == 88200 || ...
                app.fs_SOFA == 96000

             [~,idx_azim] = min(abs(app.distEq.azim-azim));
             [~,idx_radius] = min(abs(app.distEq.source_radius-source_radius));
             H_eq = app.distEq.distEQ(:,:,idx_azim,idx_radius);  
        else
            sg = [azim, elev, msrd_dist;
                  azim, elev, source_radius];
            ear=[90 0];

            h = AKsphericalHead(sg, ear, false, app.headradius,...
                                sg(1,3), 40, 512, app.fs_SOFA, 342);
            %Get distance variation functions for left and right ear
            h_freq = fft(h);
            H_eq = squeeze(ifft(h_freq(:,2,:)./h_freq(:,1,:))).';
        end
        % aplicar sobre hrtfs
        app.dist_FIR.(name){1}.Numerator = H_eq(1,:);
        app.dist_FIR.(name){2}.Numerator = H_eq(2,:);
    end
    markersize(app);
end   