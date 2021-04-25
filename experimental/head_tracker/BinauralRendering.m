clear all;  clc
addpath(genpath(pwd))

%% Carregar HRTFs
%Essas ja vem com o matlab, nao precisa definir path nem nada
ARIDataset = load('ReferenceHRTF.mat'); 
% separar HRTFs
hrtfData = double(ARIDataset.hrtfData);
hrtfData = permute(hrtfData,[2,3,1]);
% Separar posições de fonte
sourcePosition = ARIDataset.sourcePosition(:,[1,2]);
sourcePosition(:,1) = sourcePosition(:,1) - 180;


%% Carregar audio mono
[heli,originalSampleRate] = audioread('Heli_16ch_ACN_SN3D.wav'); % ja vem com o matlab 
heli = 12*heli(:,1); % keep only one channel

sampleRate = 48e3;
heli = resample(heli,sampleRate,originalSampleRate);


%% Jogar audio para objeto DSP
sigsrc = dsp.SignalSource(heli, ...
    'SamplesPerFrame',512, ...
    'SignalEndAction','Cyclic repetition');

% Configurar dispositivo de audio
deviceWriter = audioDeviceWriter('SampleRate',sampleRate);


%% Definir filtros FIR 
FIR = cell(1,2);
FIR{1} = dsp.FIRFilter('NumeratorSource','Input port');
FIR{2} = dsp.FIRFilter('NumeratorSource','Input port');


%% Inicializar Head Tracker 
open('HeadTracker.exe')
udpr = dsp.UDPReceiver('RemoteIPAddress', '127.0.0.1',...
                       'LocalIPPort',50050, ...
                       'ReceiveBufferSize', 18); % conectar matlab ao head tracker

% setup(udpr); 
% Processamento em tempo real (fonte fixa no espaco)
audioUnderruns = 0;
audioFiltered = zeros(sigsrc.SamplesPerFrame,2);

pitch = 0;
yaw = 0;

s_azim = 0;
s_elev = 0;

idx_pos = dsearchn(sourcePosition, [s_azim, s_elev]);
release(deviceWriter)

tic
while toc < 30
    % Ler orientação atual do HeadTracker.
    py_output = step(udpr);
    
    if ~isempty(py_output)
        yaw = str2double(native2unicode(py_output)); % sr~20Hz
    end
    
    idx_pos = dsearchn(sourcePosition, [s_azim + yaw, s_elev]);

    % Obtain a pair of HRTFs at the desired position.
    HRIR = squeeze((hrtfData(idx_pos, :,:)));
    
    % Read audio from file   
    audioIn = sigsrc();
             
    % Apply HRTFs
    audioFiltered(:,1) = FIR{1}(audioIn, HRIR(1,:)); % Left
    audioFiltered(:,2) = FIR{2}(audioIn, HRIR(2,:)); % Right    
    deviceWriter(squeeze(audioFiltered)); 
end
release(udpr)
release(deviceWriter)