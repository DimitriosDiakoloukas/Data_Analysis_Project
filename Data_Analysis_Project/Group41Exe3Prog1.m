clc;
clear;
warning('off', 'all');

data = readtable("TMS.xlsx");

EDdurationNOTMS = data.EDduration(data.TMS == 0);
muNOTMS = mean(EDdurationNOTMS);
fprintf("Mean of all setups NO TMS: %.4f\n", muNOTMS);

EDdurationTMS = data.EDduration(data.TMS == 1);
muTMS = mean(EDdurationTMS);
fprintf("Mean of all setups TMS: %.4f\n", muTMS);

total_setups = 6;
B = 3000;

fprintf("NO TMS DATA \n");
NO_TMS_results = [];

for setup = 1:total_setups
    setupdataNOTMS = data.EDduration(data.TMS == 0 & data.Setup == setup);
    muNOTMSSETUP = mean(setupdataNOTMS);
    fprintf("Mean of setup %d NO TMS: %.4f\n", setup, muNOTMSSETUP);
    
    if ~isempty(setupdataNOTMS)
        normalDistribution = fitdist(setupdataNOTMS, 'Normal');
        
        figure;
        histogram(setupdataNOTMS, 'Normalization', 'pdf', NumBins = 100);
        hold on;
        X = linspace(min(setupdataNOTMS), max(setupdataNOTMS), 1000);
        Y = pdf(normalDistribution, X);
        plot(X, Y, 'DisplayName', 'Normal PDF');
        title(sprintf('Setup %d - Normal Distribution Fit', setup));
        legend('show');
        hold off;

        [h, p, stats] = chi2gof(setupdataNOTMS, 'CDF', normalDistribution);
        isnormal = ~h;
        
        if isnormal 
            ci = paramci(normalDistribution, 'Parameter', 'mu');
            fprintf("Parametric Confidence Interval for setup %d: [%.4f, %.4f]\n", setup, ci(1), ci(2));
        else 
            ci = bootci(B, @mean, setupdataNOTMS);
            fprintf("Bootstrap Confidence Interval for setup %d: [%.4f, %.4f]\n", setup, ci(1), ci(2));
        end
        
        NO_TMS_results = [NO_TMS_results; setup, muNOTMSSETUP, isnormal, ci(1), ci(2)];
    else
        NO_TMS_results = [NO_TMS_results; setup, NaN, NaN, NaN, NaN];
    end
end

fprintf("TMS DATA \n");
TMS_results = [];

for setup = 1:total_setups
    setupdataTMS = data.EDduration(data.TMS == 1 & data.Setup == setup);
    muTMSSETUP = mean(setupdataTMS);
    fprintf("Mean of setup %d TMS: %.4f\n", setup, muTMSSETUP);
    
    if ~isempty(setupdataTMS)
        normalDistribution = fitdist(setupdataTMS, 'Normal');
        
        figure;
        histogram(setupdataTMS, 'Normalization', 'pdf', NumBins = 100);
        hold on;
        X = linspace(min(setupdataTMS), max(setupdataTMS), 1000);
        Y = pdf(normalDistribution, X);
        plot(X, Y, 'DisplayName', 'Normal PDF');
        title(sprintf('Setup %d - Normal Distribution Fit', setup));
        legend('show');
        hold off;

        [h, p, stats] = chi2gof(setupdataTMS, 'CDF', normalDistribution);
        isnormal = ~h;
        
        if isnormal 
            ci = paramci(normalDistribution, 'Parameter', 'mu');
            fprintf("Parametric Confidence Interval for setup %d: [%.4f, %.4f]\n", setup, ci(1), ci(2));
        else 
            ci = bootci(B, @mean, setupdataTMS);
            fprintf("Bootstrap Confidence Interval for setup %d: [%.4f, %.4f]\n", setup, ci(1), ci(2));
        end
        
        TMS_results = [TMS_results; setup, muTMSSETUP, isnormal, ci(1), ci(2)];
    else
        TMS_results = [TMS_results; setup, NaN, NaN, NaN, NaN];
    end
end

NO_TMS_table = array2table(NO_TMS_results, ...
    'VariableNames', {'Setup', 'Mean', 'IsNormal', 'CI_Lower', 'CI_Upper'});

TMS_table = array2table(TMS_results, ...
    'VariableNames', {'Setup', 'Mean', 'IsNormal', 'CI_Lower', 'CI_Upper'});

writetable(NO_TMS_table, 'results_ex3.xlsx', 'Sheet', 'NO_TMS');
writetable(TMS_table, 'results_ex3.xlsx', 'Sheet', 'TMS');

fprintf("\nResults saved to results.xlsx\n");


% OUR OBSERVTIONS AND RESULTS BELOW

% NO TMS <--> SETUP 1 ==> We can accept that the mean ED duration is μ0
% NO TMS <--> SETUP 2 ==> We can accept that the mean ED duration is μ0
% NO TMS <--> SETUP 3 ==> We cannot accept that the mean ED duration is μ0
% NO TMS <--> SETUP 4 ==> We cannot accept that the mean ED duration is μ0
% NO TMS <--> SETUP 5 ==> We cannot accept that the mean ED duration is μ0
% NO TMS <--> SETUP 6 ==> We can accept that the mean ED duration is μ0
% TMS <--> SETUP 1 ==> We can accept that the mean ED duration is μ0
% TMS <--> SETUP 2 ==> We cannot accept that the mean ED duration is μ0
% TMS <--> SETUP 3 ==> We can accept that the mean ED duration is μ0
% TMS <--> SETUP 4 ==> We cannot accept that the mean ED duration is μ0
% TMS <--> SETUP 5 ==> We can accept that the mean ED duration is μ0
% TMS <--> SETUP 6 ==> We cannot accept that the mean ED duration is μ0

% As we can see the results in the 2 cases TMS and NO TMS are
% contradictory.
