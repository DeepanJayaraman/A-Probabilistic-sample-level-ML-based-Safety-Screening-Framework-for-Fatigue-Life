clear
close all
rng(42);

%% -------- Sample Case --------
Nf = [300000, 450000, 700000, 1000000]; % Nf_1_371GPa

%% Weibull fit
[beta, eta, ~] = weibull_fit(Nf, false);

% Large sample for ground truth
[samples_full, ~] = weibull_rand(beta, eta, 1e6);
Extreme = prctile(samples_full, [2.5]);

percentiles = [10 5 90 50];
p_values = prctile(samples_full, percentiles);
[p90, p95, p10, p50] = deal(p_values(1), p_values(2), p_values(3), p_values(4));

%% -------- Sensitivity setup --------
alpha_list = 0.5:0.5:3; % 0.005:0.005:0.025;   % α variation
N = 9;                   % fixed sample size (can justify as moderate N)

CP_C90 = zeros(length(alpha_list),1);
CP_L90 = zeros(length(alpha_list),1);

%% -------- Simulation --------
for a = 1:length(alpha_list)

    alpha = alpha_list(a);

    Cp90 = []; Lp90 = [];

    for j = 1:100

        samples = [weibull_rand(beta, eta, N)];%; Extreme'

        %% ---- L-moment ----
        try
            Lsam = lmom(samples,4);
            [Distribution_type,L_sample,~,~] = Identify_dist(samples,3);

            L1= L_sample(1);L2 = L_sample(2);
            T3 = L_sample(3);T4 = L_sample(4);

            P = Parameter_estimation(samples,Distribution_type{1,1},L1,L2,T3,T4);
            X = Random_l(Distribution_type{1, 1},P,1e5,1);

            if all(X>0)
                p_vals = prctile(X, percentiles);
                Lp90(end+1) = p_vals(1);
            end
        catch
        end

        %% ---- C-moment ----
        try
            mu = mean(samples);
            sigma = std(samples);
            skew = skewness(samples);
            kurt = kurtosis(samples);

            r = pearsrnd(mu,sigma,skew,kurt,1e5,1);

            if all(r>0)
                p_vals = prctile(r, percentiles);
                Cp90(end+1) = p_vals(1);
            end
        catch
        end
    end

    %% -------- Confidence interval --------
    C_low  = Cp90 - alpha * std(Cp90,'omitnan');
    C_high = Cp90 + alpha * std(Cp90,'omitnan');

    L_low  = Lp90 - alpha * std(Lp90,'omitnan');
    L_high = Lp90 + alpha * std(Lp90,'omitnan');



    % C_low  = Cp90 .* (1 - alpha);
    % C_high = Cp90 .* (1 + alpha);
    % 
    % L_low  = Lp90 .* (1 - alpha);
    % L_high = Lp90 .* (1 - alpha);


    %% -------- Coverage Probability --------
    CP_C90(a) = sum((C_low <= p90) & (p90 <= C_high)) / length(Cp90);
    CP_L90(a) = sum((L_low <= p90) & (p90 <= L_high)) / length(Lp90);

end

%% -------- Plot --------
figure;
plot(alpha_list, CP_C90, '-o', 'Color', 'k', 'LineWidth', 1, ...
     'MarkerFaceColor', 'k'); 
hold on;

plot(alpha_list, CP_L90, '--s', 'Color', 'k', 'LineWidth', 1, ...
     'MarkerFaceColor', 'w'); % white fill for contrast

xlabel('\alpha (scaling factor)','FontSize',10,'FontWeight','bold','FontName','Times');
ylabel('Coverage Probability (P_{90})','FontSize',10,'FontWeight','bold','FontName','Times');
legend('C-moment','L-moment','Location','best');
% title('Sensitivity of Coverage Probability vs \alpha (Nf 1.371GPa)');

% Save high-res PNG (600 DPI)
exportgraphics(gcf, "SensitivityAlpha.png", 'Resolution', 600, 'BackgroundColor', 'white');
