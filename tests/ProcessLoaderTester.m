classdef ProcessLoaderTester < matlab.unittest.TestCase

    methods(TestMethodSetup)
    end
    
    methods(TestMethodTeardown)
    end
    
    methods (Test)
        
        function loadProcesses(tc)
            
            allProcesses = ProcessLoader.loadDefaultProcesses();
            tc.verifyTrue(~isempty(allProcesses));
            
        end
        
    end
    
end