% pre-calculate distance equalization filters 
clear; clc
source_radius = [0.15:0.025:0.5, 0.55:0.05:2].';
N_dist = length(source_radius);

ref_dist = 2; % [m] - far-field condition
pos = equiangular_coordinates(1, ref_dist, 0, 0); % como o modelo é esferico elevaçao nao faz diferenca
azim = -sph2nav(pos(:,1));
N_pos = size(pos,1);

ref_pos = pos;
ref_pos(:,3) = ref_dist;
des_pos = pos;


fs = [44100; 48000; 88200; 96000];
N_samples = 512;
temp = zeros(N_samples, N_pos, 2, N_dist);
for f = 1:length(fs)
    for k=1:length(source_radius)
        des_pos(:,3) = source_radius(k);
        sg = [ref_pos;
              des_pos];
          
        ear=[90 0];
        Fs = fs(f);
        h = AKsphericalHead(sg, ear, false, 0.0875,...
                            sg(1,3), 100, N_samples, Fs, 343);
        %Get distance variation functions for left and right ear
        h_freq = fft(h);
        temp(:,:,:,k) = ifft(h_freq(:,N_pos+1:end,:)./h_freq(:,1:N_pos,:));
    end
    distEQ = permute(temp, [3,1,2,4]);
    distEQ = circshift(distEQ, -170, 1);
    size(distEQ)
    %%% save files --------------------------------------------------------
    filename = ['Utils/filters/distEQ_' num2str(fs(f)/1e3) 'kHz.mat'];
    save(filename, 'source_radius', 'distEQ', 'Fs', 'azim')
end

