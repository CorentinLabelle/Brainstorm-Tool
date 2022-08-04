function createSubject = CreateSubject(subjectName, anatomyPath)

    arguments
        subjectName = 'Harry';
        anatomyPath = '';
    end
    
    createSubject = Process.create('create subject');
    createSubject.setParameter('Subject Name', subjectName);
    createSubject.setParameter('anatomy path', anatomyPath);