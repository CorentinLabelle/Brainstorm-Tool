function ia = ImportAnatomyEEG()
    ia = Process.create('Import Anatomy');
	ia = ia.setParameter(3, 1);