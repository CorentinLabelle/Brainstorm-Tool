classdef GetDatabasePathTester < matlab.uitest.TestCase & matlab.mock.TestCase

    methods (Test)
        
        function getDatabasePathTester(tc)
            
            databasePath = GetDatabasePath();
            tc.verifyTrue(isfolder(databasePath));
            
        end

    end
    
end