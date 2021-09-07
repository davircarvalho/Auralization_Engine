% Find the end of the impulse response and truncate it
% Lundeby, Virgran, Bietz and Vorlaender - Uncertainties of Measurements in Room Acoustics - ACUSTICA Vol. 81 (1995)
% Adapted from ITA_TOOLBOX 
function [Obj,idx_cut] = truncate_IR(Obj)
%% Initialization and Input Parsing
% sz = size(Obj.Data.IR);
% dimorder = length(sz):-1:1;
% IR = permute(Obj.Data.IR, dimorder);
convention = Obj.GLOBAL_SOFAConventions;
if strcmpi(convention, 'MultiSpeakerBRIR')  % MultiSpeakerBRIR
    IR = permute(Obj.Data.IR, [4,3,2,1]);
else
    IR = shiftdim(Obj.Data.IR,2);
end
fs = Obj.Data.SamplingRate;

for k = 1:size(IR,3)
timeData = IR(:,:,k,1);

%%
[nSamples, nChannels] = size(timeData);
% freqVec        = ones(nChannels,1);
freqDepWinTime = ones(nChannels,1) * 0.03; % broadband: use 30 ms windows sizes

freqDepWinTime = freqDepWinTime / 5;

%%
rawTimeData = timeData.^2;
% [ revT, noiseLevel, intersectionTime, noisePeakLevel]   = deal(nan(nChannels,1));
trackLength = nSamples/fs;


%%
nPartsPer10dB            =  5;   % time intervals per 10 dB decay. lundeby: 3 ... 10
dbAboveNoise             = 10;   % end of regression 5 ... 10 dB
useDynRangeForRegression = 20 ;  % 10 ... 20 dB
cut_point                = 0;

for iChannel = 1:nChannels
    
    % 1) smooth
    nSamplesPerBlock = round(freqDepWinTime(iChannel)* fs);
    timeWinData      = squeeze(sum(reshape(...
                        rawTimeData(1:floor(nSamples/nSamplesPerBlock)*...
                        nSamplesPerBlock,iChannel),...
                        nSamplesPerBlock,...
                        floor(nSamples/nSamplesPerBlock) ,1),1)).'/...
                        nSamplesPerBlock;
    timeVecWin       = (0:size(timeWinData,1)-1).'*nSamplesPerBlock/fs;
    
    % 2) estimate noise
    noiseEst = mean(timeWinData(end-round(size(timeWinData,1)/10) :end,:))+realmin;
    
    % 3) regression

    [del, startIdx] = max(timeWinData);
    stopIdx = find(10*log10(timeWinData(startIdx+1:end)) > 10*log10(noiseEst)+ dbAboveNoise, 1, 'last') + startIdx;
%     stopIdx = find(10*log10(timeWinData(startIdx+1:end)) < 10*log10(noiseEst)+ dbAboveNoise, 1, 'first') + startIdx;


    dynRange = diff(10*log10(timeWinData([startIdx stopIdx])));
    
    if isempty(stopIdx) || (stopIdx == startIdx) || dynRange > -5 
        ita_verbose_info('Regression did not work due to low SNR, continuing with next channel/band',1);
        continue;
    end
    
    
    X = [ones(stopIdx-startIdx+1,1) timeVecWin(startIdx:stopIdx)]; % X*c = edc
    c = X\(10*log10(timeWinData(startIdx:stopIdx)));
    
    if c(2) == 0 || any(isnan(c))
        ita_verbose_info('Regression did not work due, T would be Inf, setting to 0, continuing with next channel/band',1);
        continue;
    end
    
    % 4) preliminary crossing point
    crossingPoint = (10*log10(noiseEst) - c(1)) / c(2);
    if crossingPoint > (trackLength)  * 2 
        continue
    end
    
    % 5) new local time interval length
    nBlocksInDecay   = diff(10*log10(timeWinData([startIdx stopIdx]))) / -10 * nPartsPer10dB;
    nSamplesPerBlock = round(diff(timeVecWin([startIdx stopIdx])) / nBlocksInDecay * fs);
    
    % 6) average
    timeWinData = squeeze(sum(reshape(rawTimeData(1:floor(nSamples/nSamplesPerBlock)*nSamplesPerBlock,iChannel), nSamplesPerBlock,floor(nSamples/nSamplesPerBlock) ,1),1)).'/nSamplesPerBlock;
    timeVecWin = (0:size(timeWinData,1)-1).'*nSamplesPerBlock/fs;
    [del, idxMax] = max(timeWinData);
    
    
    oldCrossingPoint = 11+crossingPoint; % high start value to enter while-loop
    loopCounter = 0;
    
    while(abs(oldCrossingPoint-crossingPoint) > 0.01)
        % 7) estimate backgroud level
        correspondingDecay = 10;  % 5...10 dB
        idxLast10percent        = round(size(timeWinData,1)*0.9);
        idx10dBBelowCrosspoint  = max(1,round( (crossingPoint - correspondingDecay ./ c(2)) * fs / nSamplesPerBlock));
        noiseEst                = mean(timeWinData(min(idxLast10percent,idx10dBBelowCrosspoint ):end,:)) +realmin;
        
        % 8) estimate late decay slope
        startIdx = find(10*log10(timeWinData(idxMax:end)) < 10*log10(noiseEst)+ dbAboveNoise + useDynRangeForRegression, 1, 'first') + idxMax - 1;
        if isempty(startIdx)
            startIdx = 1;
        end
        stopIdx  = find(10*log10(timeWinData(startIdx+1:end)) < 10*log10(noiseEst)+ dbAboveNoise, 1, 'first')           + startIdx;
        if isempty(stopIdx)
            ita_verbose_info('Regression did not work due to low SNR, continuing with next channel/band',1);
            break;
        end
        X = [ones(stopIdx-startIdx+1,1) timeVecWin(startIdx:stopIdx)]; % X*c = edc
        c = X\(10*log10(timeWinData(startIdx:stopIdx)));
        
        if c(2) >= 0
            ita_verbose_info('Regression did not work due, T would be Inf, setting to 0, continuing with next channel/band',1);
            c(2) = Inf;
            break;
        end
        
        % 9) find croosspoint
        oldCrossingPoint = crossingPoint;
        crossingPoint = (10*log10(noiseEst) - c(1)) / c(2); 
        
        cut_point = (cut_point+crossingPoint)/2;
    end
end
end

%%
idx_cut = round(cut_point*fs);
if mod(idx_cut,2) ~= 0
    idx_cut = idx_cut+1;
end

% Actually cut it
IR_cut = IR;
try % Smooth the tail
    IR_cut(idx_cut+25:end,:,:,:) = [];    
    win = blackmanharris(100); % generate window
    win(1:50) =[];% keep only the decay
    IR_cut(idx_cut-25:end,:,:,:) = IR_cut(idx_cut-25:end,:,:,:).*win;
catch % Truncate
    IR_cut(idx_cut+1:end,:,:,:) = [];
end


if strcmpi(convention, 'MultiSpeakerBRIR')  % MultiSpeakerBRIR
    Obj.Data.IR = permute(IR_cut, [4,3,2,1]);
else
    Obj.Data.IR = shiftdim(IR_cut, 1); %% Devolve ao objeto 
end

Obj = SOFAupdateDimensions(Obj);
% Obj.Data.IR = permute(IR_hp_lp, dimorder); %% Devolve ao objeto 
end


%% 
% tx = 0:1/fs:(nSamples-1)/fs;
% plot(tx, timeData); hold on 
% xline(cut_point)