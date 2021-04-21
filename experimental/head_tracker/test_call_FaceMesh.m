clear all; clc
terminate(pyenv)
%% set environment
executable = 'C:\Users\rdavi\anaconda3\envs\mediapipe\python';
executionMode = 'OutOfProcess'; % Execution MUST be out of process to allow TCP connection
pe = pyenv('Version',executable,'ExecutionMode',executionMode);

if count(py.sys.path,'') == 0
    insert(py.sys.path,int32(0),'');
end


%% Initialize pyhton
p = gcp();
parfeval(p, @py.face_mesh.processing, 0); % Oh yeah!!


%% TCP-IP connection 
t = tcpip('localhost', 50050);
fopen(t);
addpath(genpath(pwd))

%% request data (write a message)
A = eye(3);

while true   % send request
    clc
    fwrite(t, 'gimme');
    % read response
    try 
        py_output = char(fread(t,[1, t.BytesAvailable]));  %#ok<FREAD>
        point_cloud = jsondecode(py_output);
        [~,Bfit,~] = absor(A,point_cloud, 'doScale', true, 'doTrans', false);  % rotation matrix
        % row, pitch and yaw
        %         row = rad2deg(atan2(-Bfit(3,2), Bfit(3,3)))
        pitch = rad2deg(asin(Bfit(3,1)))% elevation
        yaw = rad2deg(atan2(-Bfit(2,1),Bfit(1,1)))% azimuth
    catch
        continue
    end
    
end 

% , 