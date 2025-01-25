clc;
clear;

data = readtable("TMS.xlsx");

EDdurationTMS = data.EDduration(data.TMS == 1);

features_all = [data.Setup(data.TMS == 1), str2double(data.Stimuli(data.TMS == 1)), str2double(data.Intensity(data.TMS == 1)), ... 
    str2double(data.Spike(data.TMS == 1)), str2double(data.Frequency(data.TMS == 1)), str2double(data.CoilCode(data.TMS == 1))];
% disp(features_all);

features_all_no_Spike = [data.Setup(data.TMS == 1), str2double(data.Stimuli(data.TMS == 1)), str2double(data.Intensity(data.TMS == 1)), ... 
    str2double(data.Frequency(data.TMS == 1)), str2double(data.CoilCode(data.TMS == 1))];
% disp(features_all_no_Spike);

[b1, ~, r1, ~, stats1] = regress(EDdurationTMS, features_all);
mse1 = mean(r1.^2);
R2_1 = stats1(1);
y_pred1 = features_all * b1;

[b2, ~, r2, ~, stats2] = regress(EDdurationTMS, features_all_no_Spike);
mse2 = mean(r2.^2);
R2_2 = stats2(1);
y_pred2 = features_all_no_Spike * b2;

fprintf('Model 1 (Multiple Linear Regression with Spike):\n');
fprintf('Mean Squared Error (MSE): %.4f\n', mse1);
fprintf('R-squared (R^2): %.4f\n\n', R2_1);

fprintf("#####################################################\n\n");

fprintf('Model 2 (Multiple Linear Regression without Spike):\n');
fprintf('Mean Squared Error (MSE): %.4f\n', mse2);
fprintf('R-squared (R^2): %.4f\n\n', R2_2);


% PLOT WITH SPIKE
figure;
scatter(1:length(EDdurationTMS), EDdurationTMS, 'b', 'DisplayName', 'Original Data');
hold on;
plot(1:length(y_pred1), y_pred1, 'r', 'LineWidth', 2, 'DisplayName', 'Regression Model');
hold off;
xlabel('Data Index');
ylabel('EDdurationTMS');
title('Original Data SPIKE and Regression Model');
legend('show');
grid on;

% PLOT WITHOUT SPIKE
figure;
scatter(1:length(EDdurationTMS), EDdurationTMS, 'b', 'DisplayName', 'Original Data');
hold on;
plot(1:length(y_pred2), y_pred2, 'r', 'LineWidth', 2, 'DisplayName', 'Regression Model');
hold off;
xlabel('Data Index');
ylabel('EDdurationTMS');
title('Original Data NO SPIKE and Regression Model');
legend('show');
grid on;

fprintf("#####################################################\n\n");
fprintf("Model 3 (Stepwise Regression with Spike)\n");
modelStepwise1 = stepwiselm(features_all, EDdurationTMS);
y_predStepwise1 = predict(modelStepwise1, features_all);
mse_stepwise1 = mean((EDdurationTMS - y_predStepwise1).^2);
disp(modelStepwise1);
disp(['Manual MSE Calculation is ---> ', num2str(mse_stepwise1)]);

fprintf("#####################################################\n\n");
fprintf("Model 4 (Stepwise Regression without Spike)\n");
modelStepwise2 = stepwiselm(features_all_no_Spike, EDdurationTMS);
y_predStepwise2 = predict(modelStepwise2, features_all_no_Spike);
mse_stepwise2 = mean((EDdurationTMS - y_predStepwise2).^2);
disp(modelStepwise2);
disp(['Manual MSE Calculation is ---> ', num2str(mse_stepwise2)]);

% PLOT STEPWISE REGRESSION WITH SPIKE
figure;
scatter(1:length(EDdurationTMS), EDdurationTMS, 'b', 'DisplayName', 'Original Data');
hold on;
plot(1:length(y_predStepwise1), y_predStepwise1, 'g', 'LineWidth', 2, 'DisplayName', 'Stepwise Regression Model');
hold off;
xlabel('Data Index');
ylabel('EDdurationTMS');
title('Stepwise Regression with SPIKE');
legend('show');
grid on;

% PLOT STEPWISE REGRESSION WITHOUT SPIKE
figure;
scatter(1:length(EDdurationTMS), EDdurationTMS, 'b', 'DisplayName', 'Original Data');
hold on;
plot(1:length(y_predStepwise2), y_predStepwise2, 'g', 'LineWidth', 2, 'DisplayName', 'Stepwise Regression Model');
hold off;
xlabel('Data Index');
ylabel('EDdurationTMS');
title('Stepwise Regression NO SPIKE');
legend('show');
grid on;

fprintf("\n\n#####################################################\n\n");
fprintf("Model 5 (LASSO Regression with Spike)\n");
[B_lasso1, FitInfo1] = lasso(features_all, EDdurationTMS);
[~, lambda1] = min(FitInfo1.MSE);
B_optimal1 = B_lasso1(:, lambda1); 
intercept1 = FitInfo1.Intercept(lambda1);
y_predLasso1 = features_all * B_optimal1 + intercept1;
mse_lasso1 = mean((EDdurationTMS - y_predLasso1).^2);
R2_lasso1 = 1 - sum((EDdurationTMS - y_predLasso1).^2) / sum((EDdurationTMS - mean(EDdurationTMS)).^2);
fprintf('Mean Squared Error (MSE): %.4f\n', mse_lasso1);
fprintf('R-squared (R^2): %.4f\n\n', R2_lasso1);

