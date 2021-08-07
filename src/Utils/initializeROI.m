function initializeROI(app)
azimm = -10;
app.ROI_list = cell(app.no_input,1);
for k = 1:app.no_input                      
    roi_name = (['CH' num2str(k)]);
    app.ROI_list{k} = roi_name;

%%% Desenhar ROI objeto %%%
    if app.ROI_flag % evita reinicializar o ROI e outras coisas a cada play
        markersize(app);
        get_parallax_pos(app)  % inicializar parallax
        azimm = azimm+10; elevv = 0;
        if verLessThan('matlab','9.9') % markersize(num existia antes do R2020b)
            app.ROI.(roi_name) = drawpoint(app.UIAxes, 'Position',[azimm, elevv],...
                                   'color', 'y');
        else
            app.ROI.(roi_name) = drawpoint(app.UIAxes, 'Position',[azimm, elevv],...
                                   'color', 'y', 'MarkerSize', app.MarkerSize);
        end
        app.ROI.(roi_name).Tag = roi_name; % Valor interno 
        HRIR_filter_design(app, azimm, elevv, roi_name);  
        app.roi_listen = addlistener(app.ROI.(roi_name), 'MovingROI', @app.allevents);
        app.ROI.(roi_name).Label = roi_name; % Valor visível                            
    end
end
set(app.UIFigure,'doublebuffer','off');
app.ROI_flag = 0;   % Indica que já foi desenhado 

end

function allevents(app, src, ~)
    HRIR_filter_design(app, src.Position(1), src.Position(2), src.Tag)
end

function markersize(app)
        app.MarkerSize = app.headradius/(app.DistValue)*100;
    if  app.MarkerSize < 7               
        app.MarkerSize = 7;
    end
end