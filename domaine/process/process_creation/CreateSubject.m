function createSubject = CreateSubject(subjectName, anatomyPath)

    arguments
        subjectName = 'subject01';
        anatomyPath = '';
    end
    
    createSubject = Process.create('create subject');
    createSubject.setParameter('Subject Name', subjectName);
    createSubject.setParameter('anatomy path', anatomyPath);