fprintf("#####################################################\n\n");
fprintf("Model 6 (LASSO Regression without Spike)\n");
[B_lasso2, FitInfo2] = lasso(features_all_no_Spike, EDdurationTMS);
[~, lambda2] = min(FitInfo2.MSE);
B_optimal2 = B_lasso2(:, lambda2); 
intercept2 = FitInfo2.Intercept(lambda2);
y_predLasso2 = features_all_no_Spike * B_optimal2 + intercept2;
mse_lasso2 = mean((EDdurationTMS - y_predLasso2).^2);
R2_lasso2 = 1 - sum((EDdurationTMS - y_predLasso2).^2) / sum((EDdurationTMS - mean(EDdurationTMS)).^2);
fprintf('Mean Squared Error (MSE): %.4f\n', mse_lasso2);
fprintf('R-squared (R^2): %.4f\n\n', R2_lasso2);

% PLOT LASSO REGRESSION WITH SPIKE
figure;
scatter(1:length(EDdurationTMS), EDdurationTMS, 'b', 'DisplayName', 'Original Data');
hold on;
plot(1:length(y_predLasso1), y_predLasso1, 'k', 'LineWidth', 2, 'DisplayName', 'LASSO Regression Model');
hold off;
xlabel('Data Index');
ylabel('EDdurationTMS');
title('LASSO Regression with SPIKE');
legend('show');
grid on;

% PLOT LASSO REGRESSION WITHOUT SPIKE
figure;
scatter(1:length(EDdurationTMS), EDdurationTMS, 'b', 'DisplayName', 'Original Data');
hold on;
plot(1:length(y_predLasso2), y_predLasso2, 'k', 'LineWidth', 2, 'DisplayName', 'LASSO Regression Model');
hold off;
xlabel('Data Index');
ylabel('EDdurationTMS');
title('LASSO Regression NO SPIKE');
legend('show');
grid on;

% OUR OBSERVTIONS AND RESULTS BELOW

% In Multiple Linear Regression with Spike because of missing data from the
% Spike column we can conclude that it did indeed affect the residuals and
% furthermore the Mean Squared Error calculated as the mean of r squared
% (mean of (y actual minus y predicted) squared), which we calculated throughout
% the exercise for evaluation purposes. Also we extracted the value of R-squared
% from the stats variable which is returned from the regress model. This value was
% also very low indicating that the model is not good for the data since the 
% variance is low. Now in Multiple Linear Regression without Spike the model 
% doesn't seem to have missing data anymore which means that the values of the
% residuals aren't NaN anymore and thus the value of MSE is not NaN either.
% Although, the value of MSE which is quite high indicates that there is a
% high error in the predictions. Also the value of R-squared is higher
% which means that the variance is higher and the model better fits the
% data even though it is missing a feature of Spikes. Then, we tested the
% Multiple Linear Regression models against Stepwise Regression and Lasso
% Regression with and without Spike. The Stepwise Regression model with Spike
% seems to have a weak but significant statistical relationship due to the fact
% that as we can see the p-value is pretty low (equal to 0.034154 lower than 0.05
% threshold). Although it doen't seem to be a good model since it only
% includes x5 in the linear regression model as an important predictor y ~
% 1 + x5 which gave us the impression that it only include CoilCode for
% some reason in the regression model. It is important to note that the
% values of R-squared and Adjusted R-Squared and RMSE seem to be low as
% well which means that the model is not the best. When we removed the
% Spikes from the Stepwise Regression model, and saw that the linear
% regression model still has statistical relationship between the data due to
% the low p-value but now the linear regression model has dependence from the
% variables x1, x2, x4 (y ~ 1 + x2 + x1*x4) which means that there are more
% than one important predictors, now 3 and there is also an interaction
% between the two of them (multiplication). We can see that the model now
% has a higher variance due to the fact that the R-squared value and Adjusted R-Squared
% is higher (0.447 and 0.428). Again in this case the model seems to
% improve without the existance of the Spike column in tha data used.
% Finally in tha Lasso Regression with Spike we don't seem to have a valid
% output for R-squared (which is NaN) and also like in the simple Multiple
% Linear Regression with Regress for the same reason the MSE value is once
% again NaN (maybe due to the missing data in the Spike column). We cannot
% extract enough info to indicate wheather the model is good but we can
% assume that it isn't for the same reason the Multiple Linear Regression
% with Regress implementation. The Lasso Regression without Spike seems to
% have the same results as for MSE and R-squared as the Multiple Linear
% Regression without Spike did which can lead to a conclusion that the
% Spike column decreased the performance of every model we used. We can
% easily say based on the result analysis we provided that the Stepwise
% Regression without Spike was the best. The plots also verify the
% assumption.