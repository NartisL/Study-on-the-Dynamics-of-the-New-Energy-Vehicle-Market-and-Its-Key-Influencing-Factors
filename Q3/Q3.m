clc; % Clear the command window.
clear; % Clear all variables.
close all; % Close all figure windows.

%% Import Data
%{
The dataset includes sales of new energy vehicles (NEVs), traditional energy vehicle sales,
global oil price changes, and traditional energy technology research and development (R&D) spending.
%}
data = [
    2019, 2020, 2021, 2022; % Years
    120.6, 132.2, 350.7, 385.1; % NEV Sales
    2454.8, 2394.5, 2274.1, 1299.9; % Traditional Energy Vehicle Sales
    56.99, 39.68, 57.27, 77; % Oil Price Changes
    131.3, 138.9, 147, 155.7 % R&D Spending
]';
data = [ones(4, 1) data]; % Add a column of ones for bias term in regression.

% Names of the indicators.
indicator_name = {"Year"; "NEV Sales"; "Traditional Sales"; "Oil Price"; "R&D Spending"};

%% Visualization
colors = lines(3); % Get default colors for plotting.
group = data(:, 1); % Extract the year column.
colors = lines(length(unique(group))); % Get unique colors for each group.

figure % Create a new figure.
set(gcf, 'Position', [50 50 1000 600]); % Set the position and size of the figure window.
pairplot(data(:, 2:end), indicator_name, num2cell(num2str(group)), colors, 'bar'); % Plot pairwise relationships.

%% Granger Causality Test
alpha = 0.01; % Significance level.
max_lag = 1; % Maximum lag order.

% Test if R&D Spending Granger causes Traditional Sales.
[F1, c_v1, p1] = Granger_test(data(:, 5), data(:, 3), alpha, max_lag);

% Test if Oil Price Granger causes Traditional Sales.
[F2, c_v2, p2] = Granger_test(data(:, 4), data(:, 3), alpha, max_lag);

% Test if NEV Sales Granger causes Traditional Sales.
[F3, c_v3, p3] = Granger_test(data(:, 2), data(:, 3), alpha, max_lag);

%% Visualization of Granger Causality Results
figure % Create a new figure.
set(gcf, 'Position', [50 50 1000 600]); % Set the position and size of the figure window.
hold on % Enable hold on to plot multiple lines on the same figure.

Color = {'#F5B92C'; '#75FC2B'; '#33DAE6'; '#732BFC'}; % Define custom colors for markers.
plot(1, p1, '^', 'MarkerSize', 8, 'LineWidth', 1.5, 'MarkerFaceColor', Color{1}, 'Color', 'r'); % Plot p-value for R&D Spending.
plot(1, p2, 's', 'MarkerSize', 8, 'LineWidth', 1.5, 'MarkerFaceColor', Color{2}, 'Color', 'r'); % Plot p-value for Oil Price.
plot(1, p3, 'diamond', 'MarkerSize', 8, 'LineWidth', 1.5, 'MarkerFaceColor', Color{3}, 'Color', 'r'); % Plot p-value for NEV Sales.
yline(0.01, 'r--', 'LineWidth', 1.5); % Draw a horizontal line at significance level.
box on % Turn on the box around the plot.
grid on % Turn on grid lines.
xlabel('Lag'); % Label the x-axis.
ylabel('P Value'); % Label the y-axis.
axis tight % Fit the axis to the data.
legend('NEV Sales --> Traditional Sales', 'Oil Price --> Traditional Sales', ...
       'R&D Spending --> Traditional Sales', 'Reference Line', 'Location', 'northeast'); % Add legend.
set(gca, 'FontWeight', 'bold', 'FontSize', 14, 'FontName', 'times'); % Set font properties.
axis([0 2 0 0.03]); % Set axis limits.

%% Multivariate Regression and Correlation Analysis
% Interpolate new x values for smoother regression lines.
new_x = linspace(data(1, 2), data(4, 2), 36); % Create interpolated x values.
new_y = [];

% Interpolate the other columns using cubic spline interpolation.
new_y = [new_y spline(data(:, 2), data(:, 3), new_x)'];
new_y = [new_y spline(data(:, 2), data(:, 4), new_x)'];
new_y = [new_y spline(data(:, 2), data(:, 5), new_x)'];
new_y = [new_y spline(data(:, 2), data(:, 6), new_x)'];

% Perform multivariate regression.
[beta1, ~, ~, ~, stat1] = regress(new_y(:, 2), [ones(size(new_y, 1), 1), new_y(:, 1)]); % Regression for Traditional Sales.
[beta2, ~, ~, ~, stat2] = regress(new_y(:, 3), [ones(size(new_y, 1), 1), new_y(:, 1)]); % Regression for Oil Price.
[beta3, ~, ~, ~, stat3] = regress(new_y(:, 4), [ones(size(new_y, 1), 1), new_y(:, 1)]); % Regression for R&D Spending.

% Calculate correlation coefficients.
[coef, pvalue] = corrcoef(new_y);