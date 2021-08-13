%% Load and clean it up
clear ; clc

addpath('Curvas de fones')
fs = 44100; % escolha fs desejada
 % defina o caminho pro com a resposta do fone
filepath = 'Curvas de fones/AKG/K167 Tiesto IF.txt';

[HpIR, H, freq] = load_HpTF(filepath, fs);


%% plot -------------------------------------------------------------------

HpTF = db(abs(fft(HpIR)));
HpTF = HpTF(1:length(HpIR)/2);

figure;
semilogx(freq, db(H)); hold on
xlim([freq(2) freq(end)])
ylim([-15 15])

xlabel('Frequency (Hz)');
ylabel('Magnitude ')

semilogx(freq, HpTF)

legend('Headphone response', 'Implemented filter',...
        'location', 'best')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%