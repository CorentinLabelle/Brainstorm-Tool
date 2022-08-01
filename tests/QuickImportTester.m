classdef QuickImportTester < matlab.unittest.TestCase
        
    properties (Access = private)
        
        FolderPath = ...
            ['/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/' ...
            'ALAB1/corentin/scripts/AnalysisTool/tests/'];
        
        FolderName = 'DataQuickImportTester';
    
    end
    
    methods (TestMethodSetup)
        
    end
    
    methods(TestMethodTeardown)
        
    end
    
    methods (Test)
        
        function invalidFolder(tc)
           
            tc.verifyError(@() quickImport('SomeInvalidFolder'), '');

        end
        
        function emptyFolder(tc)
           
            emptyFolderName = 'emptyFolder';
            path = fullfile(tc.FolderPath, emptyFolderName);
            
            mkdir(path);
            [subjects, rawFiles] = quickImport(path);
            rmdir(path)
            
            tc.verifyTrue(isempty(subjects));
            tc.verifyTrue(isempty(rawFiles));

        end
        
        function validFolder(tc)
           
            path = fullfile(tc.FolderPath, tc.FolderName);
            
            [subjects, rawFiles] = quickImport(path);
            
            tc.verifyClass(subjects, 'cell');
            tc.verifyClass(rawFiles, 'cell');
            
            tc.verifyTrue(length(subjects) == length(rawFiles));
            tc.verifyTrue(length(subjects) == 23);
            
            rdmIndex = randi(length(subjects), 1);
            tc.verifyTrue(strcmp(subjects{rdmIndex}, ['S' num2str(rdmIndex, '%02.f')]));
            
        end
        
    end
    
end
