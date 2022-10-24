function RunTests()
    clear
    clc
    
    testsToSkip = [ "ProtocolManagerTester.m", ...
                    "PipelineBuilderTester.m", ...
                    "AutomatedToolTester.m", ...
                    "AllProcessTester.m", ...
                    "AutomatedToolTester.m"];

    s = dbstack();
    currentFile = s(1).file;
    
    testFolder = '/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/projects/Brainstorm_Tool/tests';
    files = dir(testFolder);
    for i = 1:length(files)
        
        [~, name, extension] = fileparts(files(i).name);
        if files(i).isdir
            continue
        end
        if strcmpi(extension, '.json')
            continue
        end
        if strcmpi(currentFile, files(i).name)
            continue
        end
        if any(strcmpi(testsToSkip, files(i).name))
            continue
        end

        if exist(name, 'class')
            runtests(name);
        else
            run(name);
        end

    end
    
end