clc;
clear;
warning('off', 'all');
data = readtable("TMS.xlsx");

EDdurationTMS = data.EDduration(data.TMS == 1);

%% PRE TMS ONLY ADDED IN FEATURES
fprintf("\n####################################################\n");
fprintf("####################### PRE TMS ####################\n");
fprintf("####################################################\n\n");
features_all_no_SpikePRE = [data.Setup(data.TMS == 1), str2double(data.Stimuli(data.TMS == 1)), str2double(data.Intensity(data.TMS == 1)), ... 
    str2double(data.Frequency(data.TMS == 1)), str2double(data.CoilCode(data.TMS == 1)), data.preTMS(data.TMS == 1)];

[b1, ~, r1, ~, stats1] = regress(EDdurationTMS, features_all_no_SpikePRE);
mse1 = mean(r1.^2);
R2_1 = stats1(1);
y_pred1 = features_all_no_SpikePRE * b1;

fprintf('Model 1 (Multiple Linear Regression without Spike):\n');
fprintf('Mean Squared Error (MSE): %.4f\n', mse1);
fprintf('R-squared (R^2): %.4f\n\n', R2_1);

figure;
scatter(1:length(EDdurationTMS), EDdurationTMS, 'b', 'DisplayName', 'Original Data');
hold on;
plot(1:length(y_pred1), y_pred1, 'r', 'LineWidth', 2, 'DisplayName', 'Regression Model');
hold off;
xlabel('Data Index');
ylabel('EDdurationTMS');
title('Original Data NO SPIKE and Regression Model PRE');
legend('show');
grid on;

fprintf("#####################################################\n\n");
fprintf("Model 2 (Stepwise Regression without Spike)\n");
modelStepwise1 = stepwiselm(features_all_no_SpikePRE, EDdurationTMS);
y_predStepwise1 = predict(modelStepwise1, features_all_no_SpikePRE);
mse_stepwise1 = mean((EDdurationTMS - y_predStepwise1).^2);
disp(modelStepwise1);
disp(['Manual MSE Calculation is ---> ', num2str(mse_stepwise1)]);

figure;
scatter(1:length(EDdurationTMS), EDdurationTMS, 'b', 'DisplayName', 'Original Data');
hold on;
plot(1:length(y_predStepwise1), y_predStepwise1, 'g', 'LineWidth', 2, 'DisplayName', 'Stepwise Regression Model');
hold off;
xlabel('Data Index');
ylabel('EDdurationTMS');
title('Stepwise Regression NO SPIKE PRE');
legend('show');
grid on;

fprintf("\n#####################################################\n\n");
fprintf("Model 3 (LASSO Regression without Spike)\n");
[B_lasso1, FitInfo1] = lasso(features_all_no_SpikePRE, EDdurationTMS);
[~, lambda1] = min(FitInfo1.MSE);
B_optimal1 = B_lasso1(:, lambda1); 
intercept1 = FitInfo1.Intercept(lambda1);
y_predLasso1 = features_all_no_SpikePRE * B_optimal1 + intercept1;
mse_lasso1 = mean((EDdurationTMS - y_predLasso1).^2);
R2_lasso1 = 1 - sum((EDdurationTMS - y_predLasso1).^2) / sum((EDdurationTMS - mean(EDdurationTMS)).^2);
fprintf('Mean Squared Error (MSE): %.4f\n', mse_lasso1);
fprintf('R-squared (R^2): %.4f\n\n', R2_lasso1);

figure;
scatter(1:length(EDdurationTMS), EDdurationTMS, 'b', 'DisplayName', 'Original Data');
hold on;
plot(1:length(y_predLasso1), y_predLasso1, 'k', 'LineWidth', 2, 'DisplayName', 'LASSO Regression Model');
hold off;
xlabel('Data Index');
ylabel('EDdurationTMS');
title('LASSO Regression NO SPIKE PRE');
legend('show');
grid on;

