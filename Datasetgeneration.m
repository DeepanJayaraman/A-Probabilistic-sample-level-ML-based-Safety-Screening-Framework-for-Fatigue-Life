
clear
close all
rng(42);  % Sets the seed for random number generation

%% [0_8] Laminate Data
Nf_1_633GPa = [2100, 3000, 4200, 6000];            % σ ≈ 1.633 GPa (0.81)
Nf_1_552GPa = [4200, 15000, 30000, 55000];         % σ ≈ 1.552 GPa (0.77)
Nf_1_452GPa = [60000, 100000, 160000, 240000];     % σ ≈ 1.452 GPa (0.72)
Nf_1_371GPa = [300000, 450000, 700000, 1000000];   % σ ≈ 1.371 GPa (0.68)
%% [0_2/90_2]_s Laminate Data
Nf_0_980GPa = [220, 310, 450, 800];                % σ ≈ 0.980 GPa (0.95)
Nf_0_949GPa = [1000, 1800, 3200, 4500];            % σ ≈ 0.949 GPa (0.92)
Nf_0_928GPa = [12000, 25000, 45000, 95000];        % σ ≈ 0.928 GPa (0.90)

%% Analysis setup
Cases = {Nf_1_633GPa, Nf_1_552GPa, Nf_1_452GPa, Nf_1_371GPa, Nf_0_980GPa, Nf_0_949GPa, Nf_0_928GPa};
CaseNames = {'Nf_1.633 GPa','Nf_1.552 GPa','Nf_1.452 GPa','Nf_1_371GPa','Nf_0.980 GPa','Nf_0.949 GPa','Nf_0.928 GPa'};
N_list = [5,7,9,11];   % sample sizes per experiment

% Consolidated dataset table
Dataset = table('Size',[0 5], ...
    'VariableTypes',{'string','double','double','double','logical'}, ...
    'VariableNames',{'Case','N','T3','T4','CmomFailure'});

for k = 1:numel(Cases)
    Nf = Cases{k};
    [beta, eta, ~] = weibull_fit(Nf, false);

    % Reference distribution (truth percentiles)
    [samples_big, ~] = weibull_rand(beta, eta, 1e6);
    Extreme = prctile(samples_big, 1);   % keep your 1% extreme
    percentiles = [10 5 90 50];
    p_values_ref = prctile(samples_big, percentiles);
    p90 = p_values_ref(1);
    % (If you later want to use 95th, change Cp vector and p_ref accordingly.)

    for i = 1:length(N_list)
        % per sample-size collectors for 100 repetitions
        T3_vec     = nan(1,100);
        T4_vec     = nan(1,100);
        Cp90_vec   = nan(1,100);   % from C-moment synthetic 'r'
        neg_flag   = false(1,100); % any negatives (X or r) in that repetition

        for j = 1:100
            % ------- L-moments path -------
            try
                samples = [weibull_rand(beta, eta, N_list(i)); Extreme];

                [Distribution_type, L_sample, ~, ~] = Identify_dist(samples, 3);
                L1 = L_sample(1); L2 = L_sample(2); T3 = L_sample(3); T4 = L_sample(4);

                Distribution_type = Distribution_type(ismember(lower(Distribution_type), ...
                    {'uniform','exponential','lognormal','gamma','weibull','generalized pareto'}));
                P = Parameter_estimation(samples, Distribution_type{1,1}, L1, L2, T3, T4);
                X = Random_l(Distribution_type{1,1}, P, 1e5, 1);

                T3_vec(j) = T3;
                T4_vec(j) = T4;

                anyXneg = any(X < 0);
            catch
                anyXneg = false;  % T3/T4 remain NaN if L path fails
            end

            % ------- C-moments (Pearson) path -------
            try
                mu   = mean(samples);
                sigma = std(samples);
                skew = skewness(samples);
                kurt = kurtosis(samples);

                r = pearsrnd(mu, sigma, skew, kurt, 1e5, 1);
                anyrneg = any(r < 0);

                p_c = prctile(r, percentiles);
                Cp90_vec(j) = p_c(1);
            catch
                anyrneg = false;   % Cp90_vec(j) stays NaN => failure later
            end

            neg_flag(j) = anyXneg || anyrneg;
        end % repetitions

        % ------- FAILURE (ratio-only + safeguards) -------
        % Ratio deviation on 90th percentile:
        % RC90 deviation > 0.3  => failure
        rc_dev_fail = abs(Cp90_vec./p90 - 1) > 0.3;

        % Safeguards: NaN or negatives => failure
        nan_fail    = isnan(Cp90_vec);
        failure_vec = rc_dev_fail | nan_fail | neg_flag;

        % Build rows for dataset
        rows = table( ...
            repmat(string(CaseNames{k}), 100, 1), ... % Case
            repmat(N_list(i), 100, 1), ...            % N
            T3_vec(:), ...                            % T3
            T4_vec(:), ...                            % T4
            failure_vec(:), ...                       % CmomFailure
            'VariableNames', {'Case','N','T3','T4','CmomFailure'} );

        Dataset = [Dataset; rows];

        % Optional quick summary
        fprintf('Case: %s, N=%d, failure_rate=%.2f\n', ...
            CaseNames{k}, N_list(i), mean(failure_vec));
    end
end

% Save consolidated dataset
outAll = "C:\Users\jayard4\OneDrive - Caterpillar\Research\Probabilistic SN\UQ-main\results\AllCases_T3T4_CmomFailure_RATIO_ONLY.mat";
save(outAll, 'Dataset', '-v7.3');

% Quick peek
head(Dataset)
