function optional_IR_conv(app)
    wait = waitbar(0, 'Processando HpTF', 'Name','Wait');
    release(app.Audio)                         
    release(app.deviceWriter)
    if app.fs_opt_IR == app.fs_Audio                
        [aud, ~] = audioread(fullfile(app.Audiofolder, app.NameAudio));
        convL = fast_conv(app, aud, app.opt_IR(:,1));
        waitbar(0.5)
        convR = fast_conv(app, aud, app.opt_IR(:,2));
        waitbar(0.9)
        y = [convL, convR];
        y = y./max(abs(y(:)))*0.975;
        app.convAudio = y;
        app.Audio = dsp.SignalSource(app.convAudio,app.BufferSize.Value); 
        app.conv_done = true;
    else 
        warndlg(['TAXAS DE AMOSTRAGEM: Audio estão em ', ...
        num2str(app.fs_Audio/1000) 'kHz, mas HpTF está em ', ...
        num2str(app.fs_opt_IR/1000) 'kHz'], 'Erro');
    end
    close(wait)                                      
end

function y = fast_conv(~,x1, x2)
    nfft = length(x1) + length(x2) - 1;
    y = real(ifft(fft(x1, nfft).*fft(x2, nfft)));
end
