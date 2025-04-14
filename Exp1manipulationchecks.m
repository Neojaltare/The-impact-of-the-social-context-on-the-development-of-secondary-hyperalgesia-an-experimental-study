% Script to perform manipulation checks

IntegratedData = readtable("IntegratedData.xls");

toremove = IntegratedData.ParticipantID(isnan(IntegratedData.MeanT1_Intensity_MFS_Arm));
toremove = unique(toremove);

% add order variable
skip = 1:2:height(IntegratedData);
order = zeros(height(IntegratedData),1);
for i = 1:length(skip)
    if isequal(IntegratedData.Condition{skip(i)},'Support')
        order(skip(i):skip(i)+1) = 1;
    else
        order(skip(i):skip(i)+1) = 2;
    end
end

IntegratedData.Order = order;


for i = 1:length(toremove)
    IntegratedData(IntegratedData.ParticipantID==toremove(i),:) = [];
end

age = IntegratedData.Age(1:2:end);
mean(age)
std(age)

cond = zeros(height(IntegratedData),1);
for i = 1:length(cond)
    if isequal(IntegratedData.Condition{i},'Support')
        cond(i) = 1;
    else
        cond(i) = 2;
    end
end
IntegratedData.Cond = cond;

manipcheckdat = IntegratedData(:,[1 2 3 4 13 14 15 45 46]);


support = IntegratedData.HowSupportedDidYouFeel;
preds = [ones(height(IntegratedData),1) IntegratedData.Cond IntegratedData.Order];
[h,p,ci,stats] = ttest(support(categorical(IntegratedData.Condition)=='Support'),support(categorical(IntegratedData.Condition)=='Alone'))
numel(support(string(IntegratedData.Condition)=='Support'))
numel(support(string(IntegratedData.Condition)=='Alone'))
[b,bint,r,rint,stats] = regress(support,preds);

fear = IntegratedData.HowFearfulDidYouFeelAboutTheStimulation;
[h,p,ci,stats] = ttest(fear(categorical(IntegratedData.Condition)=='Support'),fear(categorical(IntegratedData.Condition)=='Alone'))
std(fear(string(IntegratedData.Condition)=='Support'))
std(fear(string(IntegratedData.Condition)=='Alone'))

stress = IntegratedData.HowStressfulDidYouFindTheStimulation;
[h,p,ci,stats] = ttest(stress(categorical(IntegratedData.Condition)=='Support'),stress(categorical(IntegratedData.Condition)=='Alone'))
std(stress(string(IntegratedData.Condition)=='Support'))
std(stress(string(IntegratedData.Condition)=='Alone'))

writetable(manipcheckdat,"Manipcheckdat.xls")
