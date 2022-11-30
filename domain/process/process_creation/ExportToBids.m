function exportToBids = ExportToBids(folder, dataFileFormat)
    arguments
        folder = 'folder/subFolder/bidsFolder';
        dataFileFormat = 'brainvision';
    end
    
    exportToBids = Process.create('Export To Bids');
    exportToBids.setParameter('folder', folder);
    exportToBids.setParameter('data file format', dataFileFormat);