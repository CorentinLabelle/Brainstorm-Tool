function [classes, labels] = ic_labeling(sFile, F, iChannels, icaweights, icasphere)
    % Original function: https://github.com/sccn/ICLabel/blob/master/iclabel.m

    EEG = sFile_to_eeglab(sFile, F, iChannels, icaweights, icasphere);
    flag_autocorr = true;
    
    disp 'ICLabel: extracting features...'
    features = ICL_feature_extractor(EEG, flag_autocorr);

    version = 'default';
    disp 'ICLabel: calculating labels...'
    labels = run_ICL(version, features{:});
    
    classes = {'Brain', 'Muscle', 'Eye', 'Heart', 'Line Noise', 'Channel Noise', 'Other'};
end