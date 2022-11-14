classdef ParameterTester < matlab.unittest.TestCase
    
    properties (Access = private)
        ParameterName = 'parameterName';
    end
    
    methods (Test)
        
        function constructor(tc)
            param = ParameterFactory.create(tc.ParameterName, 'char', char.empty());
            tc.verifyClass(param, 'BstParameter');
            disp(param);
            
            param = ParameterFactory.create(tc.ParameterName, 'numeric', double.empty(), {1, 2, 3});
            tc.verifyClass(param, 'ConstrainedParameter');
        end
        
    end
end