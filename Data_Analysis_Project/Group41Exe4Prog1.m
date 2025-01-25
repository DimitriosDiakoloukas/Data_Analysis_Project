clc;
clear;

data = readtable("TMS.xlsx");
total_setups = 6;
B = 1000;
a = 0.05;

results = {};

for setup = 1:total_setups
    preTMS = data.preTMS(data.TMS == 1 & data.Setup == setup);
    postTMS = data.postTMS(data.TMS == 1 & data.Setup == setup);

    if ~isempty(preTMS) && ~isempty(postTMS)
        [rho, pval] = corr(preTMS, postTMS, 'Type', 'Pearson');
        n = length(preTMS);
        t = rho * sqrt((n - 2) / (1 - rho^2));
        w = atanh(rho);
        res = [w - norminv(1 - a/2) * sqrt(1 / (n - 3)), w + norminv(1 - a/2) * sqrt(1 / (n - 3))];
        rho_new = tanh(res);

        fprintf('Setup %d:\n', setup);
        fprintf('Pearson correlation coefficient (rho): %.4f\n', rho);
        fprintf('95%% Confidence Interval for rho: [%.4f, %.4f]\n', rho_new(1), rho_new(2));
        fprintf('p-value: %.4f\n', pval);
        fprintf('Observed t-statistic: %.4f\n', t);

        t_rand = zeros(B, 1);
        for var = 1:B
            rand_postTMS = postTMS(randperm(length(postTMS)));
            rand_correlations = corr(preTMS, rand_postTMS, 'Type', 'Pearson');
            t_rand(var) = rand_correlations * sqrt((n - 2) / (1 - rand_correlations^2));
        end

        fprintf('Summary of Randomization Test t-statistics:\n');
        fprintf('Min: %.4f, Max: %.4f\n\n', min(t_rand), max(t_rand));

        figure;
        histogram(t_rand, 30, 'Normalization', 'probability');
        hold on;
        ylimits = ylim;
        plot([t, t], [0, ylimits(2)], 'LineWidth', 3);
        title(sprintf('Randomization Test t-Statistic Distribution (Setup %d)', setup));
        xlabel('t-Statistic');
        ylabel('Probability');
        legend('Randomized t-Statistics', 'Observed t-Statistic');
        grid on;
        hold off;

        results = [results; {setup, rho, rho_new(1), rho_new(2), pval, t, min(t_rand), max(t_rand)}];
    end
end

results_table = cell2table(results, 'VariableNames', {'Setup', 'Rho', 'CI_Lower', 'CI_Upper', 'P_Value', 'Observed_T', 'Rand_Min_T', 'Rand_Max_T'});
writetable(results_table, 'results_ex4.xlsx', 'WriteRowNames', true);

fprintf('Results saved to results.xlsx\n');

% OUR OBSERVTIONS AND RESULTS BELOW

% In every case 0 is in the confidence interval for every setup and also
% the value of t-statistic is always (for every setup) in the range of
% t-statistic variables produced by randomization test (permutation). Also
% the p variable is not close to zero (as mentioned in page 87 in the Data Analysis Notes)
% so we cannot say they are uncorrelated.

