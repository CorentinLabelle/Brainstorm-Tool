function brainstorm_tool_hello_world()
    disp('Hello World');
    disp(newline);
    
    p = Pipeline();
    p = p.setName('My Pipeline');
    
    nf = Process.create('Notch filter');
    nf = nf.setParameter('frequence', [60 120 180]); 
    p = p.addProcess(nf);
    
    disp(p);