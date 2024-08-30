function [Yp, forecast] = combined_forecast(ts_data, forecast_years, c)
% This function combines forecasts from a linear model and a grey model (GM(1,1)).
% Inputs:
%   ts_data - Time series data.
%   forecast_years - Number of years to forecast.
%   c - Initial translation coefficient for the grey model.
% Outputs:
%   Yp - Fitted values combining both models for the historical data.
%   forecast - Combined forecast values for the specified number of years.

forecast = []; % Initialize the forecast array.
for i = 1:1 % Begin a loop, though it only runs once due to the range (1:1).
    % Prepare data
    X = 1:length(ts_data); % Create a time index vector.
    y = ts_data; % Original time series data.
    
    % Linear model
    [fitresult, ~] = fit(X', y', 'poly2'); % Fit a second-degree polynomial to the data.
    linear_forecast = fitresult(X(end) + 1); % Forecast the next point using the linear model.
    
    % Grey model
    ystar = y + c; % Translate the original data by adding the coefficient c.
    n = length(ystar); % Determine the length of the translated series.
    
    % Conduct the ratio test.
    lambda = ystar(1:n-1) ./ ystar(2:n); % Compute the ratios.
    Theta = [exp((-2 / (n + 1))), exp((2 / (n + 1)))]; % Define thresholds for the ratio test.
    
    % Adjust the translation coefficient until the ratio test is satisfied.
    while ~(min(lambda) > Theta(1) && max(lambda) < Theta(2))
        c = c + 5; % Increase the translation coefficient.
        ystar = y + c; % Reapply the translation.
        n = length(ystar); % Recalculate the length of the series.
        lambda = ystar(1:n-1) ./ ystar(2:n); % Recompute the ratios.
        Theta = [exp((-2 / (n + 1))), exp((2 / (n + 1)))]; % Redefine the thresholds.
    end
    
    gm_forecast = GM_1_1(y, c, 1); % Use the GM(1,1) model to forecast the next point.
    gm_forecast = gm_forecast(end); % Extract the forecasted value.
    
    combined = linear_forecast * 1/2 + gm_forecast * 1/2; % Combine forecasts.
    forecast = [forecast, combined]; % Store the combined forecast.
    
    % Forecast for additional years
    for j = 1:forecast_years - 1
        X = [X X(end) + 1]; % Extend the time index.
        y = [y combined]; % Append the last forecasted value to the dataset.
        
        % Update the linear model
        [fitresult, ~] = fit(X', y', 'poly2'); % Refit the linear model.
        linear_forecast = fitresult(X(end) + 1); % Forecast the next point.
        
        % Update the grey model
        ystar = y + c; % Translate the updated dataset.
        n = length(ystar); % Recalculate the length of the series.
        
        % Conduct the ratio test again
        lambda = ystar(1:n-1) ./ ystar(2:n); % Compute the ratios.
        Theta = [exp((-2 / (n + 1))), exp((2 / (n + 1)))]; % Define thresholds.
        
        while ~(min(lambda) > Theta(1) && max(lambda) < Theta(2))
            c = c + 5; % Adjust the translation coefficient.
            ystar = y + c; % Reapply the translation.
            n = length(ystar); % Recalculate the length.
            lambda = ystar(1:n-1) ./ ystar(2:n); % Recompute the ratios.
            Theta = [exp((-2 / (n + 1))), exp((2 / (n + 1)))]; % Redefine the thresholds.
        end
        
        gm_forecast = GM_1_1(y, c, 1); % Forecast using the GM(1,1) model.
        gm_forecast = gm_forecast(end); % Extract the forecasted value.
        
        combined = linear_forecast * 1/2 + gm_forecast * 1/2; % Combine forecasts.
        forecast = [forecast, combined]; % Store the new combined forecast.
    end
    
    % Fit the historical data using both models
    Yp_linear = fitresult(1:length(ts_data)); % Apply the linear model to historical data.
    Yp_gm = GM_1_1(ts_data, c, 0)'; % Apply the GM(1,1) model to historical data.
    Yp = (Yp_linear + Yp_gm) / 2; % Combine the fitted values.
end
end