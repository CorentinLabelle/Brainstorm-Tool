function nf = RemovePowerLineFreq_Europe()
    nf = Process.create('notch filter');
    nf = nf.setParameter(1, [50 100 150]);
    doc = 'Notch filter that removes the power line frequences in Europe (50Hz, 100Hz, 150Hz).';
    nf = nf.setDocumentation(doc);