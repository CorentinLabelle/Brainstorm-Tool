function rejectBadTrials = RejectBadTrials(megGrad, megMag, eeg, seeg, eog, ecg)
    arguments
        megGrad = 10;
        megMag = 10;
        eeg = 10;
        seeg = 10;
        eog = 10;
        ecg = 10;
    end

    rejectBadTrials = Process.create('reject bad trials');
    rejectBadTrials.setParameter('meggrad', megGrad);
    rejectBadTrials.setParameter('megmag', megMag);
    rejectBadTrials.setParameter('eeg', eeg);
    rejectBadTrials.setParameter('seeg_ecog', seeg);
    rejectBadTrials.setParameter('eog', eog);
    rejectBadTrials.setParameter('ecg', ecg);