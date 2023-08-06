function [recording, time_vector] = sFile_get_recording(sFile)
    LoadOptions = [];
    rawTime = [];
    sMat = ...
        bst_process('LoadInputFile', sFile.FileName, [], rawTime, LoadOptions);
    recording = sMat.Data;
    time_vector = sMat.Time;
end