clc; % Clear the Command Window
clear; % Remove all variables from the workspace
close all; % Close all open figure windows

%% Import data
cost_table=readtable('Cost_data.xlsx'); % Read data from an Excel file named 'Cost_data.xlsx' into a table variable called cost_table
cost_name=["Gasoline Price";"Gasoline Vehicle Energy Efficiency";"Gasoline Vehicle Average Price";...
    "Gasoline Vehicle Fuel Cost";"Electric Vehicle Charging Cost";"New Energy Vehicle Energy Efficiency";...
    "Electric Vehicle Average Price";"Electric Vehicle Electricity Cost"]; % Define a string array to store the names of each column in the cost table
indicator_table=readtable("Analyse.xlsx"); % Read data from an Excel file named 'Analyse.xlsx' into a table variable called indicator_table
indicator_name = ["Holding Ratio";"Market Size";'Number Of Charging Piles';'Average Price Of Fuel Truck';...
    'Fuel Car Fuel Consumption Price';'Average Price Of Electric Vehicles';'Electric Consumption Of Electric Vehicle';...
    'Government Subsidies';'Carbon Emissions Of China';'Market Share Of New Energy Vehicles';...
    'New Energy Vehicle Market Penetration Rate';'New Energy Vehicle Production And Sales Ratio']; % Define a string array to store the names of each column in the indicator table

%% Data visualization, needs beautification
figure % Create a new figure window
hold on % Enable adding plots to the current axes without deleting existing plots
set(gcf,'Position',[100 100 800 300]) % Set the position and size of the figure window
plot(cost_table{:,1},cost_table{:,2},'.-','MarkerSize',10) % Plot the first column versus the second column with dots connected by lines
plot(cost_table{:,1},cost_table{:,3},'.-','MarkerSize',10) % Plot the first column versus the third column with dots connected by lines
plot(cost_table{:,1},cost_table{:,4},'.-','MarkerSize',10) % Plot the first column versus the fourth column with dots connected by lines
plot(cost_table{:,1},cost_table{:,5},'.-','MarkerSize',10) % Plot the first column versus the fifth column with dots connected by lines
text(cost_table{:,1},cost_table{:,2}+1,num2str(round(cost_table{:,2},2)),"FontWeight","bold") % Add text labels above the plot points for the second column
text(cost_table{:,1},cost_table{:,3}+1,num2str(round(cost_table{:,3},2)),"FontWeight","bold") % Add text labels above the plot points for the third column
text(cost_table{:,1},cost_table{:,4}+1,num2str(round(cost_table{:,4},2)),"FontWeight","bold") % Add text labels above the plot points for the fourth column
text(cost_table{:,1},cost_table{:,5}+1,num2str(round(cost_table{:,5},2)),"FontWeight","bold") % Add text labels above the plot points for the fifth column
box on % Draw a box around the axes
grid on % Display the grid lines
set(gca,'FontWeight','bold','FontSize',12) % Set font properties of the current axes
legend(cost_name(1:4),'Location','northeast','FontSize',8) % Add a legend for the first four plotted series
xlabel('Year') % Set the x-axis label
ylabel('Gasoline Vehicle Indicators') % Set the y-axis label
axis([2012.5 2022.5 0 22]) % Set the limits for the axes

figure % Create a new figure window
hold on % Enable adding plots to the current axes without deleting existing plots
set(gcf,'Position',[100 100 800 300]) % Set the position and size of the figure window
plot(cost_table{:,1},cost_table{:,6},'.-','MarkerSize',10) % Plot the first column versus the sixth column with dots connected by lines
plot(cost_table{:,1},cost_table{:,7},'.-','MarkerSize',10) % Plot the first column versus the seventh column with dots connected by lines
plot(cost_table{:,1},cost_table{:,8},'.-','MarkerSize',10) % Plot the first column versus the eighth column with dots connected by lines
plot(cost_table{:,1},cost_table{:,9},'.-','MarkerSize',10) % Plot the first column versus the ninth column with dots connected by lines
text(cost_table{:,1},cost_table{:,6}+1,num2str(round(cost_table{:,2},2)),"FontWeight","bold") % Add text labels above the plot points for the sixth column (using wrong index)
text(cost_table{:,1},cost_table{:,7}+1,num2str(round(cost_table{:,3},2)),"FontWeight","bold") % Add text labels above the plot points for the seventh column (using wrong index)
text(cost_table{:,1},cost_table{:,8}+1.5,num2str(round(cost_table{:,4},2)),"FontWeight","bold") % Add text labels above the plot points for the eighth column (using wrong index)
text(cost_table{:,1},cost_table{:,9}-1.5,num2str(round(cost_table{:,5},2)),"FontWeight","bold") % Add text labels below the plot points for the ninth column (using wrong index)
legend(cost_name(5:8)) % Add a legend for the fifth to eighth plotted series
box on % Draw a box around the axes
grid on % Display the grid lines
set(gca,'FontWeight','bold','FontSize',12) % Set font properties of the current axes
legend(cost_name(5:8),'Location','northeast','FontSize',6) % Adjust the legend for the fifth to eighth plotted series
xlabel('Year') % Set the x-axis label
ylabel('Electric Vehicle Indicators') % Set the y-axis label
axis ([2012.5 2022.5 -3 40]) % Set the limits for the axes

%% Data preprocessing, needs beautification
figure % Create a new figure window
set(gcf,'Position',[100 100 1200 500]) % Set the position and size of the figure window
for i=1:10 % Loop through each of the first ten columns in the indicator table
    subplot(2,5,i) % Create a subplot grid of 2 rows and 5 columns, and select the ith subplot
    boxplot(indicator_table{:,i},'Whisker',3) % Create a box plot for the ith column data with whiskers extending to 3 IQR
    h=findobj(gca,'Tag','Box'); % Find the handle to the box object in the plot
    patch(get(h,'XData'),get(h,'YData'),rand(1,3),'FaceAlpha',0.5) % Draw a semi-transparent patch over the box plot
    title(indicator_name{i,:}) % Set the title of the subplot using the corresponding name from the indicator_name array
    set(gca,'FontWeight','bold','FontSize',6) % Set font properties of the current subplot axes
end