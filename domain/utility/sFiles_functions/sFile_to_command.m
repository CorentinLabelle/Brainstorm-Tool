function command = sFile_to_command(sFile)
    if isempty(sFile)
        command = '[]';
    end

    type = class(sFile);            
    switch type                
        case 'char'
            command = sFile;                    
        case 'struct'
            command = to_command_from_struct(sFile);
    end
end

function command = to_command_from_struct(sFile)
    str = strings(1, length(sFile));
    for i = 1:length(sFile)
        str{i} = ['''' sFile(i).FileName ''''];
    end
    command = ['{' char(strjoin(str, ', ')) '}'];
end