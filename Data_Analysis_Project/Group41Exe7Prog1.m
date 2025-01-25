clc;
clear;

data = readtable("TMS.xlsx");

EDdurationTMS = data.EDduration(data.TMS == 1);

features_all_no_Spike = [data.Setup(data.TMS == 1), str2double(data.Stimuli(data.TMS == 1)), str2double(data.Intensity(data.TMS == 1)), ... 
    str2double(data.Frequency(data.TMS == 1)), str2double(data.CoilCode(data.TMS == 1))];

rng(1);
n = length(EDdurationTMS);
train_part = 0.7;
test_part = 1 - train_part;
trainIdx = randperm(n, round(train_part * n));
testIdx = setdiff(1:n, trainIdx);

X_train = features_all_no_Spike(trainIdx, :);
Y_train = EDdurationTMS(trainIdx);
X_test = features_all_no_Spike(testIdx, :);
Y_test = EDdurationTMS(testIdx);

[b1, ~, ~, ~, ~] = regress(Y_train, X_train);
y_pred1 = X_test * b1;
mse1 = mean((Y_test - y_pred1).^2);
R2 = 1 - sum((Y_test - y_pred1).^2) / sum((Y_test - mean(Y_test)).^2);
fprintf('Model 1 (Multiple Linear Regression without Spike):\n');
fprintf('Mean Squared Error (MSE): %.4f\n', mse1);
fprintf('R-squared (R^2): %.4f\n\n', R2);

% PLOT MULTILPE LINEAR REGRESSOR WITHOUT SPIKE
figure;
scatter(1:length(Y_test), Y_test, 'b', 'DisplayName', 'Original Data');
hold on;
plot(1:length(y_pred1), y_pred1, 'r', 'LineWidth', 2, 'DisplayName', 'Regression Model');
hold off;
xlabel('Data Index');
ylabel('EDdurationTMS (Test Set)')
title('Original Data NO SPIKE and Regression Model');
legend('show');
grid on;

fprintf("#####################################################\n\n");
fprintf("Model 2 (Stepwise Regression without Spike) --> Full Dataset\n");
modelStepwise1 = stepwiselm(features_all_no_Spike, EDdurationTMS);
y_predStepwise1 = predict(modelStepwise1, X_test);
mse_stepwise1 = mean((Y_test - y_predStepwise1).^2);
R2_step1 = 1 - sum((Y_test - y_predStepwise1).^2) / sum((Y_test - mean(Y_test)).^2);
disp(modelStepwise1);
disp(['Manual MSE (Y TEST) Calculation is ---> ', num2str(mse_stepwise1)]);
disp(['Manual R2 (Y TEST) Calculation is ---> ', num2str(R2_step1)]);

fprintf("\n#####################################################\n\n");
fprintf("Model 3 (Stepwise Regression without Spike) --> Split Dataset\n");
modelStepwise2 = stepwiselm(X_train, Y_train);
y_predStepwise2 = predict(modelStepwise2, X_test);
mse_stepwise2 = mean((Y_test - y_predStepwise2).^2);
R2_step2 = 1 - sum((Y_test - y_predStepwise2).^2) / sum((Y_test - mean(Y_test)).^2);
disp(modelStepwise2);
disp(['Manual MSE Calculation is ---> ', num2str(mse_stepwise2)]);
disp(['Manual R2 (Y TEST) Calculation is ---> ', num2str(R2_step2)]);

figure;
scatter(1:length(Y_test), Y_test, 'b', 'DisplayName', 'Original Data');
hold on;
plot(1:length(y_predStepwise1), y_predStepwise1, 'g', 'LineWidth', 2, 'DisplayName', 'Stepwise Regression Model');
hold off;
xlabel('Data Index');
ylabel('EDdurationTMS (Test Set)');
title('Stepwise Regression NO SPIKE Full Dataset');
legend('show');
grid on;

figure;
scatter(1:length(Y_test), Y_test, 'b', 'DisplayName', 'Original Data');
hold on;
plot(1:length(y_predStepwise2), y_predStepwise2, 'g', 'LineWidth', 2, 'DisplayName', 'Stepwise Regression Model');
hold off;
xlabel('Data Index');
ylabel('EDdurationTMS (Test Set)');
title('Stepwise Regression NO SPIKE Split Dataset');
legend('show');
grid on;

