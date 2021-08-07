function get_parallax_pos(app)         
    if app.DistValue < app.posi(1,3)
        [app.parallax_pos_L, app.parallax_pos_R]=...
                            hrtf_parallax(app.samplingGrid,...
                                          app.DistValue,...
                                          app.headradius); 
    else
        app.parallax_pos_L = app.samplingGrid;
        app.parallax_pos_R = app.samplingGrid;
    end
end