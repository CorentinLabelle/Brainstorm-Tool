function brainstorm_tool_hello_world()

    nf = Process.create('Notch filter');
    nf = nf.setParameter('frequence', [60 120 180]); 
    
    p = Pipeline();
    p = p.setName('My Pipeline');
    p = p.addProcess(nf);
    assert(p.getNumberOfProcess() == 1);
    
    disp('Hello World');