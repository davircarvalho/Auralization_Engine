clear all; clc
% DAVI ROCHA CARVALHO APRIL/2021 - Eng. Acustica @UFSM 
% Test connection between MATLAB and webcam head tracker 

% MATLAB R2020b
%% Properties
python = true;

%% Via  python
if python
    % path to the python environment 
    executable = 'C:\Users\rdavi\anaconda3\envs\headtracker\python'; %#ok<*UNRCH>
    executionMode = 'OutOfProcess'; 
    pe = pyenv('Version',executable,'ExecutionMode',executionMode);

    if count(py.sys.path,'') == 0 % Adicionar path para 'variaveis ambiente caso num exista
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
IP = '127.0.0.1';
PORT = 50050;
udpr = dsp.UDPReceiver('RemoteIPAddress', IP,...
                       'LocalIPPort',PORT);
                   
% Read data from 
while true
    % read response
    py_output = udpr();
    if ~isempty(py_output)
       data = str2num(convertCharsToStrings(char(py_output))); %#ok<*ST2NM>
       disp([' yaw:', num2str(data(1)),...
             ' pitch:', num2str(data(2)),...
             ' roll:', num2str(data(3))])
    end
end 

