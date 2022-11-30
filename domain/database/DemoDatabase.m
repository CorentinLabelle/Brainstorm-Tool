clear
clc

db = Database();

%% Get names
names = db.getProcessNames();

%%
processClasses = db.getProcessClassWithName('add eeg position')