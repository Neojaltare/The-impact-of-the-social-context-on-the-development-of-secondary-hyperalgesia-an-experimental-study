
%% now rearrange data for the analysis
% load the integrated data
Data = IntegratedData;
Intensity = Data;

% check for outliers

boxplot(table2array(Intensity(:,[7:12])))
boxplot(table2array(Intensity(:,[17:28])))

removed = Intensity;

Arm = {'Control';'MFS'};
Time = {'T1';'T1';'T2';'T2'};
Baselineratings = Intensity(:,[7,9]);
Intensity(:,[7,9]) = [];

% Intensity Ratings
Intensity = stack(Intensity,{'MeanT1_Intensity_Control_Arm','MeanT1_Intensity_MFS_Arm'...
    'MeanT2_Intensity_Control_Arm','MeanT2_Intensity_MFS_Arm'},'NewDataVariableName','IntensityRatings',...
          'IndexVariableName','Cond');
Intensity.Arm = nominal(repmat(Arm,[size(Intensity,1)/size(Arm,1),1]));
Intensity.Time = nominal(repmat(Time,[size(Intensity,1)/size(Time,1),1]));
Intensity.Condition = nominal(Intensity.Condition);
Intensity.Participant = nominal(Intensity.Participant);

Baselineratings = stack(Baselineratings,{'MeanT0_Intensity_Control_Arm','MeanT0_Intensity_MFS_Arm'},'NewDataVariableName',"BaselineRatings",'IndexVariableName','BaseCondition');
Baselineratings = reshape(table2array(Baselineratings(:,"BaselineRatings")),[2,height(Baselineratings)/2]);
Baselineratings = repmat(Baselineratings,[2,1]);
Baselineratings = Baselineratings(:);
Intensity.Baselineratings = Baselineratings;

Intensity(:,[7,8,10,15,16,17,18,19,20,21,22,26,27]) = [];

Intensity.IntensityRatings(Intensity.ParticipantID==20)=nan;
Intensity.Baselineratings(Intensity.ParticipantID==20)=nan;


writetable(Intensity,'IntensityOR.xls')

Intensityresult = fitlme(Intensity,'IntensityRatings ~ Baselineratings + Arm*Time*Condition + (1|Participant)',DummyVarCoding='effects')
anova(Intensityresult)

Intensityresult = fitlme(Intensity,'Mean_MFS_Intensity ~ Condition + (1|Participant)',DummyVarCoding='effects')
anova(Intensityresult)

%% Unpleasantness Ratings

Unpleasantness = Data;

Arm = {'Control';'MFS'};
Time = {'T1';'T1';'T2';'T2'};

Baselineratings = Unpleasantness(:,[8,10]);

Unpleasantness(:,[8,10]) = [];

Unpleasantness = stack(Unpleasantness,{'MeanT1_Unpleasantness_Control_Arm','MeanT1_Unpleasantness_MFS_Arm'...
    'MeanT2_Unpleasantness_Control_Arm','MeanT2_Unpleasantness_MFS_Arm'},'NewDataVariableName','UnpleasantnessRatings',...
          'IndexVariableName','Cond');
Unpleasantness.Arm = nominal(repmat(Arm,[size(Unpleasantness,1)/size(Arm,1),1]));
Unpleasantness.Time = nominal(repmat(Time,[size(Unpleasantness,1)/size(Time,1),1]));
Unpleasantness.Condition = nominal(Unpleasantness.Condition);
Unpleasantness.Participant = nominal(Unpleasantness.Participant);

Baselineratings = stack(Baselineratings,{'MeanT0_Unpleasantness_Control_Arm','MeanT0_Unpleasantness_MFS_Arm'},'NewDataVariableName',"BaselineRatings",'IndexVariableName','BaseCondition');
Baselineratings = reshape(table2array(Baselineratings(:,"BaselineRatings")),[2,height(Baselineratings)/2]);
Baselineratings = repmat(Baselineratings,[2,1]);
Baselineratings = Baselineratings(:);
Unpleasantness.Baselineratings = Baselineratings;

Unpleasantness(:,[7,8,9,15,16,17,18,19,20,21,22,26,27]) = [];

% Remove outliers
Unpleasantness.UnpleasantnessRatings(Unpleasantness.ParticipantID==6)=nan;
Unpleasantness.UnpleasantnessRatings(Unpleasantness.ParticipantID==19)=nan;
Unpleasantness.UnpleasantnessRatings(Unpleasantness.ParticipantID==20)=nan;

Unpleasantness.Baselineratings(Unpleasantness.ParticipantID==6)=nan;
Unpleasantness.Baselineratings(Unpleasantness.ParticipantID==19)=nan;
Unpleasantness.Baselineratings(Unpleasantness.ParticipantID==20)=nan;

writetable(Unpleasantness,'UnpleasantnessOR.xls')

Unpleasantnessresult = fitlme(Unpleasantness,'UnpleasantnessRatings ~ Baselineratings + Condition*Arm*Time + (1|Participant)',DummyVarCoding='effects')
anova(Unpleasantnessresult)

Unpleasantnessresult = fitlme(Unpleasantness,'Mean_MFS_Unpleasantness ~ Condition + (1|Participant)',DummyVarCoding='effects')
anova(Unpleasantnessresult)

%% Area 

Area = Data;

toexclude = 46612;

surfaceareaT1 = (Area.Area_Length_T1 .* Area.Area_Width_T1)/2;
surfaceareaT2 = (Area.Area_Length_T2 .* Area.Area_Width_T2)/2;

Area.surfaceareaT1 = surfaceareaT1;
Area.surfaceareaT2 = surfaceareaT2;

