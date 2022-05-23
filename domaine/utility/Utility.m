classdef Utility < handle

    
    methods (Access = private)
        
        function obj = Utility()
        end
        
    end
    
    methods(Static)
        
        function obj = instance()
           
            persistent uniqueInstance;
            if isempty(uniqueInstance)
                obj = Utility();
                uniqueInstance = obj;
            else
                obj = uniqueInstance;
            end
        end
        
        function str = formatDateToString(date)
            % Convert YYYY-MM-DD-HH-MM-SS to YYYY-MM-DD-HHh-MMm-SSs
            
            if isempty(date)
                str = char.empty();
                return
            end

            date = string(split(date, '-'))';
            
            assert(length(date) == 6);
            
            str = strcat(num2str(date(1)), '-', Utility.monthConversionStrNum(date(2)), '-', ...
                num2str(date(3)), '__', num2str(date(4)), 'h', num2str(date(5)), 'm', ...
                num2str(date(6)), 's');
        end

        function date = get_Time_Now()
            date = clock;
            date(6) = round(date(6));
            date = sprintf('%.0f-' , date);
            date = date(1:end-1); % Remove last hyphen
        end
        
        function rep = monthConversionStrNum(input)
            % Initialization
            monthsName = {'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'};
            monthsNum = {'01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12'};
            monthStruct = cell2struct(monthsNum, monthsName, 2);     
            
            % Get month name or month number
            
            % If number
            if isnumeric(input)
                assert(input > 0 && input <= 12);
                rep = monthsName{input};

            % If char or string
            elseif ischar(input) || isstring(input)
                
                strUpper = upper(input);
                
                if isfield(monthStruct, strUpper)
                    
                    rep = monthStruct.(strUpper);
                    
                else
                    monthsNum = (str2double(input));
                    assert(monthsNum > 0 && monthsNum <= 12);
                    rep = monthsName{monthsNum};
                end

            else
                error(['The input is of the wrong class (' class(input) ').']);
                
            end
        end

        function bidsFolder = createBidsFolder(bidsFolder)

            nb_folder = 0;
            while isfolder(bidsFolder)
                nb_folder = nb_folder + 1;
                if nb_folder ~= 1
                    bidsFolder = bidsFolder(1:find(bidsFolder == '_', 1, 'last')-1);
                end
                bidsFolder = strcat(bidsFolder, '_', num2str(nb_folder));
            end
            mkdir(bidsFolder);

        end
        
        % The next function has been taken here:
        % https://www.mathworks.com/matlabcentral/fileexchange/77284-structure-and-object-to-json?s_tid=srchtitle

        % Unused ?
        function saveAsJSON(data, jsonFileName)
            % saves the values in the structure 'data' to a file in JSON format.
            % Based on the work of Lior Kirsch at: https://uk.mathworks.com/matlabcentr
            % al/fileexchange/50965-structure-to-json
            %
            % Modification by Arthur Y.C. Liu 24/06/2020
            %
            % Example:
            %     data.name = 'chair';
            %     data.color = 'pink';
            %     data.eye = eye(3);
            %     data.metrics.imageSize = [1920; 1080];
            %     data.metrics.height = 0.3;
            %     data.metrics.width = 1.3;
            %     saveJSONfile(data, 'out.json');
            %
            % Output 'out.json':
            % {
            % 	"name" : "chair",
            % 	"color" : "pink",
            % 	"eye" :
            % 	[
            % 		1,
            % 		0,
            % 		0,
            % 		0,
            % 		1,
            % 		0,
            % 		0,
            % 		0,
            % 		1
            % 	],
            % 	"metrics" :
            % 	{
            % 		"imageSize" :
            % 		[
            % 			1920,
            % 			1080
            % 		],
            % 		"height" : 0.3,
            % 		"width" : 1.3
            % 	}
            % }
            fid = fopen(jsonFileName,'w');
            if isobject(data)
                data = toStruct(data);
            end
            writeElement(fid, data, '', true);
            fprintf(fid,'\n');
            fclose(fid);


            function writeElement(fid, data, tabs, isFirstLine)
                namesOfFields = fieldnames(data);
                numFields = length(namesOfFields);
                tabs = sprintf('%s\t', tabs);
                if nargin == 4
                    if isFirstLine
                        fprintf(fid,'%s{\n%s', tabs(1:end-1), tabs);
                    end
                else
                    fprintf(fid,'\n%s{\n%s', tabs(1:end-1), tabs);
                end
                for i = 1:numFields
                    currentField = namesOfFields{i};
                    currentElementValue = data.(currentField);
                    writeSingleElement(fid, currentField, currentElementValue, tabs);
                    if i == numFields
                        fprintf(fid,'\n%s}',  tabs(1:end-1));
                    else
                        fprintf(fid,',\n%s', tabs);
                    end
                end
            end

            function writeSingleElement(fid, currentField, currentElementValue, tabs)
                % if this is an array/matrix and not a string then iterate on every
                % element, if this is a single element write it
                if ~isstruct(currentElementValue) &&...
                        length(currentElementValue) > 1 && ~ischar(currentElementValue)
                    fprintf(fid,'"%s" : \n%s[\n%s\t',currentField, tabs, tabs);
                    tabs = sprintf('%s\t', tabs);
                    valLength = length(currentElementValue(:));
                    for m = 1:valLength
                        fprintf(fid,'%g' , currentElementValue(m));
                        if m == valLength
                            fprintf(fid,'\n%s]', tabs(1:end-1));
                        else
                            fprintf(fid,',\n%s', tabs);
                        end
                    end
                elseif isstruct(currentElementValue) &&...
                        length(currentElementValue) > 1 && ~ischar(currentElementValue)
                    fprintf(fid,'"%s" : \n%s[',currentField, tabs);
                    tabs = sprintf('%s\t', tabs);
                    valLength = length(currentElementValue(:));
                    for m = 1:valLength
                        writeElement(fid, currentElementValue(m), tabs);
                        if m == valLength
                            fprintf(fid,'\n%s]', tabs(1:end-1));
                        else
                            fprintf(fid,',');
                        end
                    end
                elseif isstruct(currentElementValue)
                    fprintf(fid,'"%s" : ',currentField);
                    writeElement(fid, currentElementValue, tabs);
                elseif isnumeric(currentElementValue) || islogical(currentElementValue)
                    fprintf(fid,'"%s" : %g' , currentField, currentElementValue);
                elseif isempty(currentElementValue)
                    fprintf(fid,'"%s" : "null"' , currentField);
                elseif isobject(currentElementValue)
                    currentElementValue = toStruct(currentElementValue);
                    fprintf(fid,'"%s" : ',currentField);
                    writeElement(fid, currentElementValue, tabs);
                else %ischar or something else ...
                    fprintf(fid,'"%s" : "%s"' , currentField, currentElementValue);
                end
            end

        end
        
    end
    
end
    