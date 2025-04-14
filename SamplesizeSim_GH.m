
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:
% This script runs a Monte Carlo power simulation to estimate the required
% sample size for detecting a significant three-way interaction (Group × 
% Time × Arm) in a linear mixed-effects model. It simulates multivariate 
% normal data based on defined group means, standard deviations, and 
% within-group correlations, and compares models with and without baseline 
% covariates.
%
% Key Features:
% - Simulates data for two groups (Alone, Support) across 3 timepoints and 
%   2 arm conditions (Control, Stimulated)
% - Computes power for detecting:
%     • Group × Time × Arm interaction
%     • Main effect of Group
%     • Group × Time and Group × Arm interactions
% - Estimates sample sizes required to achieve 80% and 90% power
% - Plots power curves across sample sizes
%
% Output:
% - Required N for specified power thresholds (80%, 90%)
% - Power curves for visual interpretation
%
% Note:
% - Assumes a population size of 10,000 and simulates `numexps` experiments
%   for each sample size between 3 and `maxsize`
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Define Parameters
datameansA = [10,10,10,10,38,36]; % Alone group
datameansS = [10,10,10,10,30,26]; % Support group
datameans  = [datameansS datameansA];
stds       = [14 14 14 14 14 14 14 14 14 14 14 14]+6;
stds       = diag(stds);

% Create a correlation matrix for the correlations between observations
% these correlations are only defined within each group. I am doing this
% because observations are probably not going to be correlated across the
% two groups.

correlation = .65;

cormat = ones(length(datameans))*correlation;
for i = 1:length(cormat)
    cormat(i,i) = 1;
end

% convert correlation matrix to covariance matrix
sigma = stds*cormat*stds;


% define factor names to be used later
Time = {'zero';'one';'two'};
Arm = {'Control';'Control';'Control';'Stimulated';'Stimulated';'Stimulated'};

% initialize variables

%JBM: Sample sizes are not going to be larger than 100 per group,
%but this is useful for the simulations to check the full range
maxsize = 50;
sizes = 1:maxsize;

%JBM: this is a bit beter in my view: there is only one large population
%from which you sample (not many small ones)
popsize = 10000;
numexps = 100;

Pvalinteract  = zeros(numexps,1);
Powerinteract = zeros(maxsize,1);

[Powergroup PowerTimegroup PowerArmgroup] = deal(zeros(maxsize,1));
[Pvalgroup PvalTimegroup PvalArmgroup]= deal(zeros(numexps,1));
    
data = mvnrnd(datameans,sigma,popsize); % generate data
dataS = data(:,1:6);
dataA = data(:,7:end);

% Format the data for input to fitlme

dataS = array2table(dataS,'VariableNames',{'T0CA','T1CA','T2CA','T0SA','T1SA','T2SA'});
dataA = array2table(dataA,'VariableNames',{'T0CA','T1CA','T2CA','T0SA','T1SA','T2SA'});

support = stack(dataS,{'T0CA','T1CA','T2CA','T0SA','T1SA','T2SA'},'NewDataVariableName',"Ratings",'IndexVariableName','Condition');
Alone = stack(dataA,{'T0CA','T1CA','T2CA','T0SA','T1SA','T2SA'},'NewDataVariableName',"Ratings",'IndexVariableName','Condition');

support.Time  = repmat(Time,[(popsize*6)/length(Time),1]);
support.Arm   = repmat(Arm,(popsize*6)/length(Arm),1);
support.Group = categorical(zeros(popsize*6,1));

Alone.Time    = repmat(Time,[(popsize*6)/length(Time),1]);
Alone.Arm     = repmat(Arm,(popsize*6)/length(Arm),1);
Alone.Group   = categorical(ones(popsize*6,1));

alldata       = vertcat(support,Alone);

participant   = (1:popsize*2)';
participant   = (repmat(participant,1,6))';
participant   = participant(:);

alldata.participant = categorical(participant);

%% Organize data for the covariate model
Time = {'one';'two'};
Arm = {'Control';'Control';'Stimulated';'Stimulated'};

Baselineratings = dataS(:,[1,4]);
dataS(:,[1 4]) = [];

