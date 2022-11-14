function nf = RemovePowerLineFreq_NA()
    nf = Process.create('notch filter');
    nf = nf.setParameter(1, [60 120 180]);
    doc = 'Notch filter that removes the power line frequences in North America (60Hz, 120Hz, 180Hz).';
    nf = nf.setDocumentation(doc);