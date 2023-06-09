load('dcir_fit.mat')

% Variables and data definition
R1 = 12.5032;
R2 = 24.4340;
C = 0.00806;
I = 0.0038;
a = 1.5117;
deltaV_exp = data(22).deltaV;
time_exp = data(22).t;

% Calculate the voltage values using the model function
voltage_model = model_func(time_exp, R1, R2, C, I, a); % pass I as argument

% Plot data and model results on a graph
plot(time_exp, deltaV_exp, 'b-', time_exp, voltage_model, 'r--');
legend('Experimental data', 'Model result');
xlabel('Time');
ylabel('Voltage');
title('Experimental data and Model result');


% Model function definition
function voltage = model_func(time, R1, R2, C, I, a) % include I as parameter
    voltage = I * R1 * (R1 + R2) ./ (R1 + R2 .* exp(-a .* time ./ (R1 * C)));
end
