function HRIR_filter_design(app, azim, elev, ch)
%%% Por interpolação
if any(strcmp(app.InterpolationDropDown.Value, {'VBAP', 'Bilinear'}))      
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
end
%%% Pela posição mais próxima
if  any(strcmp(app.InterpolationDropDown.Value, 'Nearest')) ||...
                      any(strcmp(app.flag_interp, 'Empty')) 
    idx_pos = dsearchn(app.posi(:,1:2), [azim,elev]); % azim/elev here are taken in navigational coordinates
    posL = dsearchn(app.samplingGrid(:,1:2), app.parallax_pos_L(idx_pos,:));
    posR = dsearchn(app.samplingGrid(:,1:2), app.parallax_pos_R(idx_pos,:));

    app.idx_FIR.(ch) = [posL, posR];
    if app.flag_DistChanged || app.ROI_flag
        get_DistNorm(app,azim,elev, ch)                    
    end
    % caso queira absorcao do ar e num tenha HT ativado
    if ~app.flag_HeadTracker && app.AirabsorptionCheckBox.Value && ...
            app.DistValue > 2 % only apply for distances larger than 2m
           apply_air_abs(app,posL,posR);                                         
    end
    if strcmp(app.InterpolationDropDown.Value, {'VBAP', 'Bilinear'})
        % Reseta flag em interpolação caso tenha dado errado
        app.flag_interp = ''; 
    end
end
end       



function apply_air_abs(app, idx_L, idx_R)                       
    idx_air_abs = dsearchn(app.abs_dist_vec', app.DistValue);
    air_filter = app.AirAbsFilter{idx_air_abs};
    app.dspHRIR_L(idx_L,:) = air_filter(app.Obj_HRTF.Data.IR(:,idx_L,1));
    app.dspHRIR_R(idx_R,:) = air_filter(app.Obj_HRTF.Data.IR(:,idx_R,2));
end    




function get_DistNorm(app, azim, elev, name)
    msrd_dist = app.posi(1,3);
    method = app.DistancevariationmethodListBox.Value;
    
    if strcmpi(app.ViewType.Value, 'Top')  
    	 source_radius = app.radius.(name);
    else
         source_radius = app.DistValue;
    end
    
    if source_radius <= app.headradius
        source_radius = app.headradius+0.1;
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
        offCenter = false;
        a = app.headradius;
        r_0 = sg(1,3);
        Nsh = 40; 
        Nsamples = 256;%app.N;
        fs = app.fs_SOFA;
        c = 343;

        h = AKsphericalHead(sg, ear, offCenter, a, r_0, Nsh, Nsamples, fs, c);
        %Get distance variation functions for left and right ear
        h_freq = fft(h);
        H_eq = ifft(squeeze(h_freq(:,2,:))./squeeze(h_freq(:,1,:))).';

        % aplicar sobre hrtfs
        filtfir_L = dsp.FIRFilter('Numerator', H_eq(1,:));
        filtfir_R = dsp.FIRFilter('Numerator', H_eq(2,:));
        app.dist_FIR.(name) = {filtfir_L, filtfir_R};
    end
    markersize(app);
end     


function markersize(app)
        app.MarkerSize = app.headradius/(app.DistValue)*100;
    if  app.MarkerSize < 7               
        app.MarkerSize = 7;
    end
end