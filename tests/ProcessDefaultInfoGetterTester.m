classdef ProcessDefaultInfoGetterTester < matlab.unittest.TestCase
        
    properties (Access = private)
        
        getter = ProcessDefaultInfoGetter();
        
    end
    
    methods(TestMethodSetup)
    end
    
    methods(TestMethodTeardown)
        
    end
    
    methods (Test)
        
        function getPrClsWithValidType(tc)
            
            tc.verifyEqual(tc.getter.getPrClsWithType('eeg'), 'EEG_Process');
            tc.verifyEqual(tc.getter.getPrClsWithType('meg'), 'MEG_Process');
            tc.verifyEqual(tc.getter.getPrClsWithType('general'), 'GeneralProcess');
            tc.verifyEqual(tc.getter.getPrClsWithType('specific'), 'SpecificProcess');
            
        end
        
        function getPrClsWithInvalidType(tc)
            
            tc.verifyError(@() tc.getter.getPrClsWithType('e'), ?MException);
            tc.verifyError(@() tc.getter.getPrClsWithType(5), ?MException);
            
        end
        
        function getPrClsWithValidName(tc)
            
            tc.verifyEqual(tc.getter.getPrClsWithPrName('add eeg position'), 'EEG_Process');
            tc.verifyEqual(tc.getter.getPrClsWithPrName('convert epochs to continue'), 'MEG_Process');
            tc.verifyEqual(tc.getter.getPrClsWithPrName('review raw files'), 'GeneralProcess');
            tc.verifyEqual(tc.getter.getPrClsWithPrName('notch filter'), 'SpecificProcess');
            
        end
        
        function getPrClsWithInvalidName(tc)
            
            tc.verifyError(@() tc.getter.getPrClsWithPrName('a'), ?MException);
            tc.verifyError(@() tc.getter.getPrClsWithPrName(5), ?MException);
            
        end
        
        function getInitializedPrStructWithValidName(tc)
           
            paramStruct = tc.getter.getInitializedPrStruct('Notch Filter');
            snf = struct();
            snf.Parameter.frequence = double.empty();
            snf.fName = 'process_notch';
            snf.AnalyzerFct = @notchFilter;
            
            tc.verifyEqual(paramStruct, snf);
            
        end
        
        function getInitializedPrStructWithInvalidName(tc)
            
            tc.verifyError(@() tc.getter.getInitializedPrStruct('a'), ?MException);
            tc.verifyError(@() tc.getter.getInitializedPrStruct(7), ?MException);
            
        end
        
    end

end