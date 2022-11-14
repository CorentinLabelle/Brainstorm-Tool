function ed = ExportToEDF()
    ed = Process.create('Export Data');
    ed = ed.setParameter(1, pwd);
    ed = ed.setParameter(2, 5);
    doc = 'Export dataset to .edf.';
    ed = ed.setDocumentation(doc);