Area.Area_Length_T1(isnan(Area.MeanT1_Intensity_Control_Arm)) = nan;
Area.Area_Length_T2(isnan(Area.MeanT1_Intensity_Control_Arm)) = nan;
Area.Area_Width_T1(isnan(Area.MeanT1_Intensity_Control_Arm)) = nan;
Area.Area_Width_T2(isnan(Area.MeanT1_Intensity_Control_Arm)) = nan;

Area.surfaceareaT1(isnan(Area.MeanT1_Intensity_Control_Arm)) = nan;
Area.surfaceareaT2(isnan(Area.MeanT1_Intensity_Control_Arm)) = nan;


Arealength = stack(Area,{'Area_Length_T1','Area_Length_T2'},'NewDataVariableName','AreaLength',...
          'IndexVariableName','Time');
Arealength(:,[7,8,9,10,17,18,19,20,21,22,23,24,25,26,30,31]) = [];

Arealength.AreaLength(Arealength.ParticipantID==toexclude) = nan;

writetable(Arealength,'ArealengthOR.xls')

AreaWid = stack(Area,{'Area_Width_T1','Area_Width_T2'},'NewDataVariableName','AreaWidth',...
          'IndexVariableName','Time');
AreaWid(:,[7,8,9,10,17,18,19,20,21,22,23,24,25,26,30,31]) = [];

AreaWid.AreaWidth(AreaWid.ParticipantID==toexclude) = nan;

writetable(AreaWid,'AreawidthOR.xls')

SurfaceArea = stack(Area,{'surfaceareaT1','surfaceareaT2'},'NewDataVariableName','SurfaceArea',...
          'IndexVariableName','Time');
SurfaceArea(:,[7,8,9,10,17,18,19,20,21,22,23,24,25,26,27,28,32,33]) = []; 

SurfaceArea.SurfaceArea(SurfaceArea.ParticipantID==toexclude) = nan;


writetable(SurfaceArea,'SurfaceAreaOR.xls')

Lengthresult = fitlme(Arealength,'AreaLength ~ Condition*Time + (1|Participant)',DummyVarCoding='effects')
anova(Lengthresult)

Widthresult = fitlme(AreaWid,'AreaWidth ~ Condition*Time + (1|Participant)',DummyVarCoding='effects')
anova(Widthresult)

Surfaceresult = fitlme(SurfaceArea,'SurfaceArea ~ Condition*Time + (1|Participant)',DummyVarCoding='effects')
anova(Surfaceresult)

%% RMSSD

% first clean the RMSSD data based on the notes
% These are all partner data 

RMSSD.PartnerStim(25) = nan; RMSSD.Number(25), RMSSD.Condition(25)
RMSSD.PartnerStim(25) = nan; RMSSD.Number(25), RMSSD.Condition(25)
RMSSD.PartnerBase(27) = nan; RMSSD.Number(27), RMSSD.Condition(27)
RMSSD.PartnerStim(27) = nan; RMSSD.Number(27), RMSSD.Condition(27)
RMSSD.PartnerRec(27) = nan;  RMSSD.Number(27), RMSSD.Condition(27)


boxplot(table2array(RMSSD(:,[1:6])))

participanttoexclude =  [1,54,46,45,65];
partnertoexclude = [39,57,14,35];

RMSSD.ParticipantBase([46,45,1,54]) = nan; RMSSD.Number([46,45,1,54]), RMSSD.Condition([46,45,1,54])
RMSSD.ParticipantStim([45,46,65]) = nan;   RMSSD.Number([45,46,65]),   RMSSD.Condition([45,46,65])
RMSSD.ParticipantRec(participanttoexclude) = nan;

RMSSD.PartnerBase(partnertoexclude) = nan;
RMSSD.PartnerStim(partnertoexclude) = nan;
RMSSD.PartnerRec(partnertoexclude) = nan;
% Now organise the data

RMSSD.Number = str2double(RMSSD.Number);
columns = {'Anxiety','Avoidance','Avomycalc','totalPCS','PCSrumination','PCSmagnification','PCShelplessness','totalDAS','DASconsensus','DASsatisfaction','DAScohesion'};

tempdata = zeros(height(RMSSD),length(columns));

for i = 1:height(RMSSD)

    id = RMSSD.Number(i);
    
    for j = 1:length(columns)

    eval(char(strcat('tempdata(i,j) = mean(Data.', columns(j),'(Data.ParticipantID==id));')));

    end

end

tempdata = array2table(tempdata,"VariableNames",columns);

RMSSD = [RMSSD tempdata];

RMSSDParticipant = stack(RMSSD,{'ParticipantBase','ParticipantStim','ParticipantRec'},'NewDataVariableName','RMSSD',...
          'IndexVariableName','Time');

RMSSDParticipant.Condition(RMSSDParticipant.Condition == 'Alone' | RMSSDParticipant.Condition == 'alone') = 'Alone';
% RMSSDParticipant = stack(RMSSD,{'ParticipantBase','ParticipantStim'},'NewDataVariableName','RMSSD',...
%           'IndexVariableName','Time');

RMSSDPartner = stack(RMSSD,{'PartnerBase','PartnerStim','PartnerRec'},'NewDataVariableName','RMSSD',...
          'IndexVariableName','Time');

writetable(RMSSDParticipant,'RMSSDParticipantnew.xls')
writetable(RMSSDPartner,'RMSSDPartnerOR.xls')

RMSSDresult = fitlme(RMSSDParticipant,'RMSSD ~ Time*Condition + (1|Number)',DummyVarCoding='effects')
anova(RMSSDresult)


% Double check the RMSSD data for who is missing


numel(unique(RMSSDParticipantOR.Number)) % number of unique participant numbers

% who is missing and which condition

array2table([RMSSDParticipantOR.Number(isnan(RMSSDParticipantOR.RMSSD))]) 
ans.cond = RMSSDParticipantOR.Condition(isnan(RMSSDParticipantOR.RMSSD))


