function check_HT_status(app)
%     % check if process is still open or not
%     [~,cmdout]=system('tasklist /fi "imagename eq python.exe"');
% %     [~,cmdout]=system('tasklist');
%     tasklist_output = convertCharsToStrings(cmdout);
%     app.flag_HeadTracker = contains(tasklist_output, 'EAC_head_tracker')
% %     app.flag_HeadTracker = contains(tasklist_output, 'python.exe'); % this is just for the dev, use the above instead
%     if app.flag_HeadTracker
    app.flag_HeadTracker = true;
    try 
        release(app.udpr)
    catch                
    end               
    IP = '127.0.0.1';
    PORT = 50050;
    app.udpr = dsp.UDPReceiver('RemoteIPAddress', IP,...
                               'LocalIPPort', PORT, ...
                               'ReceiveBufferSize', 30);
%     end
end