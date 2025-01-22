bits = randi([0 1],1000,1);   // It generates a sequence of random binary bits (0s and 1s) of length 1000
s1g = wlanS1GConfig(APEPLength=1000);   // It configures the WLAN S1G parameters, specifying the length of the payload to be transmitted.
preChS1G = wlanWaveformGenerator(bits,s1g);   // It generates the baseband waveform (the signal before passing through the channel) based on the random bits and the configured S1G parameters.
cbw = s1g.ChannelBandwidth;  // It gets the channel bandwidth from the S1G configuration
fs = 2e6;   // It sets the sampling frequency for the channel model. Here, it's set to 2 million samples per second, which matches the channel bandwidth.
tgahChan = wlanTGahChannel('SampleRate',fs,'ChannelBandwidth',cbw, ...   
    'LargeScaleFadingEffect','Pathloss and shadowing', ...
    'DelayProfile','Model-D'); // It creates a TGah channel model. This models how the signal behaves as it travels through the wireless channel, including effects like path loss and shadowing
preChSigPwr_dB = 20*log10(mean(abs(preChS1G)));   // It calculates the signal power in decibels (dB) before passing through the channel.
sigPwr = 10^((preChSigPwr_dB-tgahChan.info.Pathloss)/10);   // It calculates the signal power after adjusting for path loss due to the channel.
chNoise = comm.AWGNChannel('NoiseMethod','Signal to noise ratio (SNR)',...
    'SNR',10,'SignalPower', sigPwr);   // It creates an additive white Gaussian noise (AWGN) channel model with a specified signal-to-noise ratio (SNR) and signal power.
postChS1G = chNoise(tgahChan(preChS1G));   // It simulates the effect of the channel and noise on the signal by passing the pre-channel signal through the TGah channel model and then adding noise.
rxNoise = comm.AWGNChannel('NoiseMethod','Variance', ...
    'VarianceSource','Input port');   // It creates an AWGN channel model for the received signal.
nVar = 10^((-228.6 + 10*log10(290) + 10*log10(fs) + 9)/10);   // It calculates the noise variance based on thermal noise and other factors.
rxS1G = rxNoise(postChS1G,nVar);   // It adds noise to the received signal based on the calculated noise variance.
title = '2 MHz S1G Waveform Before and After TGah Channel';   // It sets the title for the spectrum analyzer.
saScope = spectrumAnalyzer(SampleRate=fs,ShowLegend=true,...
    AveragingMethod='exponential',ForgettingFactor=0.99,Title=title,...
    ChannelNames={'Before','After'});   // It creates a spectrum analyzer object for visualizing the signals before and after passing through the channel.
saScope([preChS1G,rxS1G])   // It plots and compares the spectrum of the signal before and after passing through the TGah channel and adding noise.