[~, score, ~, ~, explained] = pca(features_all_no_SpikePRE);
num_components = find(cumsum(explained) >= 95, 1); 
best_comp = score(:, 1:num_components);
best_comp_ones = [ones(size(best_comp, 1), 1), best_comp];
[b_pcr, ~, r_pcr, ~, stats_pcr] = regress(EDdurationTMS, best_comp_ones);
mse_pcr = mean(r_pcr.^2);
R2_pcr = stats_pcr(1);
y_pred_pcr = best_comp_ones * b_pcr;
fprintf("#####################################################\n\n");
fprintf('Model 4 (Multiple Linear Regression without Spike PCA 95%%):\n');
fprintf('Mean Squared Error (MSE): %.4f\n', mse_pcr);
fprintf('R-squared (R^2): %.4f\n\n', R2_pcr);

figure;
scatter(1:length(EDdurationTMS), EDdurationTMS, 'b', 'DisplayName', 'Original Data');
hold on;
plot(1:length(y_pred_pcr), y_pred_pcr, 'r', 'LineWidth', 2, 'DisplayName', 'Regression Model');
hold off;
xlabel('Data Index');
ylabel('EDdurationTMS');
title('Original Data NO SPIKE and Regression Model PCA PRE');
legend('show');
grid on;


%% POST TMS AND PRE TMS ADDED IN FEATURES
fprintf("\n######################################################\n");
fprintf("##################### POST PRE TMS ###################\n");
fprintf("######################################################\n\n");
features_all_no_SpikePREPOST = [data.Setup(data.TMS == 1), str2double(data.Stimuli(data.TMS == 1)), str2double(data.Intensity(data.TMS == 1)), ... 
    str2double(data.Frequency(data.TMS == 1)), str2double(data.CoilCode(data.TMS == 1)), data.preTMS(data.TMS == 1), data.postTMS(data.TMS == 1)];

[b2, ~, r2, ~, stats2] = regress(EDdurationTMS, features_all_no_SpikePREPOST);
mse2 = mean(r2.^2);
R2_2 = stats2(1);
y_pred2 = features_all_no_SpikePREPOST * b2;

fprintf('Model 5 (Multiple Linear Regression without Spike):\n');
fprintf('Mean Squared Error (MSE): %.4f\n', mse2);
fprintf('R-squared (R^2): %.4f\n\n', R2_2);

figure;
scatter(1:length(EDdurationTMS), EDdurationTMS, 'b', 'DisplayName', 'Original Data');
hold on;
plot(1:length(y_pred2), y_pred2, 'r', 'LineWidth', 2, 'DisplayName', 'Regression Model');
hold off;
xlabel('Data Index');
ylabel('EDdurationTMS');
title('Original Data NO SPIKE and Regression Model POST PRE');
legend('show');
grid on;

fprintf("#####################################################\n\n");
fprintf("Model 6 (Stepwise Regression without Spike)\n");
modelStepwise2 = stepwiselm(features_all_no_SpikePREPOST, EDdurationTMS);
y_predStepwise2 = predict(modelStepwise2, features_all_no_SpikePREPOST);
mse_stepwise2 = mean((EDdurationTMS - y_predStepwise2).^2);
disp(modelStepwise2);
disp(['Manual MSE Calculation is ---> ', num2str(mse_stepwise2)]);

figure;
scatter(1:length(EDdurationTMS), EDdurationTMS, 'b', 'DisplayName', 'Original Data');
hold on;
plot(1:length(y_predStepwise2), y_predStepwise2, 'g', 'LineWidth', 2, 'DisplayName', 'Stepwise Regression Model');
hold off;
xlabel('Data Index');
ylabel('EDdurationTMS');
title('Stepwise Regression NO SPIKE POST PRE');
legend('show');
grid on;

fprintf("\n#####################################################\n\n");
fprintf("Model 7 (LASSO Regression without Spike)\n");
[B_lasso2, FitInfo2] = lasso(features_all_no_SpikePREPOST, EDdurationTMS);
[~, lambda2] = min(FitInfo2.MSE);
B_optimal2 = B_lasso2(:, lambda2); 
intercept2 = FitInfo2.Intercept(lambda2);
y_predLasso2 = features_all_no_SpikePREPOST * B_optimal2 + intercept2;
mse_lasso2 = mean((EDdurationTMS - y_predLasso2).^2);
R2_lasso2 = 1 - sum((EDdurationTMS - y_predLasso2).^2) / sum((EDdurationTMS - mean(EDdurationTMS)).^2);
fprintf('Mean Squared Error (MSE): %.4f\n', mse_lasso2);
fprintf('R-squared (R^2): %.4f\n\n', R2_lasso2);