fprintf("\n#####################################################\n\n");
fprintf("Model 4 (LASSO Regression without Spike) Full Dataset\n");
[B_lasso1, FitInfo1] = lasso(features_all_no_Spike, EDdurationTMS);
[~, lambda1] = min(FitInfo1.MSE);
B_optimal1 = B_lasso1(:, lambda1); 
intercept1 = FitInfo1.Intercept(lambda1);
y_predLasso1 = X_test * B_optimal1 + intercept1;
mse_lasso1 = mean((Y_test - y_predLasso1).^2);
R2_lasso1 = 1 - sum((Y_test - y_predLasso1).^2) / sum((Y_test - mean(Y_test)).^2);
fprintf('Mean Squared Error (MSE): %.4f\n', mse_lasso1);
fprintf('R-squared (R^2): %.4f\n\n', R2_lasso1);

fprintf("#####################################################\n\n");
fprintf("Model 5 (LASSO Regression without Spike) Split Dataset\n");
[B_lasso2, FitInfo2] = lasso(X_train, Y_train);
[~, lambda2] = min(FitInfo2.MSE);
B_optimal2 = B_lasso2(:, lambda2); 
intercept2 = FitInfo2.Intercept(lambda2);
y_predLasso2 = X_test * B_optimal2 + intercept2;
mse_lasso2 = mean((Y_test - y_predLasso2).^2);
R2_lasso2 = 1 - sum((Y_test - y_predLasso2).^2) / sum((Y_test - mean(Y_test)).^2);
fprintf('Mean Squared Error (MSE): %.4f\n', mse_lasso2);
fprintf('R-squared (R^2): %.4f\n\n', R2_lasso2);

figure;
scatter(1:length(Y_test), Y_test, 'b', 'DisplayName', 'Original Data');
hold on;
plot(1:length(y_predLasso1), y_predLasso1, 'k', 'LineWidth', 2, 'DisplayName', 'LASSO Regression Model');
hold off;
xlabel('Data Index');
ylabel('EDdurationTMS (Test Set)');
title('LASSO Regression NO SPIKE Full Dataset');
legend('show');
grid on;

figure;
scatter(1:length(Y_test), Y_test, 'b', 'DisplayName', 'Original Data');
hold on;
plot(1:length(y_predLasso2), y_predLasso2, 'k', 'LineWidth', 2, 'DisplayName', 'LASSO Regression Model');
hold off;
xlabel('Data Index');
ylabel('EDdurationTMS (Test Set)');
title('LASSO Regression NO SPIKE Split Dataset');
legend('show');
grid on;

% OUR OBSERVTIONS AND RESULTS BELOW

% Given the results of the previous exercise (Exercise 6) we found out that
% the models without Spikes are better and predict more smoothly the
% dataset against EDduration. That is why we now didn't include Spikes in
% our implementation of Exercise 7. Initially we implemented a dataset
% split 70% Train Set and 30% Test Set. We later implemented a Multiple
% Linear Regression model like in the previous exercise but now with the
% split dataset (train set for training of the model and test set for evaluation
% and predict). The results we got suggest that the R-squared was pretty
% low which indicates that the variance was low and so the model wasn't a
% great fit for the data. We can also assume that the model isn't a great
% fit given the high MSE error which we calculated based on the test set
% now. Then we implemented Stepwise Regression initially on the full dataset 
% and we clearly got better results. The R-squared improved a lot and now we have
% a higher variance of almost 54% on the test set which means that the generalization
% is good to unseen data. Also we can see that the linear regression model
% used now in the Stepwise Regression is including x2, x1, x4 where x1 and x4
% are interacting via multiplication which probably shows us that the model performance is
% going to be improved. We also implemeted a Stepwise Regression model on the
% split dataset where we found out that the results weren't as good though.
% We got a lower variance given the lower R-squared value on the test set
% and also we got a higher MSE than in the case of the model being trained on the
% full dataset rather than on the train set which means that the model is not as good 
% as it was when it was trained on the full dataset. We can also see that the
% linear regression model from the Stepwise Regression (now on the split dataset)
% which was used for this case was also a more complex one and maybe good for
% our predictions given it's dependance from x1, x2, x4 values again and now an
% interaction via multiplication between x1 and x4 and also x2 and x4. Also in each
% of the cases of the Stepwise Regression the results were significantly
% better than those of the simple Multiple Linear Regression model using
% Regress. Finally we implemented two Lasso Regression models one using the
% full dataset for training and the other using the split dataset for
% training. The results indicate again that the model using the Full
% Dataset performed better with a relatively higher variance given the
% increased R-squared value and the lower MSE which means that the model
% trained in the full dataset is generalizing better at unseen data than
% the one using the split train set for training. The Lasso model has worse
% generalization than the Stepwise Regression model but it is still
% performing better than the Multiple Linear Regression model using Regress
% especially in the case of the full dataset as a train set (in the case of the
% split train set the results are similar).


% NOTE: In each case the models were evaluated and made prediction using
% the test set. You can clearly see the differences between them in our
% plots.