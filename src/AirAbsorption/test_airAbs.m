clc; clear all;
% test distnce variation influencce in air absorption coef
addpath('D:\Documentos\1 - Work\Individualized_HRTF_Synthesis\Functions')

N = 200; % number of samples 
fs = 44100;
freq = linspace(0, fs-fs/N,N)';
for k = 1:N
    [~, alpha_iso(k,1), ~, ~]=air_absorption(freq(k));
end
dist= 15;
alpha = (dist*alpha_iso);
alpha(:,2) = alpha(:,1);
hFigure =figure();
plot(freq(1:N/2), alpha(1:N/2,1), 'r', 'linewidth', 2)
xlabel('Frequência (Hz)')
ylabel('Atenuação (dB)')
xlim([0 freq(N/4)])
grid on
set(gca, 'fontsize', 13)
% arruma_fig('% 4.0f','% 2.1f','virgula')

filename = [pwd, '/ISOairabs.pdf' ];
% exportgraphics(hFigure,filename,'BackgroundColor','none','ContentType','vector')

%% Carregar HRTF 
Obj = SOFAload('..\individuo_141.sofa');
[itd, Obj] = SOFAgetITD(Obj);
ir = shiftdim(Obj.Data.IR, 2);

%% Generate filters 

% N — Filter order for FIR filters and the numerator and denominator orders for IIR filters.
% F — Frequency vector. Frequency values in specified in F indicate locations where you provide specific filter response amplitudes.
% A — Amplitude vector. Values in A define the filter amplitude at frequency points you specify in f, the frequency vecto
tic
order = 50;
f = freq(1:N/2)./max(freq(1:N/2));
d = fdesign.arbmag('N,F,A',order, f , 10.^(-alpha(1:N/2,1)./20));
Hd = design(d,'freqsamp','SystemObject',true);
toc
% fvtool(Hd,'MagnitudeDisplay','Zero-phase','Color','White');
x = ir(:,1,1);
out = Hd(x);


%% plot
xf = db(abs(fft(x)));
outf = db(abs(fft(out)));
N = length(x);
fqq = linspace(0, fs-fs/N, N);


plot(fqq, xf);hold on 
plot(fqq, outf);
legend(['original'; 'filtered'])

%%
function y = fast_conv(x1, x2)
            nfft = length(x1) + length(x2) - 1;
            y = real(ifft(fft(x1, nfft).*fft(x2, nfft)));
end
