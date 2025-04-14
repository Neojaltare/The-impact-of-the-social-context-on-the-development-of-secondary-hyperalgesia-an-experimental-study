% Script to add an 'Order' column to multiple data tables based on condition
% Order = 1 for SUPPORT, 2 for ALONE

% Load all required tables (assumes files are in the current working directory)
Intensity = readtable('Intensity.xls');
Unpleasantness = readtable('Unpleasantness.xls');
Arealength = readtable('Arealength.xls');
Areawidth = readtable('Areawidth.xls');
RMSSD = readtable('RMSSDParticipantOR.xls');
IntegratedData = readtable('IntegratedData.xls');

% Add 'Order' column to each dataset
Intensity = addOrderColumn(Intensity, IntegratedData, 'ParticipantID');
Unpleasantness = addOrderColumn(Unpleasantness, IntegratedData, 'ParticipantID');
Arealength = addOrderColumn(Arealength, IntegratedData, 'ParticipantID');
Areawidth = addOrderColumn(Areawidth, IntegratedData, 'ParticipantID');
RMSSD = addOrderColumn(RMSSD, IntegratedData, 'Number');

% Save the updated tables
writetable(Intensity, 'Intensity_withOrder.xls');
writetable(Unpleasantness, 'Unpleasantness_withOrder.xls');
writetable(Arealength, 'Arealength_withOrder.xls');
writetable(Areawidth, 'Areawidth_withOrder.xls');
writetable(RMSSD, 'RMSSDParticipantOR_withOrder.xls');

%% Helper function
function dataTable = addOrderColumn(dataTable, integratedData, idField)
    % Adds an 'Order' column to the input table based on matching ID with IntegratedData
    order = nan(height(dataTable), 1); % Preallocate

    for i = 1:height(dataTable)
        participant = dataTable.(idField)(i);
        temp = integratedData.Condition(integratedData.ParticipantID == participant);

        if ~isempty(temp)
            if strcmpi(temp{1}, 'SUPPORT')
                order(i) = 1;
            elseif strcmpi(temp{1}, 'ALONE')
                order(i) = 2;
            end
        end
    end

    dataTable.Order = order;
end

