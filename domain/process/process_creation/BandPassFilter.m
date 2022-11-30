function bandPass = BandPassFilter(frequence)
    arguments
        frequence = [50 80]
    end
    
    bandPass = Process.create('Band Pass Filter');
    bandPass.setParameter('Frequence', frequence);