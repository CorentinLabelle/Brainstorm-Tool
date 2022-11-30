function average = Average(avgType, avgFunction)
    arguments
        avgType = 'By Folder (subject average)';
        avgFunction = 'Arithmetic Average';
    end
    
    average = Process.create('Average');
    average.setParameter('average type', avgType);
    average.setParameter('average function', avgFunction);