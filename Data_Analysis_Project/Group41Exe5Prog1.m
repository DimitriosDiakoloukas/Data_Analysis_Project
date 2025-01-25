clc;
clear;

data = readtable("TMS.xlsx");

EDdurationNOTMS = data.EDduration(data.TMS == 0);
Setup_NOTMS = data.Setup(data.TMS == 0);
EDdurationTMS = data.EDduration(data.TMS == 1);
Setup_TMS = data.Setup(data.TMS == 1);

lrmodelNOTMS = fitlm(Setup_NOTMS, EDdurationNOTMS);
disp(lrmodelNOTMS);

lrmodelTMS = fitlm(Setup_TMS, EDdurationTMS);
disp(lrmodelTMS);

figure;
scatter(Setup_NOTMS, EDdurationNOTMS, 'b', 'DisplayName', 'Data');
hold on;
x_fit = linspace(min(Setup_NOTMS), max(Setup_NOTMS), 100);
y_fit = predict(lrmodelNOTMS, x_fit');
plot(x_fit, y_fit, 'r', 'LineWidth', 2, 'DisplayName', 'Regression Line');
xlabel('Setup');
ylabel('ED Duration');
title('Linear Regression: Setup vs ED Duration (No TMS)');
legend('Location', 'best');
grid on;
hold off;

figure;
scatter(Setup_TMS, EDdurationTMS, 'b', 'DisplayName', 'Data');
hold on;
x_fit = linspace(min(Setup_TMS), max(Setup_TMS), 100);
y_fit = predict(lrmodelTMS, x_fit');
plot(x_fit, y_fit, 'r', 'LineWidth', 2, 'DisplayName', 'Regression Line');
xlabel('Setup');
ylabel('ED Duration');
title('Linear Regression: Setup vs ED Duration (TMS)');
legend('Location', 'best');
grid on;
hold off;

degrees = [2, 3, 5];

for degree = degrees
    polymodelNOTMS = polyfit(Setup_NOTMS, EDdurationNOTMS, degree);
    disp(['Polynomial Coefficients for Degree ', num2str(degree), ':']);
    disp(polymodelNOTMS);
    
    figure;
    scatter(Setup_NOTMS, EDdurationNOTMS, 'b', 'DisplayName', 'Data');
    hold on;
    x_fit = linspace(min(Setup_NOTMS), max(Setup_NOTMS), 100);
    y_fit = polyval(polymodelNOTMS, x_fit);
    plot(x_fit, y_fit, 'r', 'LineWidth', 2, 'DisplayName', ['Polynomial Degree ', num2str(degree)]);
    xlabel('Setup');
    ylabel('ED Duration');
    title(['Polynomial Regression No TMS: Setup vs ED Duration (TMS, Degree ', num2str(degree), ')']);
    legend('Location', 'best');
    grid on;
    hold off;
end

for degree = degrees
    polymodelTMS = polyfit(Setup_TMS, EDdurationTMS, degree);
    disp(['Polynomial Coefficients for Degree ', num2str(degree), ':']);
    disp(polymodelTMS);
    
    figure;
    scatter(Setup_TMS, EDdurationTMS, 'b', 'DisplayName', 'Data');
    hold on;
    x_fit = linspace(min(Setup_TMS), max(Setup_TMS), 100);
    y_fit = polyval(polymodelTMS, x_fit);
    plot(x_fit, y_fit, 'r', 'LineWidth', 2, 'DisplayName', ['Polynomial Degree ', num2str(degree)]);
    xlabel('Setup');
    ylabel('ED Duration');
    title(['Polynomial Regression TMS: Setup vs ED Duration (TMS, Degree ', num2str(degree), ')']);
    legend('Location', 'best');
    grid on;
    hold off;
end


% OUR OBSERVTIONS AND RESULTS BELOW

% We observe that the linear regression model doesn't satisfy the problem as much.
% That is because the data don't have quite a linear correlation. To begin
% with in the linear regression model for the Setup and EDduration without TMS 
% there is no significant relationship between EDduration and Setup in the
% linear regression model as you can also clearly see in our plots also given the
% R-squared of 0.00599 and also given the p-value that is around 0.372 we can
% say that the p value is less than 0.05. In contrast to this case we also 
% found out that the linear regression when the Setup and the EDduration are
% with TMS there is a very low p value more specifically approximately
% 0.00139 and which means that the probability of observing the given data
% under H0 is very small and so we can reject H0 (null hypothesis) and
% conclude that the correlation coefficient ρ is not zero which means that
% we probably have a weak statistical relationship, given that we still have a
% low R-squared of 0.084. We can see from our plots that the TMS linear regression
% is better No TMS. Finally, we experimented with polynomial regression of degrees
% [2, 3, 5] for each of the models for both TMS and No TMS Setup and
% EDduration. Then we came into the conclusion that the polynomial models
% on EDduration and Setup for both cases provide a stronger relationship
% and also perform better than the linear regression models capturing non-linearities
% better and better as the degree increases. 