%% Load and clean it up
clear ; clc

addpath('Curvas de fones')
fs = 44100; % escolha fs desejada
 % defina o caminho pro com a resposta do fone
filepath = 'Curvas de fones/Shure/SRH440 IF.txt';
% [freq_mag_raw, freq_vec_raw] = load_txt_curvas(filepath)
[HpIR, H, freq] = load_HpTF(filepath, fs);


%% plot -------------------------------------------------------------------
close all
N = length(HpIR);
HpTF = db(abs(fft(HpIR)));
HpTF = HpTF(1:N/2);
freqv = linspace(0,fs-fs/N, N);
freqv = freqv(1:N/2);

hFigure=figure;
semilogx(freq, db(H), 'linewidth', 1.5); hold on
xlim([20 2e4])
ylim([-11 11])

xlabel('Frequency (Hz)');
ylabel('Magnitude ')

semilogx(freqv, HpTF, 'linewidth', 1.5)

legend('HpTF', 'Equalization filter',...
        'location', 'best')
    
set(gca, 'FontSize', 12)   
% time plot
% subplot(212)
% tx = 0: 1/fs: (N-1)/fs;
% plot(tx,   HpIR)    
%     xlim([0 0.003])
%     ylim([-1 1])
xticks([20 100 1000 1e4 2e4])
xticklabels({'20', '100', '1k', '10k', '20k'})
% arruma_fig('% 1.0f','% 2.0f')



filename = [pwd, '/Images/HpTF.pdf' ];
exportgraphics(hFigure,filename,'BackgroundColor','none','ContentType','vector')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%