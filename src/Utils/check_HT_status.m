function check_HT_status(app)
    % check if process is still open or not
    [~,cmdout]=system('tasklist /fi "imagename eq HeadTracker.exe"');
    tasklist_output = convertCharsToStrings(cmdout);
    app.flag_HeadTracker = contains(tasklist_output, 'HeadTracker.exe');
    if app.flag_HeadTracker
        try 
            release(app.udpr)
        catch                
        end               
        IP = '127.0.0.1';
        PORT = 50050;
        app.udpr = dsp.UDPReceiver('RemoteIPAddress', IP,...
                                   'LocalIPPort', PORT, ...
                                   'ReceiveBufferSize', 8);
    end
end