%% Synchronisation Analyses

% Pipeline: First look at the notes to figure our which subjects and
% conditions to exclude

% Then plot all the remaining FFts and see which ones are reliable so that
% you can still exclude them from the average plotting of the ffts. Then
% plot the average to see what peaks you can identify. After identifying
% peaks, use those to define frequencies of interest. 

%% Load the data

load('TF.mat')
load('FD.mat')

% Exclude relevant participants

subjectstoexclude = array2table...
({'00007Support', 'Partner', 'stim';
  '00013Alone', 'Partner', 'stim';
  '00015Support', 'Partner', 'stim';
  '00017Alone', 'Partner', 'all';
  '00018Alone', 'Partner', 'all';
  '36850Alone', 'Partner', 'base';
  '41401Alone', 'Partner', 'all';
  '42577Support', 'Partner', 'all';
  '46219Support', 'Participant', 'stim'});



for i = 1:height(subjectstoexclude)
    toexclude = char(table2array(subjectstoexclude(i,1)));
    excloc = strfind(lower(FD.Id),lower(toexclude));
    excidx = find(~cellfun(@isempty,excloc));

    if strcmp(char(table2array(subjectstoexclude(i,2))),'Partner')
        person = 2;
    elseif strcmp(char(table2array(subjectstoexclude(i,2))),'Participant')
        person = 1;
    end

    if strcmp(char(table2array(subjectstoexclude(i,3))),'base')
        FD.ibix(:,1,person,excidx) = nan;
    elseif strcmp(char(table2array(subjectstoexclude(i,3))),'stim')
        FD.ibix(:,2,person,excidx) = nan;
    elseif strcmp(char(table2array(subjectstoexclude(i,3))),'rec')
        FD.ibix(:,3,person,excidx) = nan;
    elseif strcmp(char(table2array(subjectstoexclude(i,3))),'all')
        FD.ibix(:,:,person,excidx) = nan;
    end

end



% now exclude relevant participants in the TF data

for i = 1:height(subjectstoexclude)
    toexclude = char(table2array(subjectstoexclude(i,1)));
    excloc = strfind(lower(TF.Id),lower(toexclude));
    excidx = find(~cellfun(@isempty,excloc));

    if strcmp(char(table2array(subjectstoexclude(i,2))),'Partner')
        person = 2;
    elseif strcmp(char(table2array(subjectstoexclude(i,2))),'Participant')
        person = 1;
    end

    if strcmp(char(table2array(subjectstoexclude(i,3))),'base')
        TF.synch(1,:,excidx) = nan;
        TF.anglediffs(1,:,:,excidx) = nan;
        TF.tf(1,:,person,:,excidx) = nan;
        TF.angles(1,:,person,:,excidx) = nan;

    elseif strcmp(char(table2array(subjectstoexclude(i,3))),'stim')
        TF.synch(2,:,excidx) = nan;
        TF.anglediffs(2,:,:,excidx) = nan;
        TF.tf(2,:,person,:,excidx) = nan;
        TF.angles(2,:,person,:,excidx) = nan;

    elseif strcmp(char(table2array(subjectstoexclude(i,3))),'rec')
        TF.synch(3,:,excidx) = nan;
        TF.anglediffs(3,:,:,excidx) = nan;
        TF.tf(3,:,person,:,excidx) = nan;
        TF.angles(3,:,person,:,excidx) = nan;

    elseif strcmp(char(table2array(subjectstoexclude(i,3))),'all')
        TF.synch(:,:,excidx) = nan;
        TF.anglediffs(:,:,:,excidx) = nan;
        TF.tf(:,:,person,:,excidx) = nan;
        TF.angles(:,:,person,:,excidx) = nan;

    end


end

