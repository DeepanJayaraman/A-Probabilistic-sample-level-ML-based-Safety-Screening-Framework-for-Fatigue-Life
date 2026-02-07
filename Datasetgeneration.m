
clear
close all
rng(42);  % Sets the seed for random number generation

Add the data here as List

%% Analysis setup
Cases = {Case};
CaseNames = {Case Name as string};



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
outAll = FileName;
save(outAll, 'Dataset', '-v7.3');

% Quick peek
head(Dataset)
