
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Script Name: CompileQuestionnaireData.m
%
% Description:
% This script integrates questionnaire data from ECR, PCS, and DAS scales 
% with a behavioral dataset (`Ratingdata`). It aligns participant IDs, 
% handles duplicates, extracts relevant questionnaire subscales, and 
% appends them to the main data table. It also checks for missing behavioral 
% and questionnaire data and exports the final integrated dataset.
%
% Input:
% - Ratingdata: Behavioral and ratings data for participants
% - ECR, PCS, DAS: Tables with questionnaire data
%
% Output:
% - IntegratedData.xls: Final compiled dataset
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Import the three questionnaire xls files, Ratingdata 

Data = Ratingdata(1:74,:);
Data.ParticipantID(8) = 43750;
Data.ParticipantID(36) = 45970;
Data.ParticipantID(40) = 46363;
Data.ParticipantID(42) = 14;

%% Compile the questionnaire data with the behavioural data

[uniqueids,ia,ic] = unique(Data.ParticipantID);
ECR.ParticipantID = str2double(ECR.ParticipantID);
ECR.PartnerID = str2double(ECR.PartnerID);

Anxiety = zeros(height(Data),1);
Avoidance = zeros(height(Data),1);
Avomycalc = zeros(height(Data),1);

for i = 1:length(uniqueids)

    id = uniqueids(i);

    if ~ismember(id,ECR.ParticipantID)
        Anxiety(Data.ParticipantID == id) = nan;
        Avoidance(Data.ParticipantID == id) = nan;
        Avomycalc(Data.ParticipantID == id) = nan;
    else
        tempanx = ECR.Anxiety(ECR.ParticipantID==id);
        tempavo = ECR.Avoidance(ECR.ParticipantID==id);
        tempmyavo = ECR.Avomycalc(ECR.ParticipantID==id);
        if numel(tempanx)>1
            Anxiety(Data.ParticipantID == id) = tempanx(2);
            Avoidance(Data.ParticipantID == id) = tempavo(2);
            Avomycalc(Data.ParticipantID == id) = tempmyavo(2);
        else
            Anxiety(Data.ParticipantID == id) = ECR.Anxiety(ECR.ParticipantID==id);
            Avoidance(Data.ParticipantID == id) = ECR.Avoidance(ECR.ParticipantID==id);
            Avomycalc(Data.ParticipantID == id) = ECR.Avomycalc(ECR.ParticipantID==id);
        end
    end

end

Data.Anxiety = Anxiety;
Data.Avoidance = Avoidance;
Data.Avomycalc = Avomycalc;

%% PCS 

[uniqueids,ia,ic] = unique(Data.ParticipantID);
PCS.ParticipantID = str2double(PCS.ParticipantID);
PCS.PartnerID = str2double(PCS.PartnerID);

[totalPCS, PCSrumination, PCSmagnification, PCShelplessness]= deal(zeros(height(Data),1));

for i = 1:length(uniqueids)

    id = uniqueids(i);

    if ~ismember(id,PCS.ParticipantID)
        totalPCS(Data.ParticipantID == id) = nan;
        PCSrumination(Data.ParticipantID == id) = nan;
        PCSmagnification(Data.ParticipantID == id) = nan;
        PCShelplessness(Data.ParticipantID == id) = nan;

    else
        idx = find(PCS.ParticipantID==id);

        if numel(idx)>1
            idx = idx(2);
            totalPCS(Data.ParticipantID == id) = PCS.Total(idx);
            PCSrumination(Data.ParticipantID == id) = PCS.Rumination(idx);
            PCSmagnification(Data.ParticipantID == id) = PCS.Magnification(idx);
            PCShelplessness(Data.ParticipantID == id) = PCS.Helplessness(idx);
        else

            totalPCS(Data.ParticipantID == id) = PCS.Total(PCS.ParticipantID==id);
            PCSrumination(Data.ParticipantID == id) = PCS.Rumination(PCS.ParticipantID==id);
            PCSmagnification(Data.ParticipantID == id) = PCS.Magnification(PCS.ParticipantID==id);
            PCShelplessness(Data.ParticipantID == id) = PCS.Helplessness(PCS.ParticipantID==id);

        end
    end

end

Data.totalPCS = totalPCS;
Data.PCSrumination = PCSrumination;
Data.PCSmagnification = PCSmagnification;
Data.PCShelplessness = PCShelplessness;

%% DAS
[uniqueids,ia,ic] = unique(Data.ParticipantID);
DAS.ParticipantID = str2double(DAS.ParticipantID);
DAS.PartnerID = str2double(DAS.PartnerID);

[totalDAS, DASconsensus, DASsatisfaction, DAScohesion]= deal(zeros(height(Data),1));

for i = 1:length(uniqueids)

    id = uniqueids(i);

    if ~ismember(id,DAS.ParticipantID)
        totalDAS(Data.ParticipantID == id) = nan;
        DASconsensus(Data.ParticipantID == id) = nan;
        DASsatisfaction(Data.ParticipantID == id) = nan;
        DAScohesion(Data.ParticipantID == id) = nan;

    else
        idx = find(DAS.ParticipantID==id);

        if numel(idx)>1

            idx = idx(2);

            totalDAS(Data.ParticipantID == id) = DAS.Total(idx);
            DASconsensus(Data.ParticipantID == id) = DAS.Consensus(idx);
            DASsatisfaction(Data.ParticipantID == id) = DAS.Satisfaction(idx);
            DAScohesion(Data.ParticipantID == id) = DAS.Cohesion(idx);

        else

            totalDAS(Data.ParticipantID == id) = DAS.Total(DAS.ParticipantID==id);
            DASconsensus(Data.ParticipantID == id) = DAS.Consensus(DAS.ParticipantID==id);
            DASsatisfaction(Data.ParticipantID == id) = DAS.Satisfaction(DAS.ParticipantID==id);
            DAScohesion(Data.ParticipantID == id) = DAS.Cohesion(DAS.ParticipantID==id);

        end
    end

end

Data.totalDAS = totalPCS;
Data.DASconsensus = DASconsensus;
Data.DASsatisfaction = DASsatisfaction;
Data.DAScohesion = DAScohesion;

%% check for missing data and make a note

testforcomp = Data(:,2);
testforcomp = [testforcomp Data(:,7:31)];
testforcomp(:,11) = [];


completeness = false(height(testforcomp),1);
for i = 1:height(testforcomp)

    temp = table2array(testforcomp(i,:))';

    if sum(isnan(temp))
        completeness(i) = true;
    else
        completeness(i) = false;
    end

end

missingbehav = Data(completeness,:);

missingquest = isnan(Data.Anxiety);
missingquest = Data(missingquest,:);

writetable(Data,'IntegratedData.xls')