figure;
scatter(1:length(EDdurationTMS), EDdurationTMS, 'b', 'DisplayName', 'Original Data');
hold on;
plot(1:length(y_predLasso2), y_predLasso2, 'k', 'LineWidth', 2, 'DisplayName', 'LASSO Regression Model');
hold off;
xlabel('Data Index');
ylabel('EDdurationTMS');
title('LASSO Regression NO SPIKE POST PRE');
legend('show');
grid on;

[~, score_2, ~, ~, explained_2] = pca(features_all_no_SpikePREPOST);
num_components_2 = find(cumsum(explained_2) >= 95, 1); 
best_comp_2 = score_2(:, 1:num_components_2);
best_comp_ones_2 = [ones(size(best_comp_2, 1), 1), best_comp_2];
[b_pcr_2, ~, r_pcr_2, ~, stats_pcr_2] = regress(EDdurationTMS, best_comp_ones_2);
mse_pcr_2 = mean(r_pcr_2.^2);
R2_pcr_2 = stats_pcr_2(1);
y_pred_pcr_2 = best_comp_ones_2 * b_pcr_2;
fprintf("#####################################################\n\n");
fprintf('Model 8 (Multiple Linear Regression without Spike PCA 95%%):\n');
fprintf('Mean Squared Error (MSE): %.4f\n', mse_pcr_2);
fprintf('R-squared (R^2): %.4f\n\n', R2_pcr_2);

figure;
scatter(1:length(EDdurationTMS), EDdurationTMS, 'b', 'DisplayName', 'Original Data');
hold on;
plot(1:length(y_pred_pcr_2), y_pred_pcr_2, 'r', 'LineWidth', 2, 'DisplayName', 'Regression Model');
hold off;
xlabel('Data Index');
ylabel('EDdurationTMS');
title('Original Data NO SPIKE and Regression Model PCA POST PRE');
legend('show');
grid on;

% OUR OBSERVTIONS AND RESULTS BELOW

% It is important to note here that in this Exercise we again used the
% features excluding the Spikes since they seem to worsen the performance
% of our models.
%
% PRE TMS ONLY: Adding the PreTMS part on the features used in Exercise 6
% now the dataset seems to have significantly more features than we did in
% the Exercise 5 so the predictions are obviously improved in every case 
% including Multiple Linear Regression with and without PCA, Lasso Regression
% and Stepwise regression and of course the models seem to generalize better.
% Now to make comparisons to Exercise 6 the inclusion of PreTMS seems to
% increase the performance of the model since the variance is a higher value due to
% the increased R-squared in every case (Multiple Linear Regression, Lasso
% Regression and Stepwise Regression). The models seem to generalize better than those
% in the Exercise 6 where the PreTMS wasn't included with the Stepwise regression
% again being the best performing due to the lower MSE and higher R-squared
% while the Lasso and Multiple Linear Regression models seem to have
% similar performance. Now our new implementation with PCA for the Multiple Linear
% Regression model with regress where we chose to have a cumulative variance of components
% higher than 95% doesn't seem to perform as good as the one without since the
% PCR involves dimentionality reduction and we have less components selected based
% on the variance of their features so the model in other words there is
% loss of information.
%
% POST TMS AND PRE TMS: Adding PostTMS and PreTMS seems to have significant
% inpact on the performance of our models. This addition seems to cause the
% relationships between the EDduration and the features to be almost deterministic
% and we can conclude that the models (every single one of them even Multiple Linear
% Regressionwith PCA) are all overfitting, since each and every one of them achieves
% a R-squared very close to 1 and a MSE very close to zero. We can easily come
% into the conclusion that the addition of PostTMS in our features of the dataset
% has a strong predicting infuence given the almost perfect fit the models have to
% our data. Our plots comprehensively provide the visualisation of the results in our
% console.