
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Script Name: HRV_Coherence_Analysis.m
%
% Description:
% This script processes ECG data collected from a participant and their 
% partner during the experiment. It carries out the following steps:
%   1. Loads and visualizes ECG and stimulation data.
%   2. Optionally filters the ECG signals to remove noise.
%   3. Segments the data into baseline, stimulation, and recovery phases.
%   4. Detects R-peaks in the ECG to compute Inter-Beat Intervals (IBIs).
%   5. Cleans IBI time series using a moving median filter.
%   6. Computes standard time-domain HRV features (Mean RR, Mean HR, RMSSD, SDNN).
%   7. Interpolates IBIs to a uniform time base and computes power spectral 
%      density (PSD) using FFT.
%   8. Conducts wavelet-based time-frequency decomposition.
%   9. Calculates inter-subject phase synchrony as a measure of coherence.
%  10. Organizes and saves time-domain, frequency-domain, and time-frequency 
%      features to separate `.mat` files for further analysis.
%
% Input:
% - ECG1Participant.tab: ECG data from participant (column 2).
% - ECG2Partner.tab / ECG_OtherROOM.tab: ECG data from partner.
% - SyncStimulation.tab: Stimulation marker channel.
% - TRIAL_FLOW.tab: Manually loaded trial timing info.
%
% Output:
% - Various `.txt` and `.mat` files containing extracted HRV features.
%
% Requirements:
% - MATLAB Signal Processing Toolbox.
% - Manual selection of condition (support vs. alone).
% - Manual import of TRIAL_FLOW.tab at runtime.
%
% Author: [Your Name]
% Date: [Date or YYYY-MM-DD]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% Import data
load('ECG1Participant.tab')
load('ECG2Partner.tab')
load('ECG_OtherROOM.tab')
load('SyncStimulation.tab')

Time = ECG1Participant(:,1);
Participant = ECG1Participant(:,2);

support = questdlg('Is this the support condition?','Which Condition','Yes','No', 'Yes');

switch support
    case 'Yes'
        Partner = ECG2Partner(:,2);
    case 'No'
        Partner = ECG_OtherROOM(:,2);
end

msgbox('Dont forget to manually import TRIAL_FLOW.tab');


