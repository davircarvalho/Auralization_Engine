clear all; clc
% DAVI ROCHA CARVALHO APRIL/2021 - Eng. Acustica @UFSM 
% Test connection between MATLAB and webcam head tracker 

%% Properties
python = false;


%% Via  python
if python
    % path to the python environment 
    executable = 'C:\Users\rdavi\anaconda3\envs\mediapipe\python'; %#ok<*UNRCH>
    executionMode = 'OutOfProcess'; % MUST be 'out of process' to allow TCP connection
    pe = pyenv('Version',executable,'ExecutionMode',executionMode);

    if count(py.sys.path,'') == 0
        insert(py.sys.path,int32(0),'');
    end
    p = gcp();
    parfeval(p, @py.HeadTracker.processing, 0); % Oh yeah!!

    
%% Via .exe
else   
    addpath(genpath(pwd))
    open('HeadTracker.exe')
end


%% UDP connection
udpr = dsp.UDPReceiver('RemoteIPAddress', '127.0.0.1',...
                       'LocalIPPort',50050, ...
                       'ReceiveBufferSize', 32);
% Read data from 
while true
    % read response
    py_output = step(udpr);
    if ~isempty(py_output)
       yaw = str2double(native2unicode(py_output))
    end
end 
release(udpr)

