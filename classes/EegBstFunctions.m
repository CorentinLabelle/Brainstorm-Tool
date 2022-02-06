classdef EegBstFunctions < BasicBstFunctions
    
    properties
        sensortType = 'EEG';
    end
    
    methods
        function obj = EegBstFunctions()
        end
        
        function sFiles = addEegPosition(~, sFiles, fileType, capNumber, electrodeFile)
            
            if fileType == "Use Default Pattern" 
                electrodeFile = '';
                fileFormat = '';
                vox2ras = 1;

            elseif fileType == "Import"
                fileFormat = 'XENSOR';
                capNumber = 1;
                vox2ras = 0;
            end

            bst_process('CallProcess', 'process_channel_addloc', sFiles, [], ...
                        'channelfile', {electrodeFile, fileFormat}, ...
                        'usedefault', capNumber, ...
                        'fixunits', 1, ...
                        'vox2ras', vox2ras);                    
        end
        
        function refineRegistration(~, sFiles)
            bst_process('CallProcess', 'process_headpoints_refine', sFiles, []);
        end
        
        function projectElectrodesOnScalp(~, sFiles)
           bst_process('CallProcess', 'process_channel_project', sFiles, []); 
        end
       
        function detectOtherArtifact(obj, sFiles, LowFreq, HighFreq) 
           detectOtherArtifact@BasicBstFunctions(obj, sFiles, obj.sensorType, LowFreq, HighFreq);
        end
        
        function sFiles = notchFilter(obj, sFiles, frequence)
            sFiles = notchFilter@BasicBstFunctions(obj, sFiles, obj.sensortType, frequence);
        end
        
        function sFiles = bandPassFilter(obj, sFiles, frequence)
            sFiles = bandPassFilter@BasicBstFunctions(obj, sFiles, obj.sensortType, frequence);
        end
        
        function powerSpectrumDensity(obj, sFiles)
            powerSpectrumDensity@BasicBstFunctions(obj, sFiles, obj.sensortType, 10);
        end
        
        function averageReference(obj, sFiles)
            bst_process('CallProcess', 'process_eegref', sFiles, [], ...
                        'eegref', 'AVERAGE', ...
                        'sensortypes', obj.sensortType);

            viewComponents(obj, sFiles);
        end
        
        function ica(obj, sFiles, nbComponents)
            ica@BasicBstFunctions(obj, sFiles, nbComponents, obj.sensortType);
        end
        
        function runPipeline(obj, sFiles, sProcess)
            if(isfield(sProcess,'AddEEGPosition'))
                param = sProcess.AddEEGPosition;
                if param.FileType == "Use Default Pattern"
                    param.ElectrodeFile = '';
                end
                
                sFiles = obj.addEegPosition(sFiles, param.FileType, param.CapNumber, ...
                    param.ElectrodeFile);
            end
            
            if(isfield(sProcess,'RefineRegistration'))
                obj.refineRegistration(sFiles);
            end
            
            if(isfield(sProcess,'ProjectElectrodesOnScalp'))
                obj.projectElectrodesOnScalp(sFiles);
            end
            
            if(isfield(sProcess,'NotchFilter'))
                param = sProcess.NotchFilter;
                sFiles = obj.notchFilter(sFiles, param.Frequence);
            end
            
            if(isfield(sProcess,'BandPassFilter'))
                param = sProcess.BandPassFilter;
                sFiles = obj.bandPassFilter(sFiles, param.Frequence);
            end
            
            if(isfield(sProcess,'PowerSpectrumDensity'))
                obj.powerSpectrumDensity(sFiles);
            end
            
            if(isfield(sProcess,'AverageReference'))
                obj.averageReference(sFiles);
            end
            
            if(isfield(sProcess,'ICA'))
                param = sProcess.ICA;
                obj.ica(sFiles, param.NumberOfComponents);
            end
            
%             if(isfield(sProcess, 'ConvertToBids'))
%                 param = sProcess.ConvertToBids;
%             end
        end
    end
end

