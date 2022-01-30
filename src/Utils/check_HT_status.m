function check_HT_status(app)
    % check if process is still open or not
    [~,cmdout]=system('tasklist /fi "imagename eq HeadTracker.exe"');
%     [~,cmdout]=system('tasklist');
    tasklist_output = convertCharsToStrings(cmdout);
    app.flag_HeadTracker = contains(tasklist_output, 'HeadTracker.exe');
%     app.flag_HeadTracker = contains(tasklist_output, 'python.exe'); % this is just for the dev, use the above instead
    if app.flag_HeadTracker
        try 
            release(app.udpr)
        catch                
        end               
        IP = '127.0.0.1';
        PORT = 50050;
        app.udpr = dsp.UDPReceiver('RemoteIPAddress', IP,...
                                   'LocalIPPort', PORT, ...
                                   'ReceiveBufferSize', 30);
    end
end