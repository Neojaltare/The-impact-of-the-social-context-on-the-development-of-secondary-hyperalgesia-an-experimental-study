
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:
% This script processes raw Qualtrics data from a study titled 
% "Persistent Pain and the Social Context" and extracts clean and structured 
% questionnaire data from three self-report measures:
%
%   1. **ECR (Experiences in Close Relationships)**  
%      - Extracts responses, reverse-scores necessary items, and computes 
%        subscales: Anxiety, Avoidance, and a custom 'Avomycalc'.
%      - Verifies scoring accuracy by comparing computed sums to final scores.
%
%   2. **PCS (Pain Catastrophizing Scale)**  
%      - Extracts raw responses and computes subscales: Rumination, 
%        Helplessness, and Magnification, along with the Total PCS score.
%
%   3. **DAS (Dyadic Adjustment Scale)**  
%      - Extracts responses and computes subscales: Consensus, Satisfaction, 
%        Cohesion, and the Total DAS score.
%
% The script handles:
% - Conversion from strings to numeric values
% - Renaming and cleaning variable names
% - Exporting the final processed tables as Excel files
%
% Inputs:
% - `PersistentPainandtheSocialContextFebruary1202202`: full dataset exported 
%   from Qualtrics
%
% Outputs:
% - `ECR.xlsx`: Cleaned ECR data
% - `PCS.xlsx`: Cleaned PCS data
% - `DAS.xlsx`: Cleaned DAS data
%
% Note:
% - Make sure the input variable `PersistentPainandtheSocialContextFebruary1202202`
%   is loaded in the workspace prior to running the script.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% import the main CSV file as a string array
Questionnaires = PersistentPainandtheSocialContextFebruary1202202;
quest = Questionnaires(Questionnaires(:,16)=='anonymous' & Questionnaires(:,7)=='True',:);
quest = quest(6:end,:);

quest = quest(:,18:end);

ECR = quest(:,1:39);
anav = quest(:,69:70);

ECR = [ECR anav];
ECR = array2table(ECR);
ECR.Status = quest(:,71);


number = 1:36;
name = 'ECR';

for i = 4:39
    
    ECR.Properties.VariableNames{strcat(name,num2str(i))} = strcat('Q',num2str(number(i-3)));

    for j = 1:size(ECR,1)

        temp = char(table2array(ECR(j,i)));
        temp = string(temp(1));

        ECR(j,i) = {temp};

    end
    
    eval(['ECR.' , 'Q',num2str(number(i-3)),' = str2double(','ECR.' , 'Q',num2str(number(i-3)),');'])

end

ECR.Properties.VariableNames{'ECR40'} = 'Anxiety';
ECR.Anxiety = str2double(ECR.Anxiety);

ECR.Properties.VariableNames{'ECR41'} = 'Avoidance';
ECR.Avoidance = str2double(ECR.Avoidance);

ECR.Status = categorical(ECR.Status);

% test whether the calculation is legit
reversekeyd = [9,11,20,22,26,27,28,29,30,31,33,34,35,36];

temp = table2array(ECR(:,4:39));
temp(:,reversekeyd) = -(temp(:,reversekeyd) - 8);

anx = sum(temp(:,1:18),2);
sum(anx - ECR.Anxiety)

avo = sum(temp(:,19:end),2);
sum(avo - ECR.Avoidance)

ECR.Properties.VariableNames{2} = 'ParticipantID';
ECR.Properties.VariableNames{3} = 'PartnerID';
ECR.Avomycalc = avo;

writetable(ECR,'ECR.xlsx')

%% Extract the PCS scores

PCS = quest(:,40:52);
subscales = quest(:,73:75);

PCSsum = quest(:,end-8);

PCS = [quest(:,1:3), PCS, PCSsum, subscales];

PCS = array2table(PCS);

PCS.Status = quest(:,71);
PCS.Status = categorical(PCS.Status);

number = 1:36;
name = 'PCS';

for i = 4:16
    
    PCS.Properties.VariableNames{strcat(name,num2str(i))} = strcat('Q',num2str(number(i-3)));
    
    eval(['PCS.' , 'Q',num2str(number(i-3)),' = str2double(','PCS.' , 'Q',num2str(number(i-3)),');'])

end

PCS.Properties.VariableNames{'PCS17'} = 'Total';
PCS.Total = str2double(PCS.Total);

PCS.Properties.VariableNames{'PCS18'} = 'Rumination';
PCS.Rumination = str2double(PCS.Rumination);

PCS.Properties.VariableNames{'PCS19'} = 'Helplessness';
PCS.Helplessness = str2double(PCS.Helplessness);

PCS.Properties.VariableNames{'PCS20'} = 'Magnification';
PCS.Magnification = str2double(PCS.Magnification);

PCS.Properties.VariableNames{2} = 'ParticipantID';
PCS.Properties.VariableNames{3} = 'PartnerID';

writetable(PCS,'PCS.xlsx')

%% DAS Extraction

DAS = quest(:,53:53+14);
ids = quest(:,1:3);

DASsum = quest(:,end-7);

DAS = [ids,DAS, DASsum];

DAS = array2table(DAS);

name = 'DAS';

for i = 4:17
    
    DAS.Properties.VariableNames{strcat(name,num2str(i))} = strcat('Q',num2str(number(i-3)));
    
    eval(['DAS.' , 'Q',num2str(number(i-3)),' = str2double(','DAS.' , 'Q',num2str(number(i-3)),');'])

end

DAS.Properties.VariableNames{'DAS18'} = 'Total';
DAS.Total = str2double(DAS.Total);

DAS.Consensus = sum(table2array(DAS(:,4:9)),2);
DAS.Satisfaction = sum(table2array(DAS(:,10:13)),2);
DAS.Cohesion = sum(table2array(DAS(:,14:17)),2);

DAS.Status = quest(:,71);
DAS.Status = categorical(DAS.Status);

DAS.Properties.VariableNames{2} = 'ParticipantID';
DAS.Properties.VariableNames{3} = 'PartnerID';

writetable(DAS,'DAS.xlsx')
