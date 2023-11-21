function create_coordinate_system_json_file(sFile, path, coordinate_system, isEeg, data_path)
    if isEeg
        coordinate_system_var = create_coordinate_system_json_var_EEG(sFile, coordinate_system, data_path);
    else
        error('Dataset is not EEG ?');
    end
    save_file(path, coordinate_system_var); 
end

function CoordSys = create_coordinate_system_json_var_EEG(sFile, coordinate_system, data_path)
    CoordSys = struct();
    CoordSys.IntendedFor = get_anatomy_file_from_data_path(data_path);
    CoordSys.EEGCoordinateSystem = convert_coordinate_system_name(coordinate_system);
    CoordSys.EEGCoordinateUnits = 'm';
    CoordSys.EEGCoordinateSystemDescription = 'n/a';
    CoordSys.FiducialsDescription = 'n/a';
    CoordSys.FiducialsCoordinates = get_fiducial_coordinates(sFile);
end

function fiducial_coordinates = get_fiducial_coordinates(sFile)
    channel_file = load(sFile_get_channel_file_path(sFile));
    scs = channel_file.SCS;
    fiducial_coordinates = struct();
    nas = scs.NAS';
    lpa = scs.LPA';
    rpa = scs.RPA';
    if ~isempty(nas)
        fiducial_coordinates.NAS = nas;
    end
    if ~isempty(lpa)
        fiducial_coordinates.LPA = lpa;
    end
    if ~isempty(rpa)
        fiducial_coordinates.RPA = rpa;
    end
end

function coordinate_system = convert_coordinate_system_name(coordinate_system)
    switch lower(coordinate_system)
        case 'captrak'
            coordinate_system = 'CapTrak';
        case 'scs'
            warning("Using Brainstorm 'scs' coordinate system which is not allowed in the BIDS specification");
            coordinate_system = '';
        otherwise
            error('Invalid coordinate system');
    end
end

function anatomy_file = get_anatomy_file_from_data_path(data_path)
    session_folder = fileparts(data_path);
    anat_folder = fullfile(session_folder, 'anat');
    
    if ~isfolder(anat_folder)
        anatomy_file = 'n/a';
        return
    end
    
    anat_folder_content = dir(anat_folder);
    nifti = anat_folder_content(endsWith({anat_folder_content.name}, '.nii.gz'));
    
    if isscalar(nifti)
        anatomy_file = nifti.name;
    else
        warning("Multiple nifti files in anatomy, selecting one randomly for the field 'IntendedFor' in the coordsystem.json file.");
        anatomy_file = nifti(1).name;
    end
    anatomy_file = fullfile(anat_folder, anatomy_file);
end