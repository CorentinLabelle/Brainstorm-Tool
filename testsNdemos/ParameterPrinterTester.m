clear
clc

p1 = ParameterFactory.create('First Parameter', 'double', double.empty());
disp(p1);

p2 = ParameterFactory.create('Second Parameter', 'char', char.empty(), {'bonjour', 'allo', 'toi'});
disp(p2);