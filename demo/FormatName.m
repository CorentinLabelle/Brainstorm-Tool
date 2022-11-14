%% Format a name to a valid process name
clear
clc

name = 'band pAss fiLter';
nameFormated = Process.formatProcessName(name);

disp([  newline ...
        'unformated name: ' name newline ...
        'formated name: '   nameFormated ...
        newline]);
    
%% End
endMessage;