function addEegPosition = AddEegPosition(fileType, electrodeFile, cap)
    arguments
        fileType = 'Use Default Pattern';
        electrodeFile = '';
        cap = 'Colin27: BrainProducts EasyCap 128';
    end
    
    addEegPosition = Process.create('add eeg position');
    addEegPosition.setParameter('file type', fileType);
    addEegPosition.setParameter('electrode file', electrodeFile);
    addEegPosition.setParameter('cap', cap);