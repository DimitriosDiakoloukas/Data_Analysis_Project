clc;
clear;

data = readtable("TMS.xlsx");

EDdurationOcta = data.EDduration(data.TMS == 1 & str2double(data.CoilCode) == 1);
EDdurationRound = data.EDduration(data.TMS == 1 & str2double(data.CoilCode) == 0);

total_resamples = 1000;
NumBins = 100;
samples = {EDdurationRound, EDdurationOcta};
coil = {'Round', 'Octagon'};
%X0_lim = [28.869, 113.145];

resampled_stat = zeros(2, total_resamples);
X0_stat = zeros(1, 2);
for i = 1:length(samples)
    smp = samples{i};
    cl = coil{i};
    exponentialDirtribution = fitdist(smp, "Exponential");
    mu_value = exponentialDirtribution.mu;
    [~, ~, sample1] = chi2gof(smp, 'CDF',  @(z) expcdf(z, mu_value), 'NBins', NumBins);
    X0_stat(i) = sample1.chi2stat;
    for j = 1:total_resamples
        resampled = exprnd(mu_value, size(smp, 1), 1);
        [~, ~, sample2] = chi2gof(resampled, 'CDF',  @(z) expcdf(z, mu_value), 'NBins', NumBins);
        resampled_stat(i, j) = sample2.chi2stat;
    end 

    figure;
    histogram(smp, 'Normalization', 'pdf', 'NumBins', NumBins);
    hold on;
    X = linspace(min(smp), max(smp), 1000);
    Y = pdf(exponentialDirtribution, X);
    plot(X, Y, 'DisplayName', 'Exponential PDF');
    title(sprintf('%s Coil - Exponential Distribution', cl));
    xlabel('EDduration');
    ylabel('Probability Density');
    legend("show");
    grid on;
    hold off;

    % PARAMETRIKO 
    [h, p] = chi2gof(smp, 'CDF',  @(z) expcdf(z, mu_value), 'NBins', NumBins);
    if h == 0
        fprintf("Statistically acceptable distribution (%s Coil)", cl);
        disp(p);
    else
        fprintf("Not statistically acceptable distribution (%s Coil)", cl);
        disp(p);
    end

    % RESAMPLING
    P = mean(resampled_stat(i, :) >= X0_stat(i));
    fprintf("p for %s Coil: %.4f\n", cl, P);
    if P < 0.05
        fprintf("%s Coil: Statistically unacceptable (χ^2_0 in the right tail).\n", cl);
    else
        fprintf("%s Coil: Statistically acceptable (χ^2_0 not in the right tail).\n", cl);
    end

    figure;
    histogram(resampled_stat(i, :), 100, 'Normalization', 'probability');
    hold on;
    ylimits = ylim;
    plot([X0_stat(i), X0_stat(i)], [0, ylimits(2)], 'LineWidth', 3);
    % hold on
    % plot([X0_lim(i), X0_lim(i)], [0, ylimits(2)], 'LineWidth', 3);
    hold off;
    title(sprintf('Empirical Distribution of χ^2 Statistics (%s Coil)', cl));
    xlabel('\chi^2 Statistic');
    ylabel('Probability');
    legend('Resampled Statistics', '\chi^2_0 (Observed)');
    grid on;
end


% disp(resampled_stat);
% disp(size(resampled_stat));
% disp(X0_stat);
% disp(size(X0_stat));


% OUR OBSERVTIONS AND RESULTS BELOW

% We chose Number of Bins to be equal to 100 for consisteny.
% RESAMPLING: We observe that the exponenential distribution for round coil
% seems to be statistically acceptable since the value of p does indeed exceed
% the threshold of 0.05 where p = P(X² > X0²). We can also see that the
% octagon coil seems to have value of p that exceeds the threshold
% 0.05 even more which seems that the distribution better fits the octagon data
% and so we can conclude that the exponential distribution is
% also statistically acceptable for the octagon coil data.

% PARAMETRIKO: We observe that the round coil approached with exponential distribution
% seems to be statistically acceptable since the value of h (result of the 
% chi2gof function) is equal to 0 which means that p value is not less than 0.05 
% which is the threshold the function uses for variable p.
% We also observe that the octagon coil seems to return h = 0 which means that
% the variable p exceeds the limit of 0.05 again and more than it did with
% the round coil data. We can also say that the exponential distribution is statistically acceptable.

