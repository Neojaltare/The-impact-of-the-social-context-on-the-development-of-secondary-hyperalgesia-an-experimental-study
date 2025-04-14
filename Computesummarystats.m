MFSIntensity = readtable("MFSIntensity.xls");
MFSint = MFSIntensity(:,[4 57 58]);
MFSIntsummary = groupsummary(MFSint,["Condition","Train"],["mean","std"])

MFSUnpleasantness = readtable("MFSUnpleasantness.xls");
MFSunp = MFSUnpleasantness(:,[4 57 58]);
MFSunpsummary = groupsummary(MFSunp,["Condition","Train"],["mean","std"])

MFSunpsummary.Condition = [];
MFSunpsummary.Train = [];
MFSunpsummary.GroupCount = [];

MFSsummary = [MFSIntsummary MFSunpsummary];

writetable(MFSsummary,"MFSSummary.xls")

IntegratedData = readtable("IntegratedData.xls");

RMSSDParticipantOR = readtable("RMSSDParticipantOR.xls");

rmssd = RMSSDParticipantOR(:,[5 17 18]);

rmssd(rmssd.Time == "ParticipantRec",:) = [];
RMSSDsummary = groupsummary(rmssd,["Condition","Time"],["mean","std"])
writetable(RMSSDsummary,"RMSSDSummary.xls")

synchcorr = readtable("Synchcorr.xls");
synchcorr.ID = [];
Synchsummary = groupsummary(synchcorr,["Condition","Time"],["mean","std"])
writetable(Synchsummary,"SynchSummary.xls")


