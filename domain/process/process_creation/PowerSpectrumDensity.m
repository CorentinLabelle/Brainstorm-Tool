function ppsd = PowerSpectrumDensity(windowLength)
    arguments
        windowLength = 4;
    end
    
    ppsd = Process.create('Power Spectrum Density');
    ppsd.setParameter('Window Length', windowLength);