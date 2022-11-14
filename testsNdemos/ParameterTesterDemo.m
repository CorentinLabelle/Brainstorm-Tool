clear
clc
p1 = Parameter('frequence', 'numeric', double.empty());
p1 = p1.setValue(5);

p2 = Parameter('file_format', 'char', 'brainvision', {'brainvision', 'edf'});
p2 = p2.setValue('brainvision');

a = {p1, p2};

lop = ListOfParameters();
lop = lop.add(a);
lop = lop.setValue('frequence', 7);
lop = lop.setValue(2, 'edf');
disp(lop);


a = AddEegPositionParameter();
b = a(3);
b = b.selectPossibleValue(1);
c = b.getConvertedValue();
