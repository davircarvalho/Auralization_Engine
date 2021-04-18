% test_call_FaceMesh

%% set environment
executable = 'C:\Users\rdavi\anaconda3\envs\mediapipe\python';
pe = pyenv('Version',executable);

if count(py.sys.path,'') == 0
    insert(py.sys.path,int32(0),'');
end

%% Call it
p = gcp();
a = parfeval(p, @py.face_mesh.mediapipecls, 0); % Oh yeah!!


%% 
g = py.face_mesh.mediapipecls.processing