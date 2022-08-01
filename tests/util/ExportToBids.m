function exportToBids = ExportToBids(folder, dataFileFormat)
    arguments
        folder = '/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/testBids';
        dataFileFormat = 'brainvision';
    end
    
    exportToBids = Process.create('Export To Bids');
    exportToBids.setParameter('folder', folder);
    exportToBids.setParameter('data file format', dataFileFormat);