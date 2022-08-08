function extension = GetDatasetExtension(type)
            
    if strcmpi(type, 'eeg')
        extension = [".eeg", ".edf"];

    elseif strcmpi(type, 'meg')
        extension = ".meg4";

    elseif strcmpi(type, 'general') || strcmpi(type, 'specific')
        st = dbstack;
        namestr = st.name;
        currentFunctionHandle = str2func(namestr);
        extension = [currentFunctionHandle('eeg'), currentFunctionHandle('meg')];
        
    else
        error('Unsupported type...');

    end
                    
end

