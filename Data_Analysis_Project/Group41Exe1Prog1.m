clc;
clear;

data = readtable("TMS.xlsx");

EDdurationTMS = data.EDduration(data.TMS == 1);
EDdurationNOTMS = data.EDduration(data.TMS == 0);

NumBins = 100;

distributionNOTMS = fitdist(EDdurationNOTMS, "Burr");
distributionTMS = fitdist(EDdurationTMS, "Burr");
% distributionNOTMS = fitdist(EDdurationNOTMS, "Lognormal");
% distributionTMS = fitdist(EDdurationTMS, "Lognormal");
% distributionNOTMS = fitdist(EDdurationNOTMS, "Weibull");
% distributionTMS = fitdist(EDdurationTMS, "Weibull");
% distributionNOTMS = fitdist(EDdurationNOTMS, "Exponential");
% distributionTMS = fitdist(EDdurationTMS, "Exponential");
% distributionNOTMS = fitdist(EDdurationNOTMS, "Gamma");
% distributionTMS = fitdist(EDdurationTMS, "Gamma");

edges = linspace(min(EDdurationTMS), max(EDdurationTMS), NumBins); 
[h1, p1] = chi2gof(EDdurationTMS, 'Edges', edges, 'CDF', distributionTMS);
fprintf('CHITOGOF TESTING (Custom Bins) TMS: h1 = %d p1 = %.4f\n', h1, p1);

edges = linspace(min(EDdurationNOTMS), max(EDdurationNOTMS), NumBins);
[h2, p2] = chi2gof(EDdurationNOTMS, 'Edges', edges, 'CDF', distributionNOTMS);
fprintf('CHITOGOF TESTING (Custom Bins) NO TMS: h2 = %d p2 = %.4f\n', h2, p2);

% Plot --> NO TMS
figure;
histogram(EDdurationNOTMS, 'Normalization', 'pdf', 'NumBins', NumBins);
hold on;
X = linspace(min(EDdurationNOTMS), max(EDdurationNOTMS), 1000);
Y = pdf(distributionNOTMS, X);
plot(X, Y, 'DisplayName', 'Burr Fit PDF');
title('EDduration Without TMS - Burr Distribution');
xlabel('EDduration');
ylabel('Probability Density');
legend("show");
grid on;
hold off;

% Plot --> TMS
figure;
histogram(EDdurationTMS, 'Normalization', 'pdf', 'NumBins', NumBins);
hold on;
X = linspace(min(EDdurationTMS), max(EDdurationTMS), 1000);
Y = pdf(distributionTMS, X);
plot(X, Y, 'DisplayName', 'Burr Fit PDF');
title('EDduration With TMS - Burr Distribution');
xlabel('EDduration');
ylabel('Probability Density');
legend("show");
grid on;
hold off;



% OUR OBSERVTIONS AND RESULTS BELOW

% BURR SEEMS TO PERFORM THE BEST FOR OUR CASE TESTING BELOW (WE TESTED
% WEIBULL, LOGNORMAL, GAMMA, EXPONENTIAL AS WELL).
% WE GOT THE FOLLOWING RESULTS FROM CHI2GOF BELOW.
% BURR: 
    % CHITOGOF TESTING (Custom Bins) TMS: h1 = 0 p1 = 0.1969
    % CHITOGOF TESTING (Custom Bins) NO TMS: h2 = 0 p2 = 0.1110
% LOGNORMAL:
    % CHITOGOF TESTING (Custom Bins) TMS: h1 = 0 p1 = 0.1337
    % CHITOGOF TESTING (Custom Bins) NO TMS: h2 = 0 p2 = 0.0624
% GAMMA:
    % CHITOGOF TESTING (Custom Bins) TMS: h1 = 1 p1 = 0.0050
    % CHITOGOF TESTING (Custom Bins) NO TMS: h2 = 1 p2 = 0.0008
% EXPONENTIAL:
    % CHITOGOF TESTING (Custom Bins) TMS: h1 = 1 p1 = 0.0000
    % CHITOGOF TESTING (Custom Bins) NO TMS: h2 = 1 p2 = 0.0004
% WEIBULL:
    % CHITOGOF TESTING (Custom Bins) TMS: h1 = 1 p1 = 0.0003
    % CHITOGOF TESTING (Custom Bins) NO TMS: h2 = 1 p2 = 0.0004