%% Visualise the data
figure(1)
subplot(211)
plot(Time./1000,Participant)
hold on
plot(Time./1000,SyncStimulation(:,2),'r-','linew',3)
plot([TRIALFLOW(:,1) TRIALFLOW(:,1)]'./1000,[zeros(1,6);ones(1,6)*3],'k-','linew',3)
title('Participant Data'),xlabel('time(secs)'),ylabel('Amplitude')

% plot partner data
subplot(212)
plot(Time./1000,Partner)
hold on
plot(Time./1000,SyncStimulation(:,2),'r-','linew',3)
plot([TRIALFLOW(:,1) TRIALFLOW(:,1)]'./1000,[zeros(1,6);ones(1,6)*3],'k-','linew',3)
title('Partner Data'),xlabel('time(secs)'),ylabel('Amplitude')


%% Do you need to filter the data? 
% try filtering at 35 hz if data is contaminated
% FFT of raw ECG signal for participant for inspection

srate = 1000;

ecgx = abs(fft(Participant).^2);
hz   = linspace(0,srate/2,floor(length(Participant)/2)+1);
ecgx = ecgx(1:length(hz));

figure(3)
subplot(211)
plot(hz,ecgx)
title('FFT of participant signal')

ecgxpartner = abs(fft(Partner).^2);
ecgxpartner = ecgx(1:length(hz));

subplot(212)
plot(hz,ecgx)
title('FFT of partner signal')

%% %% low pass filter the data in case of MFS contamination or other noise
% 
% % create low pass filter
srate = 1000;
freq    = 30;
transw  = .1;
shape   = [1 1 0 0];
nyquist = srate/2;
order   = freq*75;
frex    = [0 freq freq+freq*transw nyquist] / nyquist;

filtkern = firls(order,frex,shape);
% visualise filter kernel spectrum
kernpow = abs(fft(filtkern).^2);
hz2     = linspace(0,nyquist,floor(length(filtkern)/2)+1);
kernpow = kernpow(1:length(hz2));

figure(3)
plot(hz2,kernpow)

% filter the signal with zero phase shift filter
Partner = filtfilt(filtkern,1,Partner);
Participant = filtfilt(filtkern,1,Participant);

% % visualise power spectrum of filtered signal
% filtpow = abs(fft(Participant).^2);
% hertz   = linspace(0,nyquist,floor(length(Participant)/2)+1);
% filtpow = filtpow(1:length(hz));
% 
% figure(4)
% plot(hertz,filtpow)

% plot the filtered signals
figure(5)
subplot(211)
plot(Time./1000,Participant)
hold on
plot(Time./1000,SyncStimulation(:,2),'r-','linew',3)
plot([TRIALFLOW(:,1) TRIALFLOW(:,1)]'./1000,[zeros(1,6);ones(1,6)*3],'k-','linew',3)
title('Participant Data'),xlabel('time(secs)'),ylabel('Amplitude')

% plot partner data
subplot(212)
plot(Time./1000,Partner)
hold on
plot(Time./1000,SyncStimulation(:,2),'r-','linew',3)
plot([TRIALFLOW(:,1) TRIALFLOW(:,1)]'./1000,[zeros(1,6);ones(1,6)*3],'k-','linew',3)
title('Partner Data'),xlabel('time(secs)'),ylabel('Amplitude')


%% Break data up into 3 segments - baseline, stimulation and recovery

idx = dsearchn(Time,TRIALFLOW(:,1));
stimdat1 = Participant(idx(3)+1:idx(4));
stimdat2 = Partner(idx(3)+1:idx(4));

synchstim = SyncStimulation(idx(3)+1:idx(4),2);
stimdat1 = stimdat1(synchstim>1.5);
stimdat2 = stimdat2(synchstim>1.5);

data(:,1,1) = Participant(idx(1)+1:idx(2));
data(:,2,1) = stimdat1(1:120000);
data(:,3,1) = Participant(idx(5):idx(6));

data(:,1,2) = Partner(idx(1)+1:idx(2));
data(:,2,2) = stimdat2(1:120000);
data(:,3,2) = Partner(idx(5):idx(6));

timevec = (0:size(data,1)-1);

figure(7)
subplot(231)
plot(timevec,data(:,1,1))
title('participantBase')

subplot(232)
plot(timevec,data(:,2,1))
title('participantStim')

subplot(233)
plot(timevec,data(:,3,1))
title('participantRec')

subplot(234)
plot(timevec,data(:,1,2))
title('PartnerBase')

subplot(235)
plot(timevec,data(:,2,2))
title('PartnerStim')

subplot(236)
plot(timevec,data(:,3,2))
title('PartnerRec')

%% save for Kubios analysis

ParticipantBase = squeeze(data(:,1,1));

ParticipantStim = squeeze(data(:,2,1));

ParticipantRec = squeeze(data(:,3,1));

PartnerBase = squeeze(data(:,1,2));

PartnerStim = squeeze(data(:,2,2));

PartnerRec = squeeze(data(:,3,2));

formatSpec = '%i\r\n';
names = {'ParticipantBase','ParticipantStim','ParticipantRec'...
    'PartnerBase','PartnerStim','PartnerRec'};

for i = 1:6
    
    fileID = fopen([names{i} '.txt'],'w');
    fprintf(fileID,formatSpec,eval(names{i}));
    fclose(fileID);
    
end

%% Convert to z scores

data = (data - mean(data)) ./ std(data);


figure(7)
subplot(231)
plot(timevec,data(:,1,1))
title('participantBase')

subplot(232)
plot(timevec,data(:,2,1))
title('participantStim')

subplot(233)
plot(timevec,data(:,3,1))
title('participantRec')

subplot(234)
plot(timevec,data(:,1,2))
title('PartnerBase')

subplot(235)
plot(timevec,data(:,2,2))
title('PartnerStim')

subplot(236)
plot(timevec,data(:,3,2))
title('PartnerRec')


%% now find peaks in data


prompt = {'Height:','Width:'};
Defaults = {'2.5','250'};
dims = [1 35];
Threshold = inputdlg(prompt,'Choose thresholds for height and width',dims,Defaults);


ht = str2double(Threshold{1});
wdt = str2double(Threshold{2});

peakslocs = struct;

for i = 1:size(data,3)
    
    tempdat = data(:,1,i);
    [vals,locs] = findpeaks(tempdat,timevec,'MinPeakHeight',ht,'minPeakDistance',wdt);
 
    peakslocs(i).baseline = [locs' vals];
    
    tempdat = data(:,2,i);
    [vals,locs] = findpeaks(tempdat,timevec,'MinPeakHeight',ht,'minPeakDistance',wdt);
 
    peakslocs(i).stimulation = [locs' vals];
    
    tempdat = data(:,3,i);
    [vals,locs] = findpeaks(tempdat,timevec,'MinPeakHeight',ht,'minPeakDistance',wdt);
 
    peakslocs(i).recovery = [locs' vals];
end


% plot the identified peaks to make sure its working okay
figure(7)

subplot(231)
plot(timevec,data(:,1,1))
hold on
plot(peakslocs(1).baseline(:,1),peakslocs(1).baseline(:,2),'ro')
title('ParticipantBase')

subplot(232)
plot(timevec,data(:,2,1))
hold on
plot(peakslocs(1).stimulation(:,1),peakslocs(1).stimulation(:,2),'ro')
title('participantStim')

subplot(233)
plot(timevec,data(:,3,1))
hold on
plot(peakslocs(1).recovery(:,1),peakslocs(1).recovery(:,2),'ro')
title('participantRec')

subplot(234)
plot(timevec,data(:,1,2))
hold on
plot(peakslocs(2).baseline(:,1),peakslocs(2).baseline(:,2),'ro')
title('PartnerBase')

subplot(235)
plot(timevec,data(:,2,2))
hold on
plot(peakslocs(2).stimulation(:,1),peakslocs(2).stimulation(:,2),'ro')
title('PartnerStim')

subplot(236)
plot(timevec,data(:,3,2))
hold on
plot(peakslocs(2).recovery(:,1),peakslocs(2).recovery(:,2),'ro')
title('PartnerRec')

%% create ibi time series

ibis = struct;

for i = 1:2
    
        ibis(i).baseline = diff(peakslocs(i).baseline(:,1));
        ibis(i).stimulation = diff(peakslocs(i).stimulation(:,1));
        ibis(i).recovery = diff(peakslocs(i).recovery(:,1));

end

figure(8)
subplot(231)
plot(ibis(1).baseline,'rs-')
title('ParticipantBase')

subplot(232)
plot(ibis(1).stimulation,'rs-')
title('participantStim')

subplot(233)
plot(ibis(1).recovery,'rs-')
title('participantRec')

subplot(234)
plot(ibis(2).baseline,'rs-')
title('PartnerBase')

subplot(235)
plot(ibis(2).stimulation,'rs-')
title('PartnerStim')

subplot(236)
plot(ibis(2).recovery,'rs-')
title('PartnerRec')



%% clean ibi time series

% threshold on secs [0.45-VeryLow; 0.35-Low; .25-Medium; .15-Strong; .05-VeryStrong]
list = {'Very Low - 0.45 sec','Low - 0.35 sec','Medium - 0.25 sec',...
    'Strong - 0.15 sec','Very Strong - 0.05 sec'};
threshoptions = [.45;.35;.25;.15;.05];
[indx,tf] = listdlg('ListString',list);



thresh = threshoptions(indx)*1000;
newibis = struct;
badbeats = struct;
win = 10;

for i = 1:2
    
    tempdat = ibis(i).baseline;
    medfilt = zeros(size(tempdat));
    locmean = zeros(size(tempdat));
    for j = 1:length(tempdat)
        hibnd = min(length(tempdat),j+win);
        lobnd = max(1,j-win);
        medfilt(j) = median(tempdat(lobnd:hibnd));
    end
    
    for k = 1:length(medfilt)
        hibnd = min(length(tempdat),k+win);
        lobnd = max(1,k-win);
        locmean(k) = mean(medfilt(lobnd:hibnd));
    end
    badbeats(i).baseline = abs(locmean-tempdat)>thresh;
    temptime = 1:length(tempdat);
    temptime(badbeats(i).baseline) = [];
    tempdat(badbeats(i).baseline) = [];
    newibis(i).baseline = interp1(temptime,tempdat,1:length(locmean),'spline');
    
    tempdat = ibis(i).stimulation;
    medfilt = zeros(size(tempdat));
    locmean = zeros(size(tempdat));
    for j = 1:length(tempdat)
        hibnd = min(length(tempdat),j+win);
        lobnd = max(1,j-win);
        medfilt(j) = median(tempdat(lobnd:hibnd));
    end
    
    for k = 1:length(medfilt)
        hibnd = min(length(tempdat),k+win);
        lobnd = max(1,k-win);
        locmean(k) = mean(medfilt(lobnd:hibnd));
    end
    badbeats(i).stimulation = abs(locmean-tempdat)>thresh;
    temptime = 1:length(tempdat);
    temptime(badbeats(i).stimulation) = [];
    tempdat(badbeats(i).stimulation) = [];
    newibis(i).stimulation = interp1(temptime,tempdat,1:length(locmean),'spline');
    
    
    tempdat = ibis(i).recovery;
    medfilt = zeros(size(tempdat));
    locmean = zeros(size(tempdat));
    for j = 1:length(tempdat)
        hibnd = min(length(tempdat),j+win);
        lobnd = max(1,j-win);
        medfilt(j) = median(tempdat(lobnd:hibnd));
    end
    
    for k = 1:length(medfilt)
        hibnd = min(length(tempdat),k+win);
        lobnd = max(1,k-win);
        locmean(k) = mean(medfilt(lobnd:hibnd));
    end
    badbeats(i).recovery = abs(locmean-tempdat)>thresh;
    temptime = 1:length(tempdat);
    temptime(badbeats(i).recovery) = [];
    tempdat(badbeats(i).recovery) = [];
    newibis(i).recovery = interp1(temptime,tempdat,1:length(locmean),'spline');
    
end

figure(9)
subplot(231)
plot(ibis(1).baseline,'ks-')
hold on
plot(newibis(1).baseline,'rs-')

subplot(232)
plot(ibis(1).stimulation,'ks-')
hold on
plot(newibis(1).stimulation,'rs-')

subplot(233)
plot(ibis(1).recovery,'ks-')
hold on
plot(newibis(1).recovery,'rs-')

subplot(234)
plot(ibis(2).baseline,'ks-')
hold on
plot(newibis(2).baseline,'rs-')

subplot(235)
plot(ibis(2).stimulation,'ks-')
hold on
plot(newibis(2).stimulation,'rs-')

subplot(236)
plot(ibis(2).recovery,'ks-')
hold on
plot(newibis(2).recovery,'rs-')


%% Calculate time domain features
% Extract Mean RR and HR

TDmeasures = struct;

[TDmeasures.avgRR , TDmeasures.meanHR] = deal(zeros(1,3,2));


for i = 1:2

    TDmeasures.avgRR(1,1,i) = mean(newibis(i).baseline);
    TDmeasures.avgRR(1,2,i) = mean(newibis(i).stimulation);
    TDmeasures.avgRR(1,3,i) = mean(newibis(i).recovery);

end

TDmeasures.meanHR = (60/TDmeasures.avgRR)*1000;

% Detrend the data


for i = 1:2
    
        newibis(i).baseline = detrend(newibis(i).baseline);
        newibis(i).stimulation = detrend(newibis(i).stimulation);
        newibis(i).recovery = detrend(newibis(i).recovery);

end


% Smoothness priors - have to choose params so not really ideal!!!
% dat = smoothness_priors_detrending(interpolated(:,2,2)', 500, 480);

% figure(10)
% subplot(231)
% hold on
% plot(peakslocs(1).baseline(2:end,1),newibis(1).baseline,'ks-')
% 
% subplot(232)
% hold on
% plot(peakslocs(1).stimulation(2:end,1),newibis(1).stimulation,'ks-')
% 
% subplot(233)
% hold on
% plot(peakslocs(1).recovery(2:end,1),newibis(1).recovery,'ks-')
% 
% subplot(234)
% hold on
% plot(peakslocs(2).baseline(2:end,1),newibis(2).baseline,'ks-')
% 
% subplot(235)
% hold on
% plot(peakslocs(2).stimulation(2:end,1),newibis(2).stimulation,'ks-')
% 
% subplot(236)
% hold on
% plot(peakslocs(2).recovery(2:end,1),newibis(2).recovery,'ks-')



TDmeasures.rmssd = zeros(1,3,2);
TDmeasures.sdnn = zeros(1,3,2);


for i = 1:2

    TDmeasures.rmssd(1,1,i) = sqrt(sum(diff(newibis(i).baseline).^2) / numel(newibis(i).baseline)-1);
    TDmeasures.rmssd(1,2,i) = sqrt(sum(diff(newibis(i).stimulation).^2) / numel(newibis(i).stimulation)-1);
    TDmeasures.rmssd(1,3,i) = sqrt(sum(diff(newibis(i).recovery).^2) / numel(newibis(i).recovery)-1);

    TDmeasures.sdnn(1,1,i) = sqrt(sum((newibis(i).baseline-mean(newibis(i).baseline)).^2) / numel(newibis(i).baseline)-1);
    TDmeasures.sdnn(1,2,i) = sqrt(sum((newibis(i).stimulation-mean(newibis(i).stimulation)).^2) / numel(newibis(i).stimulation)-1);
    TDmeasures.sdnn(1,3,i) = sqrt(sum((newibis(i).recovery-mean(newibis(i).recovery)).^2) / numel(newibis(i).recovery)-1);

end


%% interpolate up to 4 hz
N = 480;
[interpolated] = deal(zeros(N,3,2));
interptime = linspace(0,120000,N);

for i = 1:2
    
    tempdat = newibis(i).baseline;
    F = griddedInterpolant(peakslocs(i).baseline(2:end,1),tempdat,'spline');
    interpolated(:,1,i) = F(interptime);
    
    tempdat = newibis(i).stimulation;
    F = griddedInterpolant(peakslocs(i).stimulation(2:end,1),tempdat,'spline');
    interpolated(:,2,i) = F(interptime);
  
    tempdat = newibis(i).recovery;
    F = griddedInterpolant(peakslocs(i).recovery(2:end,1),tempdat,'spline');
    interpolated(:,3,i) = F(interptime);
  
end

figure(10)
subplot(231)
hold on
plot(interptime,interpolated(:,1,1),'rs-')

subplot(232)
hold on
plot(interptime,interpolated(:,2,1),'rs-')

subplot(233)
hold on
plot(interptime,interpolated(:,3,1),'rs-')

subplot(234)
hold on
plot(interptime,interpolated(:,1,2),'rs-')

subplot(235)
hold on
plot(interptime,interpolated(:,2,2),'rs-')

subplot(236)
hold on
plot(interptime,interpolated(:,3,2),'rs-')


%% Compute FFT based PSD

LF = [0.04 0.15];
HF = [0.15 0.4];

% FFT
ibix = (2*abs(fft(interpolated)./ length(interpolated))).^2;
ibixhz = linspace(0,4/2,floor(length(interpolated)/2)+1);
ibix = ibix(1:length(ibixhz),:,:);

LFidxfft = dsearchn(ibixhz',LF');
HFidxfft = dsearchn(ibixhz',HF');

LFpwrfft = sum(ibix(LFidxfft(1):LFidxfft(2),:,:),1);
HFpwrfft = sum(ibix(HFidxfft(1):HFidxfft(2),:,:),1);
ratiofft = LFpwrfft./HFpwrfft;


figure(12)
subplot(231)
plot(ibixhz,ibix(:,1,1))
set(gca,'xlim',[0 .5])
title('FFT Spectrum Participant Baseline')

subplot(232)
plot(ibixhz,ibix(:,2,1))
set(gca,'xlim',[0 .5])
title('FFT Spectrum Participant Stimulation')

subplot(233)
plot(ibixhz,ibix(:,3,1))
set(gca,'xlim',[0 .5])
title('FFT Spectrum Participant Recovery')

subplot(234)
plot(ibixhz,ibix(:,1,2))
set(gca,'xlim',[0 .5])
title('FFT Spectrum Partner Baseline')

subplot(235)
plot(ibixhz,ibix(:,2,2))
set(gca,'xlim',[0 .5])
title('FFT Spectrum Partner Stimulation')

subplot(236)
plot(ibixhz,ibix(:,3,2))
set(gca,'xlim',[0 .5])
title('FFT Spectrum Partner Recovery')



%% Synchronisation analysis

% wavelet parameters
time = -300:1/4:300;
halfwave = (length(time)-1)/2;
minfrex = 0;
maxfrex = .5;
frex = 0:.002:.5;
numfrex = length(frex);
fwhms = 20;
%fwhms = logspace(log10(.5),log10(.5),numfrex);
nkern = length(time);
ndata = size(interpolated,1);
nconv = ndata + nkern - 1;

srate = 4;

% Convolution and phase extraction
[a,b,c] = size(interpolated);
[tf, angles] = deal(zeros(b,a,c,numfrex));

for i = 1:2

    dat4conv = interpolated(:,:,i);
    datax = fft(dat4conv',nconv,2);

    for j = 1:numfrex

        cmw = exp(1i*2*pi*frex(j)*time) .* exp(-4*log(2)*time.^2/fwhms.^2);
        cmwx = fft(cmw,nconv);
        cmwx = cmwx ./ max(cmwx);

        as = ifft(repmat(cmwx,b,1) .* datax,[],2);
        asclipped = as(:,halfwave+1:end-halfwave);

        angles(:,:,i,j) = angle(asclipped);
        tf(:,:,i,j)     = abs(asclipped).^2;


    end

end

Frequenciesofinterest = [0.03, 0.05, 0.08, 0.11, 0.16];
f = dsearchn(frex',Frequenciesofinterest');

clim = [0 1];

figure(14)
subplot(121)
contourf(interptime,frex,squeeze(tf(2,:,1,:))',40,'linecolor','none')
%set(gca,'clim',clim*1500,'ydir','normal')
set(gca,'ydir','normal')
colormap jet, colorbar
xlabel('Time (ms)'), ylabel('Frequency (Hz)')

subplot(122)
plot(ibixhz,ibix(:,2,1))
set(gca,'xlim',[0 .5])
title('FFT Spectrum Participant Stimulation')


anglediffs = squeeze(angles(:,:,2,:) - angles(:,:,1,:));
synch = squeeze(abs(mean(exp(1i*anglediffs),2)));

figure(15)
plot(frex,squeeze(synch(2,:) - synch(1,:)),'linew',2)
hold on
plot(frex,zeros(size(synch,2)),'r-','LineWidth',2)

% figure
% plot(angles(1,:,1,f(end)))
% hold on
% plot(angles(1,:,2,f(end)))
% plot(squeeze(angles(1,:,2,f(end)) - angles(1,:,1,f(end))),'LineWidth',2)
% 
% figure
% plot(angles(2,:,1,f(end)))
% hold on
% plot(angles(2,:,2,f(end)))
% plot(squeeze(angles(2,:,2,f(end)) - angles(2,:,1,f(end))),'LineWidth',2)
% 
% figure
% plot(angles(3,:,1,f(end)))
% hold on
% plot(angles(3,:,2,f(end)))
% plot(squeeze(angles(3,:,2,f(end)) - angles(3,:,1,f(end))),'LineWidth',2)



%% Organise and save features

save('TDmeasures.mat','TDmeasures')
save('newibis','newibis')

FDmeasures = struct;
FDmeasures.interpolated = interpolated;
FDmeasures.interptime = interptime;
FDmeasures.ibix = ibix;
FDmeasures.ibixhz = ibixhz;
save('FDmeasures','FDmeasures')

TFmeasures = struct;
TFmeasures.tf = tf;
TFmeasures.angles = angles;
TFmeasures.frex = frex;
TFmeasures.anglediffs = anglediffs;
TFmeasures.synch = synch;
save('TFmeasures','TFmeasures')




