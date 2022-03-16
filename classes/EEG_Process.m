classdef EEG_Process < Process
    %
    % Class: EEG_Process
    % 
    % Supported Processes: 
    %   - Review Raw Files
    %   - Add EEG Position
    %   - Refine Registration
    %   - Project Electrodes on Scalp
    %   - Notch Filter
    %   - Band-Pass Filter
    %   - Power Spectrum Density
    %   - Average Reference
    %   - ICA
    %   - Export To BIDS    
    
    properties (Access = public)
        
        Type = 'EEG';
        
    end
    
    properties (Access = protected)
        
        Analyzer = EEG_Analysis();
        SpecificProcesses = [...
            "Add EEG Position", ...
            "Refine Registration", ...
            "Project Electrode On Scalp", ...
            "Average Reference"];
    end 
    
    methods (Access = public)
        
        function obj = EEG_Process(name, varargin)
            obj@Process(name, varargin);
        end
        
        function sFilesOut = run(obj, sFilesIn)
            % Run process.
            % param[in]: sFiles [struct]
            % param[out]: sFiles [struct]
            
            assert(~all(structfun(@isempty, obj.Parameters)), ...
            'Cannot run the process since all the parameters are empty!')
            
            if nargin == 1
                sFilesIn = [];
            end
        
            if obj.IsGeneral
                sFilesOut = run@Process(obj, sFilesIn);
            else
                switch obj.fName
                    
                    case 'process_channel_addloc'
                        
                        sFilesOut = obj.Analyzer.addEegPosition(sFilesIn, ...
                            obj.Parameters.FileType, ...
                            obj.Parameters.Cap, ...
                            obj.Parameters.ElectrodeFile);

                    case 'process_headpoints_refine'
                        sFilesOut = obj.Analyzer.refineRegistration(sFilesIn);

                    case 'process_channel_project'
                        sFilesOut = obj.Analyzer.projectElectrodesOnScalp(sFilesIn);

                    case 'process_eegref'
                        sFilesOut = obj.Analyzer.averageReference(sFilesIn);

                end
            end
            
            obj.addToHistory();
            
        end
         
    end
    
    methods (Access = protected)
        
        function initialization(obj)
            % Gets the sProcess and initialize the Parameters structure.
            % param[out]: sProcess [struct]

            initialization@Process(obj)
            
            if ~obj.IsGeneral
                switch obj.Name                   

                    case obj.SpecificProcesses(1)
                        obj.fName = 'process_channel_addloc';
                        obj.Parameters.FileType = char.empty();
                        obj.Parameters.ElectrodeFile = char.empty();
                        obj.Parameters.Cap = char.empty();

                    case obj.SpecificProcesses(2)
                        obj.fName = 'process_headpoints_refine';
                        obj.Parameters.ToRun = logical.empty();

                    case obj.SpecificProcesses(3)
                        obj.fName = 'process_channel_project';
                        obj.Parameters.ToRun = logical.empty();

                    case obj.SpecificProcesses(4)
                        obj.fName = 'process_eegref';
                        obj.Parameters.ToRun = logical.empty();

                    otherwise
                        error(['You entered an invalid process name (' obj.Name '). ' ...
                              'Here are the list of supported process. The name is case sensitive!' ...
                              newline newline sprintf(['<strong>' obj.printSupportedProcess() ...
                              '</strong>'])]);
                          
                end 
            end
            
            obj.sProcess = panel_process_select('GetProcess', obj.fName);
            obj.Documentation = Documentation(obj.sProcess);
            
        end
        
    end
    
end