Baselineratings = stack(Baselineratings,{'T0CA','T0SA'},'NewDataVariableName',"BaselineRatings",'IndexVariableName','BaseCondition');
Baselineratings = repmat(table2array(Baselineratings(:,"BaselineRatings"))',[2,1]);
Baselineratings = Baselineratings(:);
support2 = stack(dataS,{'T1CA','T2CA','T1SA','T2SA'},'NewDataVariableName',"Ratings",'IndexVariableName','Condition');
support2.Baselineratings = Baselineratings;


Baselineratings = dataA(:,[1,4]);
dataA(:,[1 4]) = [];

Baselineratings = stack(Baselineratings,{'T0CA','T0SA'},'NewDataVariableName',"BaselineRatings",'IndexVariableName','BaseCondition');
Baselineratings = repmat(table2array(Baselineratings(:,"BaselineRatings"))',[2,1]);
Baselineratings = Baselineratings(:);
Alone2   = stack(dataA,{'T1CA','T2CA','T1SA','T2SA'},'NewDataVariableName',"Ratings",'IndexVariableName','Condition');
Alone2.Baselineratings = Baselineratings;

support2.Time  = repmat(Time,[(popsize*4)/length(Time),1]);
support2.Arm   = repmat(Arm,(popsize*4)/length(Arm),1);
support2.Group = categorical(zeros(popsize*4,1));

Alone2.Time    = repmat(Time,[(popsize*4)/length(Time),1]);
Alone2.Arm     = repmat(Arm,(popsize*4)/length(Arm),1);
Alone2.Group   = categorical(ones(popsize*4,1));

alldata2       = vertcat(support2,Alone2);

participant   = (1:popsize)';
participant   = (repmat(participant,1,4))';
participant   = participant(:);
participant   = [participant;participant];

alldata2.participant = categorical(participant);

%% Run Simulation


for sampsize = 3:maxsize % loop over different sample sizes

    parfor exp = 1:numexps % many experiments for each sample size

        % generate random indices (participants to pick)
        indices = randsample(popsize,sampsize);
        %JBM: population is larger now, so to pick different conditions the
        %jump is '+popsize' instead of '+100'
        indices = [indices';indices'+popsize];

        % create the current sample
        sample  = alldata(ismember(alldata.participant,categorical(indices)),:);
        sample2 = alldata2(ismember(alldata2.participant,categorical(indices)),:);

        % Fit model to sample
        fullmodel = fitlme(sample,'Ratings ~ Group*Time*Arm + (1|participant)','DummyVarCoding','effects');
        covmodel  = fitlme(sample2,'Ratings ~ Baselineratings+ Group*Time*Arm + (1|participant)','DummyVarCoding','effects');
        %[beta,betanames,stats] = fixedEffects(fullmodel);

        %JBM: these are the ststs you might be more familiar with
        stats = anova(fullmodel);
        stats2 = anova(covmodel);

        % the output provides two parameters for the three way
        % interaction. Store both.
        %Pvalinteract1(iters) = stats(11,6);
        %Pvalinteract2(iters) = stats(12,6);
       
        %JBM: this is the true p value for the three way interaction
         Pvalinteract(exp) = stats(8,5);
         Pvalgroup(exp) = stats2(5,5);
         PvalTimegroup(exp) = stats2(7,5);
         PvalArmgroup(exp) = stats2(8,5);

         disp(['Samplesize' num2str(sampsize) ' experiment ' num2str(exp)])
    end


    % compute and store power
    % Powerinteract1(sampsize,exp) = sum(Pvalinteract1<=.05)/iters;
    %Powerinteract2(sampsize,exp) = sum(Pvalinteract2<=.05)/iters;
     Powerinteract(sampsize) = sum(Pvalinteract<=.05)/numexps;
     Powergroup(sampsize) = sum(Pvalgroup<=.05)/numexps;
     PowerTimegroup(sampsize) = sum(PvalTimegroup<=.05)/numexps;
     PowerArmgroup(sampsize) = sum(PvalArmgroup<=.05)/numexps;

end

% for power of 80
ReqN   = dsearchn(Powerinteract,.8);
ReqNgroup  = dsearchn(Powergroup,.8);
reqNTimegroup = dsearchn(PowerTimegroup,.8);
reqNArmgroup = dsearchn(PowerArmgroup,.8);

% for power of 90
%ReqN901 = sizes(dsearchn(mean(Powerinteract1,2),.9));
%ReqN902 = sizes(dsearchn(mean(Powerinteract2,2),.9));
ReqN90   = dsearchn(Powerinteract,.9);
ReqNgroup90  = dsearchn(Powergroup,.9);
reqNTimegroup90 = dsearchn(PowerTimegroup,.9);
reqNArmgroup90 = dsearchn(PowerArmgroup,.9);

figure(3)
plot(sizes,Powerinteract(:,1),'ko-','LineWidth',2)
hold on
plot(get(gca,'xlim'),[.8 .8],'r-','LineWidth',2)
title(['Required N = ' num2str(ReqN) 'Correlation .65'])
xlabel('Sample Sizes')
ylabel('Power')


figure(4)
plot(sizes,Powergroup(:,1),'ko-','LineWidth',2)
hold on
plot(sizes,PowerTimegroup(:,1),'go-','LineWidth',2)
plot(sizes,PowerArmgroup(:,1),'mo-','LineWidth',2)
plot(get(gca,'xlim'),[.8 .8],'r-','LineWidth',2)
legend('Main Effect Group','Time x Group','Arm x Group')
title(['Required N for Group = ' num2str(ReqNgroup) ' and for group arm interaction = ' num2str(reqNArmgroup) ' Correlation .65'])
xlabel('Sample Sizes')
ylabel('Power')

