% BIDS SPECS for participants.tsv and participants.json
% https://bids-specification.readthedocs.io/en/stable/03-modality-agnostic-files.html#participants-file
function create_participants_tsv_file(sFiles, tsv_path, participant_tsv_function_handle)
    arguments
        sFiles
        tsv_path
        participant_tsv_function_handle = [];
    end
    
    if isempty(participant_tsv_function_handle)
        participant_tsv_function_handle = @participants_tsv_var_template;
    end
    
    % Create variables
    participant_tsv_var = participant_tsv_function_handle(sFiles);
    participant_json_var = create_participants_json_var(participant_tsv_var);
    
    % Create json path
    [folder, file] = fileparts(tsv_path);
    json_path = fullfile(folder, [file '.json']);
    
    % Save variables
    save_file(tsv_path, participant_tsv_var);
    save_file(json_path, participant_json_var);
end

 function participant_json_var = create_participants_json_var(participant_tsv_var)
    participant_json_var = participants_field_description();
    
    tsv_fields = participant_tsv_var(1, :);
    json_fields = fieldnames(participant_json_var);
    
    % Warns if field is in TSV not in JSON
    for iField = 1:length(tsv_fields)
        field = tsv_fields(iField);
        if ~any(strcmpi(field, json_fields))
           warning(...
               ['The field "' char(field) '" has no description in the participants.json.' ...
               'Add the field description in the following file: ' ...
               mfilename('fullpath')]);
        end
    end
    
    % Remove field from JSON if not in TSV
    for iField = 1:length(json_fields)
        field = json_fields(iField);
        if ~any(strcmpi(field, tsv_fields))
            participant_json_var = rmfield(participant_json_var, field);
        end
    end
    
    % Check if field 'age' is in TSV
    age_field_index = find(strcmpi(tsv_fields, 'age'));
    if ~isempty(age_field_index)
        age_values = participant_tsv_var(2:end, age_field_index);
        if check_if_all_ages_are_equal(age_values)
            participant_json_var.age.Description = "mean age of all participants";
        end
    end
end

function field_descriptions = participants_field_description()
    field_descriptions = struct();
    
    % Participant ID
    field_descriptions.participant_id.Description = "ID of the participant";
    
    % Age
    field_descriptions.age.Description = "age of the participant";
    field_descriptions.age.Units = "years";
    
    % Sex
    field_descriptions.sex.Description = "sex of the participant as reported by the participant";
    field_descriptions.sex.Levels.M = "male";
    field_descriptions.sex.Levels.F = "female";
    
    % Gender
    field_descriptions.gender.Description = "gender of the participant as reported by the participant";
    
    % Handedness
    field_descriptions.handedness.Description = "handedness of the participant as reported by the participant";
    field_descriptions.handedness.Levels.left = "left";
    field_descriptions.handedness.Levels.right = "right";
    
    % Species
    field_descriptions.species.Description = "specie of the participant";
    species = get_species();
    for iSpecie = 1:length(species)
        specie = species{iSpecie};
        field = strrep(specie, ' ', '_');
        value = lower(specie);
        field_descriptions.species.Levels.(field) = value;
    end
    
    % Strain
    field_descriptions.strain.Description = "strain of the specie, if the specie is different from 'homo sapien'";
    
    % Strain RRID
    field_descriptions.strain_rrid.Description = "research ressource identifier (RRID) of the strain of the specie, if the specie is different from 'homo sapien'";
    
    % Years in Africa
    field_descriptions.years_in_africa.Description = "years spent in Africa as reported by the participant";
    field_descriptions.years_in_africa.Units = "years";
    
    % Years in Quebec
    field_descriptions.years_in_quebec.Description = "years spent in Quebec as reported by the participant";
    field_descriptions.years_in_quebec.Units = "years";
    
    % Country of origin
    field_descriptions.country.Description = "country of origin as reported by the participant";
    
    % Country of residence
    field_descriptions.country_of_residence.Description = "country of residence as reported by the participant";
    
    % Area
    field_descriptions.area.Description = "area of residence as reported by the participant";
    field_descriptions.area.Levels.rural = "rural";
    field_descriptions.area.Levels.urban = "urban";
    
    % Language
    field_descriptions.language.Description = "spoken language as reported by the participant";

    % Ethnic Identity or Culture
    field_descriptions.ethnic_identity_or_culture.Description = "ethnic identity or culture as reported by the participant";

    % Years of study
    field_descriptions.years_of_study.Description = "Years spent studying as reported by the participant";
    field_descriptions.years_of_study.Units = "years";
    
    % Years of education
    field_descriptions.years_of_education.Description = "Years of education as reported by the participant";
    field_descriptions.years_of_education.Units = "years";
    
    % Years of musical education
    field_descriptions.years_of_musical_education.Description = "Years of musical education as reported by the participant";
    field_descriptions.years_of_musical_education.Units = "years";
    
    % BehaviorBaselineSimple
    field_descriptions.behavior_baseline_simple.Description = "Performance on the simple task. A score of 0 indicates the subject was as good as the chance level.";
    
    % BehaviorBaselineManipulation
    field_descriptions.behavior_baseline_manipulation.Description = "Performance on the manipulation task. A score of 0 indicates the subject was as good as the chance level.";
    
end

function species = get_species()
% https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi

species = ...
    {...	
    'rattus norvegicus', ...	
    'homo sapiens', ...	
    'mus musculus'...
    };
end


function bool = check_if_all_ages_are_equal(ages)
    bool = true;
    first_age = ages{1};
    for iValue = 1:length(ages)
        if ~isequal(first_age, ages{iValue})
            bool = false;
            return
        end
    end
end

