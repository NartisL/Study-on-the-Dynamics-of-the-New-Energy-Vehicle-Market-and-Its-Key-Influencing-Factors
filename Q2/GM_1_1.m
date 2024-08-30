function [Yp, error, u] = GM_1_1(y, c, t)
% Function to implement the Grey Model GM(1,1) for data prediction.
% Inputs:
%   y - Original data or reference data column vector.
%   c - Translation coefficient C.
%   t - Prediction step.
% Outputs:
%   Yp - Prediction results.
%   error - Relative error.
%   u - Coefficients a and b from the GM(1,1) model.

% Apply translation transformation to the input data.
y = y + c;

n = length(y); % Length of the data series.

% Conduct the ratio test.
lambda = y(1:n-1) ./ y(2:n); % Ratio values.
Theta = [exp((-2 / (n + 1))), exp((2 / (n + 1)))]; % Thresholds for the ratio test.

% If the minimum value of lambda is greater than the lower bound of the interval
% and the maximum value is less than the upper bound, the ratio test is satisfied.
if (min(lambda) > Theta(1)) && (max(lambda) < Theta(2))
    % Display a message indicating that the ratio test is satisfied.
    disp(['Ratio test satisfied, current translation coefficient C: ', num2str(c)]);

    % Construct the data sequence.
    y_AGO = cumsum(y); % First-order accumulation to generate the sequence.
    z = (y_AGO(1:n-1) + y_AGO(2:n)) / 2; % Generate mean sequence.

    % Construct the matrix YB.
    Y = y(2:n)'; % Transpose the data vector.
    B = [-z' ones(n-1, 1)]; % Construct matrix B.

    % Solve for coefficients a and b using matrix operations.
    % Note: The line below uses symbolic computation which might not be efficient.
    % A numerical solution is preferred for practical use.
    x = dsolve('Dx+a*x=b', 'x(0)=c');

    % Solve for a and b using least squares method.
    u = lsqr(B, Y);

    % Assign values to the symbolic variables.
    x = subs(x, {'a', 'b', 'c'}, {u(1), u(2), y_AGO(1)});

    % Perform prediction based on first-order accumulated sequence.
    Y_AGO = eval(subs(x, 't', 0:n-1+t));

    % Reverse accumulation.
    Yp = [Y_AGO(1) diff(Y_AGO)];

    % Calculate relative error.
    error = abs((Yp(1:n) - c) - (y - c)) ./ (y - c);

    % Undo the translation transformation.
    Yp = Yp - c;
else
    % Display a message indicating that the ratio test is not satisfied.
    disp('Ratio test not satisfied, please re-determine the translation coefficient C');
    Yp = nan;
    error = nan;
    u = nan;
end
end