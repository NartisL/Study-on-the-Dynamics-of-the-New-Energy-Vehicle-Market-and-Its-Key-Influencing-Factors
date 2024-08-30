function [F, c_v, p] = Granger_test(var1, var2, alpha, max_lag)
% Function to perform a Granger causality test.
% Input parameters:
%   var1 - Time series data for the dependent variable.
%   var2 - Time series data for the independent variable.
%   alpha - Significance level for the test.
%   max_lag - Maximum number of lags to consider.
% Output:
%   F - F-statistic value.
%   c_v - Critical value for the F-statistic.
%   p - P-value for the test.
% Result interpretation: If p < alpha, reject the null hypothesis that var2 does not Granger-cause var1.

% Initialize variables
T = length(var1); % Length of the time series
BIC = []; % Bayesian Information Criterion
RSSR = []; % Residual Sum of Squares for the restricted model

i = 1;

% Loop through different lag lengths
while i <= max_lag
    % Extract the lagged part of y
    ystar = var1(i+1:T, :);

    % Build the design matrix xstar, including a constant term and lagged terms of x
    xstar = [ones(T-i, 1) zeros(T-i, i)];

    % Add lagged terms of x to the design matrix
    j = 1;
    while j <= i
        xstar(:, j+1) = var1(i+1-j:T-j);
        j = j + 1;
    end

    % Fit a linear regression model of ystar on xstar
    [b, bint, r] = regress(ystar, xstar);

    % Calculate BIC and RSSR
    BIC(i, :) = T * log(r' * r) + (i+1) * log(T);
    RSSR(i, :) = r' * r;

    % Update i
    i = i + 1;
end

% Find the lag length with the minimum BIC for the restricted model
x_lag = find(BIC == min(BIC));

% Reinitialize variables for the unrestricted model
BIC = [];
RSSUR = [];

% Loop through different lag lengths
i = 1;
while i <= x_lag
    % Extract the lagged part of y
    ystar = var1(x_lag+1:T, :);

    % Build the design matrix xstar, including a constant term and lagged terms of x and y
    xstar = [ones(T-x_lag, 1) zeros(T-x_lag, x_lag)];

    % Add lagged terms of x to the design matrix
    j = 1;
    while j <= x_lag
        xstar(:, j+1) = var1(x_lag-j+1:T-j, :);
        j = j + 1;
    end

    % Add lagged terms of y to the design matrix
    j = 1;
    while j <= i
        xstar(:, x_lag+j+1) = var2(x_lag-j+1:T-j, :);
        j = j + 1;
    end

    % Fit a linear regression model of ystar on xstar
    [b, bint, r] = regress(ystar, xstar);

    % Calculate BIC and RSSUR
    BIC(i, :) = T * log(r' * r) + (i+x_lag+1) * log(T);
    RSSUR(i, :) = r' * r;

    % Update i
    i = i + 1;
end

% Find the lag length with the minimum BIC for the unrestricted model
y_lag = find(BIC == min(BIC));

% Calculate the F-statistic
F_num = (RSSR(x_lag, :) - RSSUR(y_lag, :)) / y_lag;
F_den = RSSUR(y_lag, :) / (T - (x_lag + y_lag + 1));
F = F_num / F_den;

% Calculate the critical value
c_v = finv(1 - alpha, y_lag, (T - (x_lag + y_lag + 1)));

% Calculate the p-value
p = 1 - fcdf(F, y_lag, (T - (x_lag + y_lag + 1)));