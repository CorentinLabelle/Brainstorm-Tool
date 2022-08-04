
% Old compilation
tic
clear
clc

%AppFile = fullfile('C:\Users\alab\Desktop\Corentin', 'AnalysisTool', 'interface', 'Analysis_Tool.mlapp');
AppFile = '/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/app test/test_bst_app.mlapp';
%OutputDir = 'C:\Users\alab\Desktop\ToolCompiled';
OutputDir = '/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1';

%folderToAdd = ["C:\Users\alab\Desktop\Corentin\AnalysisTool\domaine", "C:\Users\alab\Desktop\Corentin\AnalysisTool\interface"];
%rep = getAllAdditionnalFiles(folderToAdd);
%rep = '';

w = waitbar(1, 'Compiling...', 'Name', 'Compiling...');
disp('Compiling...');

%results = compiler.build.standaloneApplication(AppFile, 'AdditionalFiles', rep, 'OutputDir', OutputDir);
results = compiler.build.standaloneApplication(AppFile, 'OutputDir', OutputDir);

delete(w);
disp('Done!');
disp(results);

winopen(OutputDir);
toc

function files = getAllAdditionnalFiles(directory)

    files = [];
    for i = 1:length(directory)
        content = dir(directory(i));

        for j = 1:length(content)
    
            if any(strcmp(content(j).name, [".", ".."]))
                continue
            end
    
            if content(j).isdir
               files = [files, getAllAdditionnalFiles(string(fullfile(content(j).folder, content(j).name)))];
    
            else
                [~, ~, extension] = fileparts(content(j).name);
    
                if any(strcmp(extension, [".m", ".png", ".mlapp"]))
                    files = [files string(fullfile(content(j).folder, content(j).name))];
                end
            end
        end
    end
end