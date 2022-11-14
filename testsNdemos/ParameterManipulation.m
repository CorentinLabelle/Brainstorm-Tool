%% Parameter Manipulation
clear
clc

%% Description
% There is two types of parameter:
%    1. BstParameter: The user enters the value.
%    2. ConstrainedParameter: the value of the parameter is constrained to
%    certains values. The user selects the value.


%% Create a parameter

% BstParameter = ParameterFactory.create('parameterName', 'class', defaultValue);
param1 = ParameterFactory.create('frequence', 'numeric', double.empty());
param2 = ParameterFactory.create('extension', 'logical', true);
assert(isa(param1, 'BstParameter'));
assert(isa(param2, 'BstParameter'));

% ConstrainedParameter = ParameterFactory.create('parameterName', 'class', defaultValue, {possibleValues});
param3 = ParameterFactory.create('extension', 'char', char.empty(), {'.mat', '.json'});
assert(isa(param3, 'ConstrainedParameter'));

%% Assign value

% BstParameter
param1 = param1.setValue(45);
assert(param1.getValue() == 45);
param2 = param2.setValue(false);
assert(param2.getValue() == false);

% ConstrainedParameter
param3 = param3.setValue(2);
assert(strcmpi(param3.getValue(),'.json'));