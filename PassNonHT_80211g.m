ssbits = randi([0 1],1000,1);
nht = wlanNonHTConfig;
preChNonHT = wlanWaveformGenerator(bits,nht);
dist = 3;
fc = 2.4e9;
pathLoss = 10^(-log10(4*pi*dist*(fc/3e8)));
fs = 20e6; % Channel model sampling frequency equals the channel bandwidth
maxDoppShift = 3;
trms = 2/fs;
ch802 = comm.RayleighChannel('SampleRate',fs,'MaximumDopplerShift',maxDoppShift,'PathDelays',trms);
postChNonHT = awgn(ch802(preChNonHT),10,'measured');
rxNoise = comm.AWGNChannel('NoiseMethod','Variance', ...
    'VarianceSource','Input port');
nVar = 10^((-228.6 + 10*log10(290) + 10*log10(fs) + 9)/10);

rxNonHT = rxNoise(postChNonHT, nVar)* pathLoss;
title = '20 MHz Non-HT Waveform Before and After 802.11g Channel';
saScope = spectrumAnalyzer(SampleRate=fs,ShowLegend=true,...
    AveragingMethod='exponential',ForgettingFactor=0.99,Title=title,...
    ChannelNames={'Before','After'});
saScope([preChNonHT,rxNonHT])
