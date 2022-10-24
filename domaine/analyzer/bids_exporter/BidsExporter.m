classdef BidsExporter < handle
    
    properties (Access = private)        
        pathCreator BidsPathCreator;
    end
    
    methods (Access = public)
        
        function sFiles = export(obj, listOfParameters, sFiles)            
            bidsFolderPath = obj.createBidsFolder(listOfParameters.getConvertedValue(1));
            eventDescriptorPath = EventDescriptorCreator.getEventDescriptor(sFiles);
            
            for i = 1:length(sFiles)                
                isRaw = SFileManager.isSFileRaw(sFiles(i));
                sFileForProvenance = sFiles(i);
                if isRaw
                    sFileToExportToBids = sFiles(i);
                else
                    sFileToExportToBids = BidsExporter.exportAndReimportsFile(sFiles(i));
                end
                
                BidsExporter.brainstormExportToBidsFunction(...
                            listOfParameters, ...
                            sFileToExportToBids, ...
                            bidsFolderPath);
                        
                obj.createSideCarFiles(sFileToExportToBids, sFileForProvenance, eventDescriptorPath);
                
                if ~isRaw
                    obj.deleteReimportedStudyAndTemporaryFiles(sFileToExportToBids);
                end                
            end
        end
        
    end
    
    methods (Access = private)
        
        function bidsFolderPath = createBidsFolder(obj, bidsFolderPath)
            obj.pathCreator = BidsPathCreator(bidsFolderPath);
            bidsFolderPath = obj.pathCreator.getValidBidsPath();
            mkdir(bidsFolderPath);
        end
        
        function createSideCarFiles(obj, sFile, sFileRaw, eventDescriptorPath)            
            BidsFileCreator.createEventFile(sFile, obj.pathCreator.getEventFilePath(sFile));
            BidsFileCreator.createEventMetaDataFile(sFile, obj.pathCreator.getEventMetaDataFilePath(sFile), eventDescriptorPath);
            BidsFileCreator.createProvenanceFile(sFileRaw, obj.pathCreator.getProvenanceFilePath(sFileRaw));
            BidsFileCreator.createChannelFile(sFile, obj.pathCreator.getChannelFilePath(sFile));
            BidsFileCreator.createElectrodeFile(sFile, obj.pathCreator.getElectrodeFilePath(sFile));
            %fileCreator.createCoordinateSystemFile(sFile, obj.pathCreator.getCoordinateFilePath(sFile));
        end
        
    end
    
    methods (Static, Access = private)  
        
        function deleteReimportedStudyAndTemporaryFiles(sFileExportedToBids)           
            StudyManager.deleteStudy(sFileExportedToBids);
            temporaryFolder = BidsExporter.getTemporaryFolderToExportProcessedsFile();
            delete(fullfile(temporaryFolder, '*'));
            rmdir(temporaryFolder);
        end
        
        function sFileReimported = exportAndReimportsFile(sFileToExportAndReimport)            
            sFileExported = BidsExporter.exportData(sFileToExportAndReimport);            
            subject = sFileToExportAndReimport.SubjectName;
            sFileReimported = BidsExporter.reImportsFile(subject, sFileExported.filename);                    
        end
        
        function sFileExported = exportData(sFile)           
            temporaryFolder = BidsExporter.getTemporaryFolderToExportProcessedsFile();
            if ~isfolder(temporaryFolder)
                mkdir(temporaryFolder);
            end
            
            exportDataProcess = Process.create('Export Data');
            exportDataProcess = exportDataProcess.setParameter(1, temporaryFolder);
            exportDataProcess = exportDataProcess.setParameter(2, 2);
            exportDataProcess = exportDataProcess.setParameter(3, 2);
            
            sFileExported = exportDataProcess.run(sFile);            
        end
              
        function sFile = reImportsFile(subject, fileName)           
            rrf = Process.create('Review Raw Files');
            rrf = rrf.setParameter(1, {subject});
            rrf = rrf.setParameter(2, {fileName});
            rrf = rrf.setParameter(3, 2);                                           
            sFile = rrf.run();            
        end      
        
        function temporaryFolder = getTemporaryFolderToExportProcessedsFile()            
            temporaryFolder = fullfile(pwd, 'temporaryFolder');            
        end
        
        function sFile = brainstormExportToBidsFunction(listOfParameters, sFile, bidsPath)
            taskDescription = listOfParameters.getConvertedValue(6);
            datasetDesc = BidsExporter.formatStructToCharacters(listOfParameters.getConvertedValue(7));
            datasetSidecar = BidsExporter.formatStructToCharacters(listOfParameters.getConvertedValue(8));
            sFile = bst_process('CallProcess', 'process_export_bids', sFile, [], ...
                 'bidsdir',       {bidsPath, 'BIDS'}, ...
                 'subscheme',     2, ...  % Number index
                 'sesscheme',     1, ...  % Acquisition date
                 'emptyroom',     'emptyroom, noise', ...
                 'defacemri',     0, ...
                 'overwrite',     0, ...
                 'powerline',     2, ...  % 60 Hz
                 'dewarposition', 'Upright', ...
                 'eegreference',  'Cz', ...
                 'edit',          struct(...
                 'ProjName',    listOfParameters.getConvertedValue(2), ...
                 'ProjID',      listOfParameters.getConvertedValue(3), ...
                 'ProjDesc',    listOfParameters.getConvertedValue(4), ...
                 'Categories',  listOfParameters.getConvertedValue(5), ...
                 'JsonDataset', ['{' 10 '  "License": "PD"' datasetDesc '}'], ...
                 'JsonMeg',     ['{' 10 '  "TaskDescription": "' taskDescription '"' datasetSidecar '}']));                 
        end
        
        function structAsChars = formatStructToCharacters(structure)           
           fields = string(fieldnames(structure)');
           value = strings(1, length(fields));
           for i = 1:length(fields)
               value(i) =  string(structure.(fields(i)));
           end
           structAsChars = [char(strjoin("," + newline + '  "' + fields + '": ' + '"' + value + '"', '\n')) 10];
        end
        
    end
    
end