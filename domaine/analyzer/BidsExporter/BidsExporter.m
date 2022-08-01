classdef BidsExporter < handle
    
    properties (Access = private)
        
        pathCreator BidsPathCreator;
        
        sFilesToExport struct = struct.empty;
        BidsFolderPath;
        
    end
    
    methods (Access = public)

        function obj = BidsExporter(sFilesToExport, bidsFolder)
            
            obj.sFilesToExport = sFilesToExport;
            obj.BidsFolderPath = bidsFolder; 
            
        end
        
        function sFiles = export(obj)
            
            obj.pathCreator = BidsPathCreator(obj.BidsFolderPath);
            bidsFolderPath = obj.pathCreator.getValidBidsPath();
            mkdir(bidsFolderPath);
            
            for i = 1:length(obj.sFilesToExport)
                
                isRaw = SFileManager.isSFileRaw(obj.sFilesToExport(i));
                if isRaw
                    rawsFile = obj.sFilesToExport(i);
                    sFileToExport = rawsFile;
                else
                    sFileToExport = obj.exportAndReimportsFile(obj.sFilesToExport(i));
                    rawsFile = sFileToExport;
                end
                
                sFileExported = obj.brainstormExportToBidsFunction(sFileToExport, ...
                                                    bidsFolderPath);
                 
                obj.createSideCarFiles(sFileToExport, rawsFile);
                
                if ~isRaw
                    obj.deleteReimportedStudyAndTemporaryFiles(sFileExported);
                end
                
            end
            
            sFiles = obj.sFilesToExport;
        
        end
        
    end
    
    methods (Access = private)

        function createSideCarFiles(obj, sFile, sFileRaw)
           
            fileCreator = BidsFileCreator();
            
            fileCreator.createEventFile(sFile, obj.pathCreator.getEventFilePath(sFile));
            fileCreator.createEventMetaDataFile(sFile, obj.pathCreator.getEventMetaDataFilePath(sFile));
            fileCreator.createProvenanceFile(sFileRaw, obj.pathCreator.getProvenanceFilePath(sFileRaw));
            fileCreator.createChannelFile(sFile, obj.pathCreator.getChannelFilePath(sFile));
            fileCreator.createElectrodeFile(sFile, obj.pathCreator.getElectrodeFilePath(sFile));
            %fileCreator.createCoordinateSystemFile(sFile, obj.pathCreator.getCoordinateFilePath(sFile));
            
        end
        
        function sFileReimported = exportAndReimportsFile(obj, sFileToExportAndReimport)
            
            sFileExported = obj.exportData(sFileToExportAndReimport);
            
            subject = sFileToExportAndReimport.SubjectName;
            sFileReimported = obj.reImportsFile(subject, sFileExported.filename);
                    
        end

        function sFileExported = exportData(obj, sFile)
           
            temporaryFolder = obj.getTemporaryFolderToExportProcessedsFile();
            
            exportDataProcess = Process.create('Export Data');
            exportDataProcess.setParameter('Folder', temporaryFolder, ...
                                           'File_Format', 'brainvision');
                                       
            if ~isfolder(temporaryFolder)
                mkdir(temporaryFolder);
            end
            
            sFileExported = exportDataProcess.run(sFile);
            
        end
        
    end
    
    methods (Static, Access = private)
        
        function temporaryFolder = getTemporaryFolderToExportProcessedsFile()
            
            temporaryFolder = fullfile(pwd, 'temporaryFolder');
            
        end
        
        function deleteReimportedStudyAndTemporaryFiles(sFileExportedToBids)
           
            DeleteStudy(sFileExportedToBids);
            temporaryFolder = BidsExporter.getTemporaryFolderToExportProcessedsFile();
            delete(fullfile(temporaryFolder, '*'));
            rmdir(temporaryFolder);
            
        end
              
        function sFile = reImportsFile(subject, fileName)
           
            reviewRawFilesProcess = Process.create('Review Raw Files');
            reviewRawFilesProcess.setParameter('Subjects', {subject}, ...
                                               'Raw_Files', {fileName});
                                           
            sFile = reviewRawFilesProcess.run();
            
        end
        
        function sFile = brainstormExportToBidsFunction(sFile, bidsPath)
            
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
                 'ProjName',    [], ...
                 'ProjID',      [], ...
                 'ProjDesc',    [], ...
                 'Categories',  [], ...
                 'JsonDataset', ['{' 10 '  "License": "PD"' 10 '}'], ...
                 'JsonMeg',     ['{' 10 '  "TaskDescription": "My task"' 10 '}']));
                 
        end
        
    end
    
end