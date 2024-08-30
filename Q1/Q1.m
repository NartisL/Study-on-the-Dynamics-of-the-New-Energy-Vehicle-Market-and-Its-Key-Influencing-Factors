% Clear command window, variables, and close all figures.
clc; clear; close all;

%% Data Importing
% Read data from Excel files
cost_table = readtable('Cost_data.xlsx');
cost_name = ["Gasoline Price"; "Gasoline Vehicle Energy Efficiency"; "Gasoline Vehicle Average Price"; ...
    "Gasoline Vehicle Fuel Cost"; "Electric Vehicle Charging Cost"; "New Energy Vehicle Energy Efficiency"; ...
    "Electric Vehicle Average Price"; "Electric Vehicle Electricity Cost";];
indicator_table = readtable("Analyse.xlsx");
indicator_name = ["Holding Ratio"; "Market Size"; 'Number Of Charging Piles'; 'Average Price Of Fuel Truck';...
    'Fuel Car Fuel Consumption Price'; 'Average Price Of Electric Vehicles'; 'Electric Consumption Of Electric Vehicle';...
    'Government Subsidies'; 'Carbon Emissions Of China'; 'Market Share Of New Energy Vehicles';...
    'New Energy Vehicle Market Penetration Rate'; 'New Energy Vehicle Production And Sales Ratio'];

%% Correlation Analysis
% Calculate correlation coefficients and p-values
[corrA p_value] = corrcoef(indicator_table{:,:});
corrA = corrA(2:end,1); % Extract correlations for the first column against others

% Plot heatmap for correlations
figure;
set(gcf,'Position',[100 100 1000 500]);
h = heatmap(indicator_name(1), indicator_name(2:end), corrA);
colormap jet;
set(gca,'FontSize',10);

% Correlation matrix for variables excluding the first column
corrB = corrcoef(indicator_table{:,2:end});
figure;
set(gcf,'Position',[100 100 1200 600]);
h = heatmap(indicator_name(2:end), indicator_name(2:end), round(corrB,3));
colormap jet;
set(gca,'FontSize',10);

%% Multivariate Regression - Ridge Regression
% Using ridge regression function
x = indicator_table{:,2:end};
y = indicator_table{:,1};

% Normalize the data (commented out in favor of min-max scaling)
% x = (x - mean(x)) ./ std(x);
x = mapminmax(x',0,1)'; % Min-max scaling
X = [ones(size(x,1),1) x]; % Augmented matrix

% Set a range of regularization parameters
lambda = 0:0.0001:0.001;
beta = ridge(y,x,lambda); % Beta matrix of coefficients, each column corresponds to a lambda value

% Plot ridge trace
figure;
plot(lambda,beta,'-^','LineWidth',1.5);
xlabel('lambda');
ylabel('Regression Coefficient Values');

% Select lambda
lambda_choose = 0.01;
beta = ridge(y,x,lambda_choose,0); % Beta matrix of coefficients for selected lambda

% Predicted values
ypred = X * beta;

% Display predicted vs actual values
figure;
hold on;
set(gcf,'Position',[100 100 800 500]);
plot(y,y,'--','LineWidth',1.5,'Color','#20BD4A');
plot(y,ypred,'*r','LineWidth',1.5,'MarkerSize',10);
box on;
grid on;
set(gca,'FontWeight','bold','FontSize',14);
legend('Real-Real','Real-Predicted','Location','southeast','FontSize',14);
xlabel('Real Value');
ylabel('Predicted Value');
axis tight;

% Bar chart for coefficient importance
figure;
hold on;
set(gcf,'Position',[100 100 800 500]);
num_bars = length(beta(2:end));
for i = 1:num_bars
    bar(i, abs(beta(i + 1)), 'FaceColor', rand(1,3));
end
set(gca,'XTick',1:11,'XTickLabel',indicator_name(2:end));
box on;
grid on;
ylabel('Importance');
set(gca,'FontWeight','bold','FontSize',10);

%% Evaluation Metrics
% Mean Squared Error (MSE)
mse = mean((y - ypred).^2);

% Mean Absolute Error (MAE)
mae = mean(abs(y - ypred));

% Coefficient of Determination (R^2)
sst = sum((y - mean(y)).^2);
ssr = sum((ypred - mean(y)).^2);
rSquared = ssr / sst;

% Mean Absolute Percentage Error (MAPE)
mape = mean(abs((y - ypred)./ y)) * 100;

%% Output Results
fprintf('MSE: %.4f\n', mse);
fprintf('MAE: %.4f\n', mae);
fprintf('R^2: %.4f\n', rSquared);
fprintf('MAPE: %.4f%%\n', mape);