%% Run cluster analysis for FFt data
% aloneidx = strfind(lower(FD.Id),'alone');
% supportidx = strfind(lower(FD.Id),'support');
% alonecondition = find(~cellfun(@isempty,aloneidx));
% supportcondition = find(~cellfun(@isempty,supportidx));
% 
% Aloneid = char(TF.Id(alonecondition)');
% Aloneid = string(Aloneid(:,1:5));
% 
% Supportid = char(TF.Id(supportcondition)');
% Supportid = string(Supportid(:,1:5));
% 
% AloneFD = squeeze(FD.ibix(:,2,1,alonecondition));
% SupportFD = squeeze(FD.ibix(:,1:2,:,supportcondition));
% 
% Supportpartic = squeeze(SupportFD(:,:,1,:));
% Supportpartner = squeeze(SupportFD(:,:,2,:));
% 
% Supportavg = (Supportpartner + Supportpartic) / 2;
% Supportbaseline = squeeze(Supportavg(:,1,:));
% Supportstimulation = squeeze(Supportavg(:,2,:));
% 
% 
% Supportbasenans = any(isnan(Supportbaseline),1);
% Supportstimnans = any(isnan(Supportstimulation),1);
% nans = logical(Supportbasenans + Supportstimnans);
% 
% Supportbaseline(:,nans) = [];
% Supportstimulation(:,nans) = [];
% Supportid(nans) = [];
% 
% % Run permutation between all averaged baseline vs stimulation
% 
% [FDclusts, FDp_vals, FDt_sums, FDperm_dist ] = permutest(Supportstimulation,Supportbaseline,[],0.05,5000,true,[]);
% 
% figure
% plot(FD.ibixhz,mean(Supportbaseline,2))
% hold on
% plot(FD.ibixhz,nanmean(Supportstimulation,2))
% plot([FD.ibixhz(FDclusts{1});FD.ibixhz(FDclusts{1})],get(gca,'ylim'),'r-')
% legend('baseline','stimulation')
% xlim([0 .5])
% 

%% Synchronisation Analysis

aloneidx = strfind(lower(TF.Id),'alone');
supportidx = strfind(lower(TF.Id),'support');
alonecondition = find(~cellfun(@isempty,aloneidx));
supportcondition = find(~cellfun(@isempty,supportidx));

Aloneid = char(TF.Id(alonecondition)');
Aloneid = string(Aloneid(:,1:5));

Supportid = char(TF.Id(supportcondition)');
Supportid = string(Supportid(:,1:5));

Alonesynch = TF.synch(:,:,alonecondition);
Supportsynch = TF.synch(:,:,supportcondition);

figure(2)
plot(FD.ibixhz,squeeze(nanmean(FD.ibix(:,2,1,supportcondition),4)))
hold on
plot(FD.ibixhz,squeeze(nanmean(FD.ibix(:,2,1,alonecondition),4)))
legend('Support','Alone')
xlim([0 .5])


% %% Run mixed model analysis
% 
% Freqsofint = FD.ibixhz([FDclusts{1} FDclusts{2}]);
% Freqidx = dsearchn(TF.frex',Freqsofint');
% 
% % Organize synch data for mixed models
% 
% pvals = zeros(size(Freqsofint));
% alovssupps = zeros(size(Freqsofint));
% 
% for i = 1:length(Freqidx)
% 
%     Talone = array2table(squeeze(Alonesynch(:,Freqidx(i),:))',"VariableNames",{'Baseline','Stimulation','Recovery'});
%     Talone.group = repmat(nominal('Alone'),height(Talone),1);
%     Talone.id = Aloneid;
%     Talone.Recovery = [];
% 
%     Tsupport = array2table(squeeze(Supportsynch(:,Freqidx(i),:))',"VariableNames",{'Baseline','Stimulation','Recovery'});
%     Tsupport.group = repmat(nominal('Support'),height(Tsupport),1);
%     Tsupport.id = Supportid;
%     Tsupport.Recovery = [];
% 
%     T = [Tsupport;Talone];
% 
%     synchresult = fitlme(T,'Stimulation ~ Baseline + group + (1|id)','DummyVarCoding','effects');
%     myres = anova(synchresult);
% 
%     alovssupps(i) = myres.pValue(2);
% 
%     Sup = stack(Tsupport,{'Baseline','Stimulation'},"NewDataVariableName",'Synch','IndexVariableName','Condition');
% 
%     synchresult = fitlme(Sup,'Synch ~ Condition + (1|id)','DummyVarCoding','effects');
%     myres = anova(synchresult);
% 
%     pvals(i) = myres.pValue(2);
% 
% end
% 
%     
% sigfrex = Freqsofint(pvals<0.08);
% sigfrex2 = Freqsofint(alovssupps<0.08);
% 
% figure(4)
% plot(TF.frex,nanmean(squeeze(Supportsynch(1,:,:)),2))
% hold on
% plot(TF.frex,nanmean(squeeze(Supportsynch(2,:,:)),2))
% plot([sigfrex;sigfrex],get(gca,'ylim'),'r-','LineWidth',2)
% legend('Baseline','Stimulation','Sigfrex')
% 
% figure(5)
% plot(FD.ibixhz,squeeze(nanmean(FD.ibix(:,2,1,supportcondition),4)))
% hold on
% plot(FD.ibixhz,squeeze(nanmean(FD.ibix(:,2,1,alonecondition),4)))
% legend('Support','Alone')
% xlim([0 .5])
% plot([sigfrex;sigfrex],get(gca,'ylim'),'r-','LineWidth',2)

    
%% cluster based test
% first compare the conditions and make sure the same participants data is
% in both conditions

notinsupport=find(~ismember(Aloneid,Supportid));

Aloneid(notinsupport) = [];
Alonesynch(:,:,notinsupport) = [];


% exclude nan value participants

supportbase = squeeze(Supportsynch(1,:,:))';
supportstim = squeeze(Supportsynch(2,:,:))';

alonebase = squeeze(Alonesynch(1,:,:))';
alonestim = squeeze(Alonesynch(2,:,:))';

supportbasenans = any(isnan(supportbase), 2);
supportstimnans = any(isnan(supportstim), 2);

alonebasenans = any(isnan(alonebase), 2);
alonestimnans = any(isnan(alonestim), 2);

toremove1 = logical(supportbasenans + alonebasenans);
toremove2 = logical(supportstimnans + alonestimnans);
toremove3 = logical(supportstimnans + supportbasenans);

presenceeffectsupbase = supportbase(~toremove1,:);
presenceeffectalobase = alonebase(~toremove1,:);

% now run the cluster test

[clusters1, p_values1, t_sums1, permutation_distribution1 ] = permutest(presenceeffectsupbase',presenceeffectalobase',[],0.05,5000,false,[]);
sigfrex = TF.frex(clusters1{1});
p_values1

figure
plot(TF.frex,mean(presenceeffectsupbase)','LineWidth',2)
hold on
plot(TF.frex,mean(presenceeffectalobase)','LineWidth',2)
legend('support baseline','alone baseline')
plot([sigfrex;sigfrex],get(gca,'ylim'),'r-','LineWidth',2)


presenceeffectsupstim = supportstim(~toremove2,:);
presenceeffectalostim = alonestim(~toremove2,:);

% now run the cluster test

[clusters2, p_values2, t_sums2, permutation_distribution2 ] = permutest(presenceeffectsupstim',presenceeffectalostim',[],0.05,5000,false,[]);
sigfrex = TF.frex(clusters2{1});
p_values2

figure
plot(TF.frex,mean(presenceeffectsupstim)','LineWidth',2)
hold on
plot(TF.frex,mean(presenceeffectalostim)','LineWidth',2)
legend('support stim','alone stim')
plot([sigfrex;sigfrex],get(gca,'ylim'),'r-','LineWidth',2)


handeffectbase = supportbase(~toremove3,:);
handeffectstim = supportstim(~toremove3,:);

% now run the cluster test

[clusters3, p_values3, t_sums3, permutation_distribution3 ] = permutest(handeffectstim',handeffectbase',[],0.05,5000,false,[]);
sigfrex = TF.frex(clusters3{1});
p_values3

figure
plot(TF.frex,mean(handeffectstim)','LineWidth',2)
hold on
plot(TF.frex,mean(handeffectbase)','LineWidth',2)
legend('baseline','stimulation')
plot([sigfrex;sigfrex],get(gca,'ylim'),'r-','LineWidth',2)



%% Try just correlation synchrony on interpolated ibi time series
load("FD.mat")

subjectstoexclude = array2table...
({'00007Support', 'Partner', 'stim';
  '00013Alone', 'Partner', 'stim';
  '00015Support', 'Partner', 'stim';
  '00017Alone', 'Partner', 'all';
  '00018Alone', 'Partner', 'all';
  '36850Alone', 'Partner', 'base';
  '41401Alone', 'Partner', 'all';
  '42577Support', 'Partner', 'all';
  '46219Support', 'Participant', 'stim'});

ibis = FD.Interpolated;
ibiids = FD.Id;
excidx = [];

for i = 1:height(subjectstoexclude)
    
    toexclude = char(table2array(subjectstoexclude(i,1)));
    excloc = strfind(lower(FD.Id),lower(toexclude));
    excidx(i) = find(~cellfun(@isempty,excloc));

end

ibis(:,:,:,excidx) = [];
ibiids(excidx) = [];

aloneidx = strfind(lower(ibiids),'alone');
supportidx = strfind(lower(ibiids),'support');

alonecondition = find(~cellfun(@isempty,aloneidx));
supportcondition = find(~cellfun(@isempty,supportidx));

Aloneid = char(ibiids(alonecondition)');
Aloneid = string(Aloneid(:,1:5));

Supportid = char(ibiids(supportcondition)');
Supportid = string(Supportid(:,1:5));

Aloneibis = ibis(:,:,:,alonecondition);
Supportibis = ibis(:,:,:,supportcondition);

% Find data common to both alone and support for simple correlations

[shared,Aid,Sid] = intersect(Aloneid,Supportid);
Alonelen = length(Aloneid)-length(shared);
Supportlen = length(Supportid)-length(shared);


% chop wings of all ibis to get rid of artifacts

Aloneibis = Aloneibis(9:end-8,:,:,:);
Supportibis = Supportibis(9:end-8,:,:,:);

% correlations in the alone condition
Alonecorrs = zeros(length(Aloneid),2);

for i = 1:length(Aloneid)
    
    Alonecorrs(i,1) = corr(squeeze(Aloneibis(:,1,1,i)),squeeze(Aloneibis(:,1,2,i)));
    Alonecorrs(i,2) = corr(squeeze(Aloneibis(:,2,1,i)),squeeze(Aloneibis(:,2,2,i)));
    
end

% correlations in the support condition

Supportcorrs = zeros(length(Supportid),2);

for i = 1:length(Supportid)
    
    Supportcorrs(i,1) = corr(squeeze(Supportibis(:,1,1,i)),squeeze(Supportibis(:,1,2,i)));
    Supportcorrs(i,2) = corr(squeeze(Supportibis(:,2,1,i)),squeeze(Supportibis(:,2,2,i)));
    
end

Aloneid(Aid) = [];
Supportid(Sid) = [];

corrtable = array2table(NaN((length(shared)+Alonelen+Supportlen),5),"VariableNames",{'ID','Alonebase','Alonestim','Supportbase','Supportstim'});
corrtable.ID(1:length(shared)) = shared;
corrtable.ID(length(shared)+1:length(shared)+Alonelen) = Aloneid;
corrtable.ID(end-length(Supportid)+1:end) = Supportid;

Aloneid = char(ibiids(alonecondition)');
Aloneid = string(Aloneid(:,1:5));

Supportid = char(ibiids(supportcondition)');
Supportid = string(Supportid(:,1:5));


corrtable(1:length(shared),2:3) = array2table(Alonecorrs(Aid,:));
corrtable(1:length(shared),4:5) = array2table(Supportcorrs(Sid,:));
Alonecorrs(Aid,:) = [];
corrtable(length(shared)+1:length(shared)+Alonelen,2:3) = array2table(Alonecorrs);
Supportcorrs(Sid,:) = [];
corrtable(end-Supportlen+1:end,4:5) = array2table(Supportcorrs);

% put these values together in the correlation table

Correlate = readtable("Correlate.xls");

Correlate.synchbase = double(NaN(height(Correlate),1));
Correlate.synchstim = double(NaN(height(Correlate),1));

for i = 1:height(Correlate)

    temp = find(corrtable.ID == Correlate.ParticipantID(i));

    if isempty(temp)
        continue
    elseif categorical(Correlate.Condition(i))== 'Support'
        Correlate.synchbase(i) = corrtable.Supportbase(temp);
        Correlate.synchstim(i) = corrtable.Supportstim(temp);
    elseif categorical(Correlate.Condition(i))== 'Alone'
        Correlate.synchbase(i) = corrtable.Alonebase(temp);
        Correlate.synchstim(i) = corrtable.Alonestim(temp);
    end

end


%% Put the synch values into the correlate table


Correlate.synchbase = double(NaN(height(Correlate),1));
Correlate.synchstim = double(NaN(height(Correlate),1));
Synchcorr.ID = double(Synchcorr.ID);
base = Synchcorr(Synchcorr.Time == 'base',:);
stim = Synchcorr(Synchcorr.Time == 'stim',:);


for i = 1:height(Correlate)

    temp = find(Synchcorr.ID == Correlate.ParticipantID(i));
    try
        if  categorical(Correlate.Condition(i))== 'Support'
            Correlate.synchbase(i) = Synchcorr.Synch(temp(3));
            Correlate.synchstim(i) = Synchcorr.Synch(temp(4));
        elseif categorical(Correlate.Condition(i))== 'Alone'
            Correlate.synchbase(i) = Synchcorr.Synch(temp(1));
            Correlate.synchstim(i) = Synchcorr.Synch(temp(2));
        end
    catch
        disp(['error with ', string(Correlate.ParticipantID(i))])
    end
end

writetable(Correlate,'Correlate.xls')

%% Now correlate the r values in the support condition with the intensity and area etc. 

Corrsupport = Correlate(categorical(Correlate.Condition)=='Support',:);


writetable(Corrsupport,'Correlate2.xls')

%% is there a significant effect of either condition or time on the r values as a surrogate for synchronisation
    
corrtable = stack(corrtable,{'Alonebase','Alonestim','Supportbase','Supportstim'},"NewDataVariableName",'Synch','IndexVariableName','Condition');

time = {'base';'stim'};
time = repmat(time,height(corrtable)/2,1);
corrtable.Time = categorical(cellstr(time));

cond = {'Alone';'Alone';'Support';'Support'};
cond = repmat(cond,height(corrtable)/4,1);
corrtable.Condition = categorical(cellstr(cond));
corrtable.ID = categorical(corrtable.ID);

synchresult = fitlme(corrtable,'Synch ~ Condition*Time + (1|ID)');
anova(synchresult)

writetable(corrtable,'Synchcorr.xls')

%% Try cross correlations on interpolated ibi time series

maxlag = 40;
Alonexcorrs = zeros(1+maxlag*2,2,length(Aloneid));

for i = 1:length(Aloneid)
    
    Alonexcorrs(:,1,i) = xcorr(squeeze(Aloneibis(:,1,1,i)),squeeze(Aloneibis(:,1,2,i)),maxlag,'normalized');
    Alonexcorrs(:,2,i) = xcorr(squeeze(Aloneibis(:,2,1,i)),squeeze(Aloneibis(:,2,2,i)),maxlag,'normalized');
    
end

% correlations in the support condition

Supportxcorrs = zeros(1+maxlag*2,2,length(Supportid));

for i = 1:length(Supportid)
    
    Supportxcorrs(:,1,i) = xcorr(squeeze(Supportibis(:,1,1,i)),squeeze(Supportibis(:,1,2,i)),maxlag,'normalized');
    Supportxcorrs(:,2,i) = xcorr(squeeze(Supportibis(:,2,1,i)),squeeze(Supportibis(:,2,2,i)),maxlag,'normalized');
    
end


Alonexcorrs = Alonexcorrs(:,:,Aid);
Supportxcorrs = Supportxcorrs(:,:,Sid);

plot(-maxlag:maxlag,squeeze(Alonexcorrs(:,2,:)),'k-')
hold on
plot(-maxlag:maxlag,squeeze(Supportxcorrs(:,2,:)),'g-')
legend('Alone','Support')


%% Exploratory correlations
% first create all the relevant columns that you want to correlate

% Hyperalgesia for T1

IntensityhypT1 = (IntegratedData.MeanT1_Intensity_MFS_Arm - IntegratedData.MeanT0_Intensity_MFS_Arm)...
               - (IntegratedData.MeanT1_Intensity_Control_Arm - IntegratedData.MeanT0_Intensity_Control_Arm);


UnpleasantnesshypT1 = (IntegratedData.MeanT1_Unpleasantness_MFS_Arm - IntegratedData.MeanT0_Unpleasantness_MFS_Arm)...
                    - (IntegratedData.MeanT1_Unpleasantness_Control_Arm - IntegratedData.MeanT0_Unpleasantness_Control_Arm);


% Hyperalgesia for T2

IntensityhypT2 = (IntegratedData.MeanT2_Intensity_MFS_Arm - IntegratedData.MeanT0_Intensity_MFS_Arm)...
             - (IntegratedData.MeanT2_Intensity_Control_Arm - IntegratedData.MeanT0_Intensity_Control_Arm);



UnpleasantnesshypT2 = (IntegratedData.MeanT2_Unpleasantness_MFS_Arm - IntegratedData.MeanT0_Unpleasantness_MFS_Arm)...
                    - (IntegratedData.MeanT2_Unpleasantness_Control_Arm - IntegratedData.MeanT0_Unpleasantness_Control_Arm);

% mean for T1 and T2

meaninthyp = mean([IntensityhypT1 IntensityhypT2],2);
meanunphyp = mean([UnpleasantnesshypT1 UnpleasantnesshypT2],2);

corrs = [IntegratedData.Mean_MFS_Intensity IntegratedData.Mean_MFS_Unpleasantness IntensityhypT1 UnpleasantnesshypT1 IntensityhypT2 UnpleasantnesshypT2 meaninthyp meanunphyp...
        Area.Area_Length_T1 Area.Area_Width_T1 Area.Area_Length_T2 Area.Area_Width_T2 Area.surfaceareaT1 Area.surfaceareaT2];

% Correlate with RMSSD
[RMSSDbase, RMSSDstim, RMSSDrec] = deal(NaN(height(IntegratedData),1));

for i = 1:height(IntegratedData)
    number = IntegratedData.ParticipantID(i);
    condition = IntegratedData.Condition(i);

    tempbase = RMSSDParticipantOR.RMSSD(RMSSDParticipantOR.Number==number & RMSSDParticipantOR.Condition==condition & RMSSDParticipantOR.Time=='ParticipantBase');
    tempstim = RMSSDParticipantOR.RMSSD(RMSSDParticipantOR.Number==number & RMSSDParticipantOR.Condition==condition & RMSSDParticipantOR.Time=='ParticipantStim');
    temprec = RMSSDParticipantOR.RMSSD(RMSSDParticipantOR.Number==number & RMSSDParticipantOR.Condition==condition & RMSSDParticipantOR.Time=='ParticipantRec');

    if ~isempty(tempbase)
        RMSSDbase(i) = tempbase;
    end

    if ~isempty(tempstim)
        RMSSDstim(i) = tempstim;
    end

    if ~isempty(temprec)
       RMSSDrec(i) = temprec;
    end
       
end


corrs = [corrs RMSSDbase RMSSDstim RMSSDrec (RMSSDbase-RMSSDstim)];
vnames = {'MFS_Intensity', 'MFS_Unpleasantness', 'IntensityhypT1', 'UnpleasantnesshypT1','IntensityhypT2', 'UnpleasantnesshypT2', 'meaninthyp', 'meanunphyp'...
        'Area_Length_T1', 'Area_Width_T1', 'Area_Length_T2', 'Area_Width_T2', 'surfaceareaT1', 'surfaceareaT2',...
    'RMSSDbase', 'RMSSDstim', 'RMSSDrec', 'RMSSDchange'};
corrs = array2table(corrs,"VariableNames",vnames);
corrs = [IntegratedData(:,2) IntegratedData(:,4) corrs];


[r,p] = corr(corrs.MFS_Intensity,corrs.RMSSDchange,"rows","complete")


% Extract synch data

Freqidx = dsearchn(TF.frex',sigfrex');
tempsynch = TF.synch(:,Freqidx,:);

tempid = char(lower(TF.Id)');
numbers = tempid(:,1:5);
numbers = string(double(string(numbers)));
conditions = string(tempid(:,6:end));
conditions = strtrim(conditions);
tempid = strcat(numbers,conditions);

[Synchbase, Synchstim, Synchrec] = deal(NaN(height(Correlate),length(Freqidx)));

for i = 1:height(Correlate)
    number = Correlate.ParticipantID(i);
    condition = Correlate.Condition(i);
    
    comb = strcat(string(number),string(condition));

    tempidx = find(strcmp(tempid,lower(comb)));
    tempbase = tempsynch(1,:,tempidx);
    tempstim = tempsynch(2,:,tempidx);
    temprec = tempsynch(3,:,tempidx);

    if ~isempty(tempbase)
        Synchbase(i,:) = tempbase;
    end

    if ~isempty(tempstim)
        Synchstim(i,:) = tempstim;
    end

    if ~isempty(temprec)
       Synchrec(i,:) = temprec;
    end
       
end

Synchdiff = Synchstim-Synchbase;

vnames = {'one','two','three','four','five','six','seven','eight','nine','ten','eleven'};
Basesynch = array2table(Synchbase,"VariableNames",vnames);
Basesynch = [Basesynch Correlate];
Basesynch(Basesynch.Condition=='Alone',:) = [];

Stimsynch = array2table(Synchstim,"VariableNames",vnames);
Stimsynch = [Stimsynch Correlate];
Stimsynch(Stimsynch.Condition=='Alone',:) = [];

Recsynch = array2table(Synchrec,"VariableNames",vnames);
Recsynch = [Recsynch Correlate];
Recsynch(Recsynch.Condition=='Alone',:) = [];

%corrs = [corrs, Synchbase, Synchstim, Synchrec];


%% write loop for correlations

% Correlate.Area_Length_T1(isnan(Correlate.meaninthyp)) = nan;
% Correlate.Area_Length_T2(isnan(Correlate.meaninthyp)) = nan;
% Correlate.Area_Width_T1(isnan(Correlate.meaninthyp)) = nan;
% Correlate.Area_Width_T2(isnan(Correlate.meaninthyp)) = nan;
% Correlate.surfaceareaT1(isnan(Correlate.meaninthyp)) = nan;
% Correlate.surfaceareaT2(isnan(Correlate.meaninthyp)) = nan;


vec1 = Stimsynch.surfaceareaT1;

ps = NaN(1,length(Freqidx));
rs = NaN(1,length(Freqidx));

for i = 1:length(Freqidx)
    
    %[rs(1,i),ps(1,i,1)] = corr(corrs.Area_Length_T2,Synchbase(:,i),"rows","complete");
    [rs(i),ps(i)] = corr(vec1,table2array(Stimsynch(:,i)),"rows","complete");
    %[rs(3,i),ps(3,i,1)] = corr(corrs.Area_Length_T2,Synchrec(:,i),"rows","complete");
    %[rs(4,i),ps(4,i,1)] = corr(corrs.Area_Length_T2,Synchdiff(:,i),"rows","complete");

end

rs(ps>.05) = 0;

figure(10)
imagesc(rs(:,:,1))
colorbar
axis xy
xticklabels(string(sigfrex))

%% now also run mixed model analysis on each of the frequencies
Table = stack(Stimsynch,{'surfaceareaT1','surfaceareaT2'},"NewDataVariableName",'Area','IndexVariableName','Time');
synchps = zeros(3,length(Freqidx));

for i = 1:length(Freqidx)

    synchresult = fitlme(Table,string(strcat('Area ~ ', vnames(i) ,'*Time + (1|Participant)')),'DummyVarCoding','effects');
    myres = anova(synchresult);

    synchps(1,i) = myres.pValue(2);
    synchps(2,i) = myres.pValue(3);
    synchps(3,i) = myres.pValue(4);


end

synchps(synchps>0.06) = nan;

%% exploring TF data

TFparticipant = squeeze(TF.tf(:,:,1,:,:));

aloneidx = strfind(lower(TF.Id),'alone');
supportidx = strfind(lower(TF.Id),'support');
alonecondition = find(~cellfun(@isempty,aloneidx));
supportcondition = find(~cellfun(@isempty,supportidx));

Aloneid = char(TF.Id(alonecondition)');
Aloneid = string(Aloneid(:,1:5));

Supportid = char(TF.Id(supportcondition)');
Supportid = string(Supportid(:,1:5));

AloneTF = TFparticipant(:,:,:,alonecondition);
SupportTF = TFparticipant(:,:,:,supportcondition);

missingparticipant = TF.Id(find(isnan(squeeze(TFparticipant(2,1,1,:)))));
missingparticipant = char(missingparticipant);
missingparticipant = string(missingparticipant(1:5));

AloneTF(:,:,:,Aloneid==missingparticipant) = [];
SupportTF(:,:,:,Supportid==missingparticipant) = [];
Aloneid(Aloneid==missingparticipant) = [];
Supportid(Supportid==missingparticipant) = [];

toremove = setdiff(Aloneid,Supportid);
tokeep = intersect(Aloneid, Supportid);

for i = 1:length(toremove)

    AloneTF(:,:,:,strcmp(Aloneid,toremove(i))) = [];
    Aloneid(strcmp(Aloneid,toremove(i))) = [];

end

allTFbase = cat(3,squeeze(SupportTF(1,:,:,:)),squeeze(AloneTF(1,:,:,:)));
allTFstim = cat(3,squeeze(SupportTF(2,:,:,:)),squeeze(AloneTF(2,:,:,:)));
allTFdiff = allTFstim - allTFbase;

allID = double([Supportid;Aloneid]);
allcond = categorical([repmat("Support",size(Supportid));repmat("Alone",size(Aloneid))]);
% Run test for baseline vs stimulation in the support condition

[clusterscond, p_valuescond, t_sumscond, permutation_distributioncond ] = permutest(allTFbase,allTFstim,[],0.05,[],true,[]);


% plot significant clusters

clim = [0 700];

figure(4)
subplot(121)
contourf(TF.Interptime,TF.frex,squeeze(mean(allTFbase,3))',40,'linecolor','none')
set(gca,'clim',clim)

subplot(122)
contourf(TF.Interptime,TF.frex,squeeze(mean(allTFstim,3))',40,'linecolor','none')
set(gca,'clim',clim)


sigclust = squeeze(mean(allTFstim(:,:,:),3));
x = 1:numel(sigclust);
x([clusterscond{1};clusterscond{2}]) = [];
sigclust(x) = 0;
%sigclust(clusterscond{2}) = 0;

figure(4)
subplot(122)
hold on
contour(TF.Interptime,TF.frex,logical(sigclust'),1,'linecolor','k')

% extract power from significant cluster from each participant

meanpower = zeros(size(allTFstim,3),3,2);

for i = 1:size(allTFstim,3)

    tempbase = squeeze(allTFbase(:,:,i));
    tempstim = squeeze(allTFstim(:,:,i));
    tempdiff = squeeze(allTFdiff(:,:,i));

    for j = 1:2

        clustidx = clusterscond{j};

        meanpower(i,1,j) =  mean(tempbase(clustidx));
        meanpower(i,2,j) =  mean(tempstim(clustidx));
        meanpower(i,3,j) =  mean(tempdiff(clustidx));

    end

end

newmeanpower = NaN(height(corrs),6);

for i = 1:height(corrs)

    id = corrs.ParticipantID(i);
    condt = corrs.Condition(i);
    loc = find(allID==id & allcond==condt);

    if loc

        newmeanpower(i,1) = meanpower(loc,1,1);
        newmeanpower(i,2) = meanpower(loc,2,1);
        newmeanpower(i,3) = meanpower(loc,3,1);
        newmeanpower(i,4) = meanpower(loc,1,2);
        newmeanpower(i,5) = meanpower(loc,2,2);
        newmeanpower(i,6) = meanpower(loc,3,2);

    end

end

vnames = {'baseclust1','stimclust1','diffclust1','baseclust2','stimclust2','diffclust2'};
newmeanpower = array2table(newmeanpower,'VariableNames',vnames);

corrs = [corrs newmeanpower];

writetable(corrs,'Correlate.xls')

writetable(Correlate,'Correlate.xls')


[r,p] = corr(corrs.diffclust2,corrs.surfaceareaT2,"rows","complete")

participant = repmat(1:37,2,1);
Correlate.Participant = participant(:);




%% now run test for Alone vs Support Baseline Subtracted

Alonesubt = squeeze(AloneTF(2,:,:,:)) - squeeze(AloneTF(1,:,:,:));
Supportsubt = squeeze(SupportTF(2,:,:,:)) - squeeze(SupportTF(1,:,:,:));

[clusters, p_values, t_sums, permutation_distribution ] = permutest(Alonesubt,Supportsubt,[],0.05,[],false,[]);


% plot significant clusters

clim = [0 700];

figure(7)
subplot(121)
contourf(TF.Interptime,TF.frex,squeeze(mean(Alonesubt(:,:,:),3))',40,'linecolor','none')
set(gca,'clim',clim)

subplot(122)
contourf(TF.Interptime,TF.frex,squeeze(mean(Supportsubt(:,:,:),3))',40,'linecolor','none')
set(gca,'clim',clim)

sigclust = squeeze(mean(allTFstim(:,:,:),3));
x = 1:numel(sigclust);
x([clusters{1};clusters{2}]) = [];
sigclust(x) = 0;
%sigclust(clusterscond{2}) = 0;

figure(7)
subplot(122)
hold on
contour(TF.Interptime,TF.frex,logical(sigclust'),1,'linecolor','k')


