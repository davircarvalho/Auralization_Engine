% test_call_FaceMesh

%% set environment
clear all; clc
executable = 'C:\Users\rdavi\anaconda3\envs\mediapipe\python';
pe = pyenv('Version',executable );

if count(py.sys.path,'') == 0
    insert(py.sys.path,int32(0),'');
end


%% Initialize pyhton
p = gcp();
parfeval(p, @py.face_mesh.processing, 0); % Oh yeah!!


%% TCP-IP connection 
clc
t = tcpip('localhost', 50007);
fopen(t);

%% request data (write a message)
fwrite(t, 'This is a test message.');


% read echo
bytes = fread(t, [1, t.BytesAvailable]);
char(bytes)


%% 

% c = b.processing()

% executionMode= 'OutOfProcess';
