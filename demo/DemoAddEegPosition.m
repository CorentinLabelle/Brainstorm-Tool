aep = Process.create('add eeg position');
aep = aep.setParameter(3, 1);

disp(aep);

electrodeFile = '/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/projects/Brainstorm_Tool/demo/DemoAddEegPosition.m';
aep = aep.setParameter(1, electrodeFile);

disp(aep);