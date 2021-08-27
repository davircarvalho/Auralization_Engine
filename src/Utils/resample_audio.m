function resample_audio(app)
    release(app.Audio)                         
    release(app.deviceWriter)
    [aud, fs_original] = audioread(fullfile(app.Audiofolder, app.NameAudio));
    if fs_original ~= app.fs_SOFA
        aud = resample(aud, app.fs_SOFA, fs_original);  
    end

    aud = aud*((10^(-8/20))/(max(abs(aud(:)))));
    app.Audio = dsp.SignalSource(aud,app.BufferSize.Value); 
    app.fs_Audio = app.fs_SOFA;
    app.deviceWriter.SampleRate = app.fs_SOFA;  
end
