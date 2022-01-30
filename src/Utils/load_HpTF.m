function [HpIR, H_out, freq] = load_HpTF(filepath, fs)
% Carrega e gera filtro de fase minima para resposta de fones do dataset
%
% ENTRADAS: 
%           filepath: caminho para o txt (ex: 'meu_local/fone/resposta.txt')
%           fs:       amostragem do filtro na saida
% SAIDAS:
%           HpIR:     Headphone imppulse response (filtro de correcao no tempo)
%           H_out:    Resposta do fone
%           freq:     Vetor de frequencias para o filtro 

%% Config
N = 2^15;
freq = linspace(0,fs-fs/N, N);
freq = freq(1:N/2);

%% Load and clean it up
% carregar medicao
raw_file = importdata(filepath);

% selecionar apenas numeros
B = regexp(raw_file{1},'\S*','match');
f = @(a)sscanf(a,'%f;');
x = cellfun(f,B,'UniformOutput',false);

% remover celulas vazias
idx_empty = cell2mat(cellfun(@isempty,x,'UniformOutput',false));
x(idx_empty) = [];
clean_file = cell2mat(x);

% separar vetor de frequencias e magnitude correspondente
k=1:length(clean_file);
idx_freq = logical(rem(k, 2));
freq_vec_raw = clean_file(idx_freq);
freq_mag_raw = clean_file(idx_freq == false).';
freq_mag_smooth = smoothdata(freq_mag_raw, 'sgolay',9);

% Inverter magnitude e janelar na frequencia 
% N_win = length(freq_mag_raw);
% win = tukeywin(N_win, 0.03);
% win(round(N_win/2):end) = 1;
inv_freq_mag_raw = (1./(10.^(freq_mag_smooth./20))); %.* win;
% Gerar vetor no tempo
% remover interpolação para frequencias alem das fornecidas (acima e abaixo)
[~, idx_low] = min(abs(freq - freq_vec_raw(1)));
[~, idx_high] = min(abs(freq - 18e3));

% N_up = 2*length(freq(1:idx_low));
% N_down = 2*length(freq(idx_high:end));
% win_up = hann(N_up);
% win_up = win_up(1:N_up/2);
% 
% win_down = hann(N_down);
% win_down = win_down((N_down/2+1):end);


% Criar amostragem de acordo com a taxa de amostragem desejada 
H = interp1(freq_vec_raw, inv_freq_mag_raw,  freq, 'makima', 'extrap');
H_out = interp1(freq_vec_raw, 10.^(freq_mag_raw./20),  freq, 'makima', 'extrap');

% H(1:idx_low) = 10.^((20*log10(H(1:idx_low)).*win_up')./20);
% H(idx_high:end) = 10.^((20*log10(H(idx_high:end)).*win_down')./20);
H(1:idx_low+1) = H(idx_low+3);
H(idx_high:end) = H(idx_high);

Hmin = get_min_phase(H.', 'linear', 'nonsymmetric');
HpIR = real(ifft(Hmin));


% Cortar RI para tamanho que contenha ate a menor fequencia conhecida
min_sz = ceil(fs/freq_vec_raw(1));
if mod(min_sz, 2) ~= 0
    min_sz = min_sz+1;
end

HpIR(4*min_sz+1:end) = [];

end