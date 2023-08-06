function EEG = create_ica_fields(F, iChannels, icaweights, icasphere, EEG)
    if nargin == 1
        EEG = struct();
    end
    
    EEG.icaweights = icaweights;
    EEG.icasphere = icasphere;
    
    % W: Unmixing matrix
    W = icaweights * icasphere;
    
    % EEG.icawinv = pinv(EEG.icaweights * EEG.icasphere) = pinv(W)
    EEG.icawinv = pinv(W);

    % EEG.icaact = EEG.icaweights*EEG.icasphere)*EEG.data
    EEG.icaact = [];
    if ~isempty(W)
        EEG.icaact = W * F;
    end
    
    EEG.icachansind = iChannels;
end