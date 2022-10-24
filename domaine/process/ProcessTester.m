classdef ProcessTester < matlab.unittest.TestCase
        
    properties (Access = private)
        ProcessName = "review_raw_files";
        ProcessNameAsString = ["notch_filter", "band_pass_filter", "ica"];
    end
    
    methods(TestMethodTeardown)
        
    end
    
    methods (Test)
        
        function createWithEmptyInput(tc)
            tc.verifyError(@() Process.create(), ?MException);            
        end
        
        function createScalarWithNameString(tc)
            pr = Process.create(string(tc.ProcessName));
            tc.verifyTrue(isscalar(pr));
            tc.verifyEqual(tc.ProcessName, pr.getName());
        end
        
        function createScalarWithNameChar(tc)
            pr = Process.create(char(tc.ProcessName));
            tc.verifyTrue(isscalar(pr));
            tc.verifyEqual(tc.ProcessName, pr.getName());
        end
        
        function createScalarWithInvalidName(tc)
            tc.verifyError(@() Process.create('invalid Name'), ?MException); 
        end
        
        function createCellWithName(tc)
            pr = Process.create(tc.ProcessNameAsString);
            tc.verifyClass(pr, 'cell');
            tc.verifyTrue(all(cellfun(@(x) isa(x, 'Process'), pr)));
            tc.verifyEqual(tc.ProcessNameAsString, cellfun(@(x) x.getName(), pr));
        end
                 
        function createWithAnInteger(tc)
            tc.verifyError(@() Process.create(4), ?MException);            
        end
        
        function createWithEmptyChar(tc)
            tc.verifyError(@() Process.create(''), ?MException);            
        end
        
        function createWithEmptyString(tc)
            tc.verifyError(@() Process.create(""), ?MException);            
        end
        
        function createWithProcessCell(tc)
            prCell = Process.create(tc.ProcessNameAsString);
            prCell2 = Process.create(prCell);
            tc.verifyEqual(prCell, prCell2);
        end
        
        function setParameterWithValidInput(tc)
            pr = Process.create(tc.ProcessName);
            subjects = {'Harry'};
            rawFiles = {'folder/file.eeg'};
            pr = pr.setParameter('subjects', subjects);
            pr = pr.setParameter('raw files', rawFiles);
            tc.verifyEqual(pr.getParameter().subjects, subjects);
            tc.verifyEqual(pr.getParameter().raw_files, rawFiles);            
        end
        
        function setParametersWithInvalidValue(tc)
            nf = Process.create('notch filter');
            tc.verifyError(@() nf.setParameter('Frequence', '60'), ?MException);
        end
        
        function setParametersWithInvalidField(tc)
            nf = Process.create('notch filter');
            tc.verifyError(@() nf.setParameter('Frequences', 60), ?MException); 
        end
        
        function setParameterWithStructure(tc)
            rrf = Process.create('Review Raw Files');            
            param.subjects = {'Robert', 'Lewandowski'};
            param.raw_files = {...
                {'somefolder1/somename1.ext', 'somefolder2/somename2.ext'}, ...
                {'somefolder3/somename3.ext', 'somefolder4/somename4.ext'},...
                };            
            rrf = rrf.setParameterWithStructure(param);            
            tc.verifyEqual(rrf.getParameter(), param);            
        end
        
        function equalityBetweenTwoScalars(tc)
            specPr1 = Process.create('notch filter');
            specPr1.setParameter('Frequence', 60);            
            specPr2 = Process.create('notch filter');
            param.Frequence = 60;
            specPr2.setParameterWithStructure(param);            
            tc.verifyTrue(specPr1 == specPr2);            
        end
        
        function equalityBetweenCellsAndScalar(tc)
            prCell = process.create(tc.ProcessNameAsString);
            pr = process.create('notch Filter');
            disp(prCell == pr);
            tc.verifyEqual(logical([1 0 0 0]), specPr1 == specVector);
            tc.verifyEqual(logical([1 0 0 0]), specVector == specPr1);
            tc.verifyEqual(logical([0 1 0 0]), specPr2 == specVector);
            tc.verifyEqual(logical([0 1 0 0]), specVector == specPr2);
            tc.verifyEqual(logical([0 0 1 0]), specPr3 == specVector);
            tc.verifyEqual(logical([0 0 1 0]), specVector == specPr3);
            
        end
                
        function printProcess(tc)
            pr = Process.create('ica');
            characters = pr.convertToCharacters();
            tc.verifyClass(characters, 'char');
        end
        
    end
    
end