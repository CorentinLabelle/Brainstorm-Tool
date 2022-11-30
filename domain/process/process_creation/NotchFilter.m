function notch = NotchFilter(frequence)
    arguments
        frequence = [60 120 180];
    end
    
    notch = Process.create('Notch Filter');
    notch.setParameter('Frequence', frequence);