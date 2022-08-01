classdef DatabaseSearcherTester < matlab.unittest.TestCase   
    
    methods (TestMethodSetup)
        
        function createTestProtocol(~)
            createTestProtocol();
        end
        
    end
    
    methods (TestMethodTeardown)
        
    end
    
    methods (Test)
        
        function selectAllFilesFromOneSubject(tc)
           
            sFile = DatabaseSearcher.searchQuery("path", "contains", "Harry");
            tc.verifyTrue(all(strcmpi({sFile.SubjectName}, 'Harry')));
            
        end
        
        function selectOneStudy(tc)
            
            sFile = DatabaseSearcher.selectFiles({'Harry'}, {'@rawb1'});
            tc.verifyTrue(length(sFile) == 1);
            tc.verifyTrue(strcmpi(sFile.SubjectName, 'Harry'));
            tc.verifyTrue(strcmpi(sFile.Condition, '@rawb1'));
            
            sFile = DatabaseSearcher.searchQuery("path", "equals", "Harry/@rawb1/data_0raw_b1.mat");
            tc.verifyTrue(length(sFile) == 1);
            tc.verifyTrue(strcmpi(sFile.SubjectName, 'Harry'));
            tc.verifyTrue(strcmpi(sFile.Condition, '@rawb1'));
            
            sFile = DatabaseSearcher.selectFiles({'Harry'}, {'@rawb1_notch'});
            tc.verifyTrue(length(sFile) == 1);
            tc.verifyTrue(strcmpi(sFile.SubjectName, 'Harry'));
            tc.verifyTrue(strcmpi(sFile.Condition, '@rawb1_notch'));
            
        end
        
        function selectNotchedStudies(tc)
            
            sFiles = DatabaseSearcher.searchQuery(  "parent", "contains", "notch", "and", ...
                                                    "parent", "not contains", "band");
            tc.verifyTrue(length(sFiles) == 12);
            tc.verifyTrue(all(contains({sFiles.Condition}, 'notch')));
            
        end
        
        function selectNotchedAndBandPassedStudies(tc)
            
            sFiles = DatabaseSearcher.searchQuery(  "parent", "contains", "notch", "and", ...
                                                    "parent", "contains", "band");
            tc.verifyTrue(length(sFiles) == 12);
            tc.verifyTrue(all(contains({sFiles.Condition}, 'notch')));
            tc.verifyTrue(all(contains({sFiles.Condition}, 'band')));
            
        end
        
        function selectBandPassedStudies(tc)
            
            sFiles = DatabaseSearcher.searchQuery(  "parent", "contains", "band", "and", ...
                                                    "parent", "not contains", "notch");
            tc.verifyTrue(length(sFiles) == 12);
            tc.verifyTrue(all(contains({sFiles.Condition}, 'band')));
            
        end
        
        function selectNotchedStudyFromOneSubject(tc)
            
            sFiles = DatabaseSearcher.searchQuery(  "path", "contains", "notch", "and", ...
                                                    "path", "contains", "Harry");
            tc.verifyTrue(all(contains({sFiles.Condition}, 'notch')));
            tc.verifyTrue(all(strcmpi({sFiles.SubjectName}, 'Harry')));
            
        end
        
    end
    
    
      
end

% Exact Search Query
% 
% sFiles1 = bst_process('CallProcess', 'process_select_search', [], [], ...
%                     'search', '([path EQUALS "Ron/@rawb1/data_0raw_b1.mat"])');
%                 
%                 
% sFiles2 = bst_process('CallProcess', 'process_select_search', [], [], ...
%                     'search', '([parent EQUALS "@rawb1_notch"])');
