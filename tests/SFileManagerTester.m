classdef SFileManagerTester < matlab.unittest.TestCase   
    
    methods (TestMethodSetup)
        
        function createTestProtocol(~)
            CreateTestProtocol();
        end
        
    end
    
    methods (TestMethodTeardown)
        
    end
    
    methods (Test)
        
        
        function getsFilesFromStudyLinks(tc)

            sFiles = DatabaseSearcher.searchQuery("name", "contains", "");
            studyLink = {sFiles.FileName};
            sFiles = SFileManager.getsFileFromMatLink(studyLink);
            tc.verifyTrue(isa(sFiles, 'struct'));
            
        end
        
    end
    
    
      
end



