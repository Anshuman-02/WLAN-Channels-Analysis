bits = randi([0 1],1000,1);
ht = wlanHTConfig;
preChHT = wlanWaveformGenerator(bits,ht);
fs = 20e6; % Channel model sampling frequency equals the channel bandwidth
tgnChan = wlanTGnChannel('SampleRate',fs,'LargeScaleFadingEffect', ...
    'Pathloss and shadowing','DelayProfile','Model-F');
postChHT = awgn(tgnChan(preChHT),10,'measured');
rxNoise = comm.AWGNChannel('NoiseMethod','Variance', ...
    'VarianceSource','Input port');
nVar = 10^((-228.6 + 10*log10(290) + 10*log10(fs) + 9)/10);

rxHT = rxNoise(postChHT, nVar);
title = '20 MHz HT Waveform Before and After TGn Channel';
saScope = spectrumAnalyzer(SampleRate=fs,ShowLegend=true,...
    AveragingMethod='exponential',ForgettingFactor=0.99,Title=title,...
    ChannelNames={'Before','After'});
saScope([preChHT,postChHT])
