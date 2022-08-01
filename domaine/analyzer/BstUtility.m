classdef BstUtility
    
    methods (Static, Access = public)            
       
        % Date Functions
        
        function edfDate = getDateFromEDF(path)
            
            fileid = fopen(path, 'r');
            textline = fgetl(fileid);
            fclose(fileid);
            index = strfind(textline, 'Startdate');
            edfDate = datetime(textline(index+10:index+10+10));
            
        end
        
        function getVmrkFilePathFromEEGFile(eegFile)
           
            [folder, file] = fileparts(eegFile);
            vmrkFilePath = strcat(fullfile(folder, file), '.vmrk');
            assert(isfile(vmrkFilePath));
            
        end
        
        function vmrkDate = getDateFromVmrk(vmrkFilePath)
            
            fileid = fopen(vmrkFilePath, 'r');
            % Skip 10 lines
            for j = 0:10  
                fgetl(fileid);
            end
            textline = fgetl(fileid);

            fclose(fileid);

            startDate = 24;
            vmrkDate = datetime(textline(startDate:startDate+13), 'InputFormat', 'yyyyMMddhhmmss');
                
            
        end
         
        function modifyEDFDate(edfFilePath, dateIn)
            
            fileid = fopen(edfFilePath, 'r');
            textline = fgetl(fileid);
            fclose(fileid);
            
            % First replacement
            index = strfind(textline, 'Startdate');
            dateIn.Format = 'dd-MMM-yyyy';
            newline = strrep(textline, textline(index+10:index+10+10), char(dateIn));
                
            % Second replacement
            dateIn.Format = 'dd.MM.yyhh.mm.ss';
            newline = strrep(newline, textline(169:184), char(dateIn));
  
            % Replace newlines in modified file
            % Open file to write
            fileid = fopen(edfFilePath, 'r+');
            
            % Write to file
            fprintf(fileid, '%c', newline);
            
            % Close file
            fclose(fileid);
            
        end
 
        function modifyBrainstormStudyMATDate(sFiles, date)
            
            assert(length(sFiles) == length(date), ...
                'sFiles and date cell should be of same length');
            
            getBstStudyPathHandle = ...
                str2func([mfilename('class') '.getBrainstormStudyPathFromSFile']);
            for i = 1:length(sFiles)
                
                brainstormstudyFilePath = getBstStudyPathHandle(sFiles(i));
                bstStudy = load(brainstormstudyFilePath);
                
                date{i}.Format = 'dd-MMM-yyyy';
                bstStudy.DateOfStudy = upper(char(date{i}));
                save(brainstormstudyFilePath, '-struct', 'bstStudy');
                
            end
 
        end
         
        function date = getDateFromBrainstormStudyMAT(sFiles)
            
            getBstStudyPathHandle = ...
                str2func([mfilename('class') '.getBrainstormStudyPathFromSFile']);
            
            date = NaT(1, length(sFiles));
            for i = 1:length(sFiles)
                brainstormStudyFile = getBstStudyPathHandle(sFiles(i));
                bsStudy = load(brainstormStudyFile);
                date(i) = datetime(bsStudy.DateOfStudy);
            end
            
        end
         
        
        
        % To improve       
       
        function rawFilesPath = MEGReviewRawFiles(subjectName)
            % A REVOIR AU COMPLET
            % Select Data or Noise file
            
            
            % Select Dataset 
            folder = uigetdir(app.WorkingFolderPath, title);      
            
            if isequal(folder, 0)
                return
            end
            
            % If only one dataset (folder) selected
            if (folder(end-2:end) == ".ds")
                rawFilesPath = folder;
            
            % If the folder selected contains multiple dataset
            else
                % Keep only data files (.ds)
                FilesName = dir([folder filesep '*.' 'ds']);
            
                % Saving FileNames in a cell (Path)
                rawFilesPath = cell(1, length(FilesName));
                
                for i=1:length(rawFilesPath)
                    rawFilesPath{i} = fullfile(FilesName(i).folder, FilesName(i).name);
                end
            end
            
            % Review Raw Files
            fileFormat = 'CTF';
            app.BasicFct.reviewRawFiles(subjectName, rawFilesPath, fileFormat, ChannelAlign);
            
            waitfor(msgbox('Note: We do not need to extract date from original files. It is done automatically'));
            
        end

    end
    
end