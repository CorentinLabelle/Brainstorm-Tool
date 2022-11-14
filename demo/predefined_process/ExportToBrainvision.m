function ed = ExportToBrainvision()
    ed = Process.create('Export Data');
    ed = ed.setParameter(1, pwd);
    ed = ed.setParameter(2, 2);
    doc = 'Export dataset to .eeg (with .vhdr and .vmrk).';
    ed = ed.setDocumentation(doc);