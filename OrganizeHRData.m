
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:
% This script loops through a series of participant folders containing 
% saved HRV (heart rate variability) analysis results from individual 
% sessions. It compiles the data from three domains:
%
% 1. **Time Domain (TD) Measures**  
%    - Extracts RMSSD, average RR interval (avgRR), mean HR, and SDNN
%    - Saves each metric as a separate `.xls` file
%
% 2. **Frequency Domain (FD) Measures**  
%    - Loads interpolated IBI signals and their power spectra
%    - Stores them in a 4D structure and saves as `FD.mat`
%
% 3. **Time-Frequency Domain (TF) Measures**  
%    - Loads time-frequency decompositions and phase synchrony data
%    - Stores them in a structured format and saves as `TF.mat`
%
% Assumptions:
% - Each folder name encodes participant number and condition (e.g., "12345SUPPORT")
% - Each folder contains files: `TDmeasures.mat`, `FDmeasures.mat`, `TFmeasures.mat`
%
% Output:
% - RMSSD.xls, avgRR.xls, meanHR.xls, sdnn.xls (time domain)
% - FD.mat (frequency domain)
% - TF.mat (time-frequency domain)
%
% Notes:
% - Update the `destination` variable to specify where to save the `.xls` files
% - The folder structure must be flat and accessible via `dir`
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


folders = dir;
names = strings(67,1);

for i = 3:length(folders)
    names(i) = string(folders(i).name);

end

names(1:3,:) = [];
path = string(folders(5).folder);
destination = "Path_to_destination_folder";


%% For Time Domain Measures

rmssd = array2table(zeros(0,8));
rmssd.Properties.VariableNames = {'ParticipantBase','ParticipantStim', 'ParticipantRec','PartnerBase',...
           'PartnerStim', 'PartnerRec','Number','Condition'};
rmssd.Condition = string(rmssd.Condition);
rmssd.Number = string(rmssd.Condition);

avgRR = array2table(zeros(0,8));
avgRR.Properties.VariableNames = {'ParticipantBase','ParticipantStim', 'ParticipantRec','PartnerBase',...
           'PartnerStim', 'PartnerRec','Number','Condition'};
avgRR.Condition = string(avgRR.Condition);
avgRR.Number = string(avgRR.Number);

meanHR = array2table(zeros(0,8));
meanHR.Properties.VariableNames = {'ParticipantBase','ParticipantStim', 'ParticipantRec','PartnerBase',...
           'PartnerStim', 'PartnerRec','Number','Condition'};
meanHR.Condition = string(meanHR.Condition);
meanHR.Number = string(meanHR.Condition);

sdnn = array2table(zeros(0,8));
sdnn.Properties.VariableNames = {'ParticipantBase','ParticipantStim', 'ParticipantRec','PartnerBase',...
           'PartnerStim', 'PartnerRec','Number','Condition'};
sdnn.Condition = string(sdnn.Condition);
sdnn.Number = string(sdnn.Condition);

varnames = sdnn.Properties.VariableNames;

for i = 1:length(names)

        source = strcat(path,'/',names(i),'/TDmeasures');
        load(source);
        tempname = char(names(i));
        number = tempname(1:5);
        cond = tempname(6:end);

        fields = fieldnames(TDmeasures);

        for k = 1:length(fields)

            eval(strcat('participant = TDmeasures.', string(fields(k)), '(1,:,1);'))
            eval(strcat('partner = TDmeasures.', string(fields(k)), '(1,:,2);'))

            temptable = array2table([participant partner]);
            temptable.number = string(number);
            temptable.Condition = string(cond);

            eval(strcat(string(fields(k)), '(i,:) = temptable(1,:);'))

        end

        clear TDmeasures


end



 writetable(rmssd,strcat(destination,'RMSSD.xls'))
 writetable(avgRR,strcat(destination,'avgRR.xls'))
 writetable(meanHR,strcat(destination,'meanHR.xls'))
 writetable(sdnn,strcat(destination,'sdnn.xls'))

 %% FD Domain measures


 FD = struct;


 for i = 1:length(names)

     source = strcat(path,'/',names(i),'/FDmeasures');
     load(source);
     tempname = names(i);

     FD.Interpolated(:,:,:,i) = FDmeasures.interpolated;
     FD.Id(i) = tempname;
     FD.ibix(:,:,:,i) = FDmeasures.ibix;
     FD.Interptime = FDmeasures.interptime;
     FD.ibixhz = FDmeasures.ibixhz;

     clear FDmeasures

 end

 save('FD.mat','FD')

 %% TF measures


 TF = struct;


 for i = 1:length(names)

     source = strcat(path,'/',names(i),'/TFmeasures');
     load(source);
     tempname = names(i);

     TF.tf(:,:,:,:,i) = TFmeasures.tf;
     TF.Id(i) = tempname;
     TF.angles(:,:,:,:,i) = TFmeasures.angles;
     TF.frex = TFmeasures.frex;
     TF.anglediffs(:,:,:,i) = TFmeasures.anglediffs;
     TF.synch(:,:,i) = TFmeasures.synch;


     clear TFmeasures

 end

TF.Interptime = FD.Interptime;

 save('TF.mat','TF')
