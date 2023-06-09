function fit_data()
    % Load the data
    load('gitt_fit.mat');
    deltaV_exp = data(22).deltaV;
    time_exp = data(22).t;
    
    % Initial estimates for optimization
    A = data(22).V(56) - data(22).V(133);
    B = 901;

    initial_guess = [A, B];
    
    % Perform optimization using fmincon
    options = optimoptions('fmincon', 'Display', 'iter', 'MaxIterations', 100);
    lower_bound = [-Inf, 900];
    upper_bound = [0, Inf];
    [opt_params, rms] = fmincon(@(params) cost_function(params, time_exp, deltaV_exp), ...
        initial_guess, [], [], [], [], lower_bound, upper_bound, [], options); 

    % Print optimized parameters
    disp("Optimized Parameters:");
    disp("A: " + opt_params(1));
    disp("B: " + opt_params(2));
    
    % Predict using the model with optimized parameters
    voltage_model = model_func(time_exp, opt_params(1), opt_params(2));
    
    % Plot the data and model result
    plot(time_exp, deltaV_exp, 'b-', time_exp, voltage_model, 'r--');
    legend('Experimental Data', 'Model Result');
    xlabel('Time');
    ylabel('Voltage');
    title('Experimental Data and Model Result');
end

function cost = cost_function(params, time, deltaV)
    A = params(1);
    B = params(2);
    
    % Calculate the predicted voltage using the model function
    voltage_model = model_func(time, A, B);
    
    % Calculate RMS error
    error = deltaV - voltage_model;
    cost = sqrt(mean(error.^2));

end

% Model function definition
function voltage = model_func(time, A, B)
    I = 0.00048;
    R1 = 24.5755;
    R2 = 77.0154;
    C = 8.4357;
    voltage = zeros(size(time)); % Initialize a vector to store voltage
    for i = 1:length(time)
        t = time(i); % Calculate the voltage for each time step
        voltage(i) = I * R1 * (R1 + R2 + A * (1-sqrt(t/B))) / (R1 + (R2 + A * (1-sqrt(t/B))) * exp((-R1/(R2+A * (1-sqrt(t/B))) + 1) * t / (R1 * C)));
    end
end
