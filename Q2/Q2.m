% Clear command window, variables, and close all figures.
clc; clear; close all;

%% Data Importing
% Import data from Excel file containing indicators related to new energy vehicles.
indicator_table = readtable("Analyse.xlsx");

% List of indicator names.
indicator_name = ["Holding Ratio"; "Market Size"; 'Number Of Charging Piles'; 'Average Price Of Fuel Truck';...
    'Fuel Car Fuel Consumption Price'; 'Average Price Of Electric Vehicles'; 'Electric Consumption Of Electric Vehicle';...
    'Government Subsidies'; 'Carbon Emissions Of China'; 'Market Share Of New Energy Vehicles';...
    'New Energy Vehicle Market Penetration Rate'; 'New Energy Vehicle Production And Sales Ratio'];

%% Data Visualization
% Create a figure to display the trends of four selected indicators over time.
figure;
set(gcf,'Position',[100 100 800 500]);
ind_choose = [1,2,3,11]; % Selected indicators
year = (2013:2022)'; % Years from 2013 to 2022
Color = {'#F5B92C'; '#75FC2B'; '#33DAE6'; '#732BFC'}; % Colors for plots

% Loop through the selected indicators to plot them.
for i = 1:4
    subplot(2,2,i); % Create a 2x2 subplot grid
    hold on;
    data_indicator = indicator_table{:, ind_choose(i)}; % Extract data for the current indicator
    plot(year, data_indicator, '.--', 'MarkerSize', 20, 'LineWidth', 1.5, 'Color', Color{i}); % Plot the data
    box on;
    grid on;
    xlabel('Year');
    ylabel('Value');
    axis tight;
    set(gca,'FontWeight','bold','FontSize',14,'FontName','times');
    title(indicator_name{ind_choose(i)}, 'FontSize', 12, 'FontWeight', 'bold', 'FontName', 'times');
    xlim([2012.5 2022.5]);
end

%% Data Fitting and Forecasting
% Create a figure to display the fitted and forecasted values for the selected indicators.
figure;
set(gcf,'Position',[50 50 1400 700]);
ind_choose = [1,2,3,11]; % Selected indicators
year = (2013:2022)'; % Years from 2013 to 2022
Color = {'#F5B92C'; '#75FC2B'; '#33DAE6'; '#732BFC'}; % Colors for plots
rSquared = []; % Vector to store R^2 values
mse = []; % Vector to store MSE values
Ypred = []; % Vector to store predicted values

% Loop through the selected indicators to fit the data and make forecasts.
for i = 1:4
    subplot(2,2,i); % Create a 2x2 subplot grid
    hold on;
    data_indicator = indicator_table{:, ind_choose(i)}; % Extract data for the current indicator
    plot(year, data_indicator, '.--', 'MarkerSize', 20, 'LineWidth', 1.5, 'Color', Color{i}); % Plot the data
    
    % Fit the data and make predictions
    [Yp, forecast] = combined_forecast(data_indicator', 10, 0); % Assuming combined_forecast is defined elsewhere
    plot(year, Yp, 'r-', 'MarkerSize', 20, 'LineWidth', 1.5); % Plot the fitted line
    plot(year(end)+1:year(end)+10, forecast, 'or', 'LineWidth', 1.5); % Plot the forecasted values
    
    box on;
    grid on;
    xlabel('Year');
    ylabel('Value');
    axis tight;
    legend('Real Value', 'Fitted Line', 'Predicted Value', 'Location', 'southeast');
    set(gca,'FontWeight','bold','FontSize',14,'FontName','times');
    title(indicator_name{ind_choose(i)}, 'FontSize', 12, 'FontWeight', 'bold', 'FontName', 'times');
    xlim([2012.5 2032.5]);
    
    Ypred = [Ypred round(forecast', 2)]; % Store the forecasted values
    
    % Evaluate the model
    % Calculate R^2
    [R, P] = corrcoef(Yp, data_indicator);
    r = R(1,2)^2;
    rSquared = [rSquared; r];
    
    % Calculate MSE
    mse = [mse; round(mean((data_indicator - Yp).^2), 5)];
end