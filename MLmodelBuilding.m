clear;
clc
rng(42);
Folder =Folder Name; 
addpath(Folder)
CaseNames = [ CaseNmae];


% Color-blind-safe palette
colBlue = [0 114 178] / 255;
colRed  = [213 94  0] / 255;
colGray = 0.2 * [1 1 1];

for kk = 1:length(CaseNames)
    KK = CaseNames(kk);
    load(Folder+"MLData" + KK + ".mat");  % must contain T_N90, T_N95

    Classes = {'C90','C95'};
    cases   = {T_N90, T_N95};

    for i = 1:numel(cases)
        C = cases{i};

        % ----------------------- Labels -----------------------
        % C.Cmom_Succ: 1 = valid, 0 = failure
        % Use failure as POSITIVE = 1 for ROC/PR consistency.
        Ysucc = C.Lmom_Succ;           % 1=valid, 0=failure
        Y_fail     = 1 - Ysucc;             % 1=failure (positive), 0=valid (negative)
        X     = [C.N, C.t3, C.t4];

        % Sanity check: both classes present
        if numel(unique(Y_fail)) < 2
            warning('Case %s | %s has a single class. Skipping.', KK, Classes{i});
            continue;
        end

        % ----------------- Class weights (balanced) -----------------
        % Given Nok=16 (valid) and Nfail=384 (failure),
        % minority is VALID (Y==0). Up-weight VALID to prevent collapse.
        Nfail = sum(Ysucc == 0);
        Nok   = sum(Ysucc == 1);
        w_valid =Nok  / max(Nfail, 1);     % 384/16 = 24 in your case

        obsWeights = ones(size(Ysucc));
        obsWeights(Ysucc == 0) = w_valid;      % up-weight VALID (minority)

        % ---------------- Stratified 5-fold CV ----------------
        K  = 5;
        cv = cvpartition(Y_fail, 'KFold', K);

        % Storage
        allScores = [];   % P(failure)
        allTrue   = [];

        % ----------------- CV train & score -------------------
        for k = 1:K
            tr = training(cv, k);
            te = test(cv, k);

            Xtrain = X(tr,:);  Ytrain = Ysucc(tr);  Wtrain = obsWeights(tr);
            Xtest  = X(te,:);  Ytest  = Ysucc(te);

            % Logistic regression (positive=1=failure)
            mdl = fitclinear(Xtrain, Ytrain, ...
                'Learner','logistic', ...
                'ClassNames',[0 1], ...
                'Weights',Wtrain);

            % Scores: probability for positive class (failure)
            [~, score] = predict(mdl, Xtest);
            P_fail = score(:,2);

            allScores = [allScores; P_fail];
            allTrue   = [allTrue;   Ytest];
        end

        % ---------------- ROC & PR (failure is positive=1) ----------------
        [fpr, tpr, thrROC, AUCroc] = perfcurve(allTrue, allScores, 1);
        [reca, prec, thrPR, AUCpr] = perfcurve(allTrue, allScores, 1, ...
            'xCrit','reca','yCrit','prec');

        pos_rate = mean(allTrue == 1);   % PR baseline = prevalence of failure

        fprintf('\n=== %s | %s ===\n', KK, Classes{i});
        fprintf('Class counts: valid=%d, failure=%d\n', Nok, Nfail);
        fprintf('ROC-AUC (failure): %.3f\n', AUCroc);
        fprintf('PR-AUC  (failure): %.3f (baseline=%.3f)\n', AUCpr, pos_rate);

        % --------------- Cost-based threshold selection ---------------
        % Penalize missed failures more than false alarms
        C_FN_fail = 5;   % miss a failure (FN)
        C_FP_fail = 1;   % false alarm (FP)

        thrGrid = thrROC(isfinite(thrROC));
        thrGrid = unique([thrGrid; 0; 1]);

        bestThr  = 0.5;
        bestLoss = inf;

        for t = thrGrid(:)'
            yhat = double(allScores >= t);        % 1=failure, 0=valid
            cm = confusionmat(allTrue, yhat);     % [TN FP; FN TP]
            if numel(cm) < 4, cm = [cm(1), 0; 0, cm(2)]; end

            TN = cm(1,1); FP = cm(1,2);
            FN = cm(2,1); TP = cm(2,2);

            total = TN + FP + FN + TP;
            loss  = (C_FP_fail*FP + C_FN_fail*FN) / max(total,1);

            if loss < bestLoss
                bestLoss = loss;
                bestThr  = t;
            end
        end

        % Conservative cap for safety
        t_chosen = min(bestThr);% 0.20

        % ---------------- Final metrics at chosen threshold ----------------
        yhat = double(allScores >= t_chosen);
        cm = confusionmat(allTrue, yhat);         % [TN FP; FN TP]
        if numel(cm) < 4, cm = [cm(1), 0; 0, cm(2)]; end

        TN = cm(1,1); FP = cm(1,2);
        FN = cm(2,1); TP = cm(2,2);

        % Failure-side (positive) metrics
        prec_fail   = TP / max(TP + FP, 1);
        recall_fail = TP / max(TP + FN, 1);
        f1_fail     = 2 * prec_fail * recall_fail / max(prec_fail + recall_fail, eps);

        % Valid-side (negative) metrics
        specificity = TN / max(TN + FP, 1);
        npv_valid   = TN / max(TN + FN, 1);

        fprintf('Cost-optimal threshold: %.3f (loss=%.3f), chosen: %.3f\n', bestThr, bestLoss, t_chosen);
        fprintf('Confusion matrix [TN FP; FN TP]:\n'); disp(cm);
        fprintf('Failure (pos): Precision=%.3f Recall=%.3f F1=%.3f\n', prec_fail, recall_fail, f1_fail);
        fprintf('Valid (neg):  Specificity=%.3f NPV=%.3f\n', specificity, npv_valid);

        % Point to mark on ROC
        TPR_chosen = recall_fail;
        FPR_chosen = FP / max(FP + TN, 1);

        % % ---------------- Figure: ROC (step) ----------------
        % fig1 = figure('Color','w','Position',[100 100 620 480]);
        % stairs(fpr, tpr, 'Color', 'k', 'LineWidth', 2); hold on;
        % plot([0 1],[0 1],':','Color',colGray,'LineWidth',1);
        % plot(FPR_chosen, TPR_chosen, 'o', 'MarkerSize', 10, ...
        %      'MarkerFaceColor', colBlue, 'MarkerEdgeColor', colBlue);
        % grid on; set(gca,'FontSize',12,'LineWidth',1);
        % xlabel('False Positive Rate');
        % ylabel('True Positive Rate');
        % title(sprintf('ROC (AUC = %.3f)', AUCroc));
        % legend({'ROC (step)','Chance','Chosen threshold'}, 'Location','southeast');
        % outROC = fullfile(Folder, sprintf('ROC_%s_%s.png', KK, Classes{i}));
        % exportgraphics(fig1, outROC, 'Resolution', 300);
        % 
        % % ---------------- Figure: Precision–Recall (step + baseline) ----------------
        % fig2 = figure('Color','w','Position',[100 100 620 480]);
        % stairs(reca, prec, 'Color', 'k', 'LineWidth', 2); hold on;
        % yline(pos_rate, '--', sprintf('Baseline \\pi = %.3f', pos_rate), ...
        %       'Color', colBlue, 'LabelHorizontalAlignment','left', 'LabelVerticalAlignment','middle');
        % plot(recall_fail, prec_fail, 'o', 'MarkerSize', 10, ...
        %      'MarkerFaceColor', colBlue, 'MarkerEdgeColor', colBlue);
        % grid on; set(gca,'FontSize',12,'LineWidth',1);
        % xlabel('Recall');
        % ylabel('Precision');
        % title(sprintf('Precision–Recall (AUC = %.3f)', AUCpr));
        % legend({'PR (step)','Baseline','Chosen threshold'}, 'Location','northwest');
        % outPR = fullfile(Folder, sprintf('PR_%s_%s.png', KK, Classes{i}));
        % exportgraphics(fig2, outPR, 'Resolution', 300);
        % 
        % % ---------------- Persist results ----------------
        % results = struct();
        % 
        % results.mdl = mdl;              % save final trained model
        % 
        % results.class_counts = struct('valid', Nok, 'failure', Nfail);
        % results.AUCroc = AUCroc;
        % results.AUCpr  = AUCpr;
        % results.baseline = pos_rate;      % failure prevalence
        % results.bestThr  = bestThr;
        % results.bestLoss = bestLoss;
        % results.t_chosen = t_chosen;
        % results.cm       = cm;
        % results.metrics  = struct( ...
        %     'precision_fail',prec_fail, 'recall_fail',recall_fail, 'f1_fail',f1_fail, ...
        %     'specificity',specificity, 'npv_valid',npv_valid );
        % results.curves   = struct('fpr',fpr,'tpr',tpr,'reca',reca,'prec',prec);
        % 
        % save(fullfile(Folder, sprintf('%s_%s_results.mat', KK, Classes{i})), 'results');
    end
end


