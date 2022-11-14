classdef PipelineDetailsTester < matlab.unittest.TestCase
    
    properties (Access = private)
       PipelineName = "Name Of Pipeline"; 
    end
    
    methods (Test)
       
        function emptyConstructor(tc)
            pipDetails = PipelineDetails();
            tc.verifyTrue(pipDetails.isEmpty());
        end
        
        function setNameWithChars(tc)
           pipDetails = PipelineDetails();
           pipName = char(tc.PipelineName());
           
           pipDetails.setName(pipName);
           
           tc.verifyEqual(pipDetails.Name, tc.PipelineName());
        end
        
        function setNameWithStrings(tc)
           pipDetails = PipelineDetails();
           pipName = string(tc.PipelineName());
           
           pipDetails.setName(pipName);
           
           tc.verifyEqual(pipDetails.Name, tc.PipelineName());
        end
        
    end
    
end
