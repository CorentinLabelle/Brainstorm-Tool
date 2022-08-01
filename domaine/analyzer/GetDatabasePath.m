function databasePath = GetDatabasePath()

    if ~isdeployed()
        databasePath = bst_get('BrainstormDbDir');
    else
        databasePath = 'C:';
    end

end