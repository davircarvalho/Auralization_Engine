clear all; clc
terminate(pyenv)
%% set environment
executable = 'C:\Users\rdavi\anaconda3\envs\mediapipe\python';
executionMode = 'OutOfProcess'; % MUST be 'out of process' to allow TCP connection
pe = pyenv('Version',executable,'ExecutionMode',executionMode);

if count(py.sys.path,'') == 0
    insert(py.sys.path,int32(0),'');
end


%% Initialize pyhton
p = gcp();
parfeval(p, @py.head_tracker_via_tcp.processing, 0); % Oh yeah!!


%% TCP-IP connection 
t = tcpclient('localhost', 50050);
addpath(genpath(pwd))

%% request data (write a message)

while true   % send request
    % read response
    py_output = char(read(t)); 
    if ~isempty(py_output)
        yaw = (native2unicode(py_output))
    end
end 

