function ica = Ica(numberOfComponents)
    arguments
        numberOfComponents = 32;
    end

    ica = Process.create('ICA');
    ica.setParameter('Number_of_Components', numberOfComponents);