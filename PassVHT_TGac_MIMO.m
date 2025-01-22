ssbits = randi([0 1],1000,1);
ntx = 4;
nsts = 3;
nrx = 3;
vht = wlanVHTConfig('NumTransmitAntennas',ntx, ...
    'NumSpaceTimeStreams',nsts,'SpatialMapping','Hadamard');
preChVHT = wlanWaveformGenerator(bits,vht);
cbw = vht.ChannelBandwidth;
fs = 80e6; % Channel model sampling frequency equals the channel bandwidth
tgacChan = wlanTGacChannel('SampleRate',fs,'ChannelBandwidth',cbw,...
    'NumTransmitAntennas',ntx,'NumReceiveAntennas',nrx);
tgacChan.LargeScaleFadingEffect = 'None';
postChVHT = awgn(tgacChan(preChVHT),10,'measured');
rxNoise = comm.AWGNChannel('NoiseMethod','Variance', ...
    'VarianceSource','Input port');
nVar = 10^((-228.6 + 10*log10(290) + 10*log10(fs) + 9)/10);

rxVHT = rxNoise(postChVHT,nVar);
title = '80 MHz VHT 4x3 MIMO Waveform After TGac Channel';
saScope = spectrumAnalyzer(SampleRate=fs,ShowLegend=true,...
    AveragingMethod='exponential',ForgettingFactor=0.99,Title=title,...
    ChannelNames={'RX1','RX2','RX3'});
saScope(rxVHT)
