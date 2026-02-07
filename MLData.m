clear;
% Cases = {Nf_1_633GPa, Nf_1_552GPa, Nf_1_452GPa, Nf_1_371GPa, Nf_0_980GPa, Nf_0_949GPa, Nf_0_928GPa};
CasesNN = {"Nf_1_371GPa"};
% N_list = [5,7,9,11];
Folder = "C:\Users\jayard4\OneDrive - Caterpillar\Research\Probabilistic SN\UQ-main\results\";
rng(5)

for j  = 1:length(CasesNN)
    C = CasesNN{j};

    load(Folder+C+"test.mat")%


    % Build two tables:
    %  - T_N90: Cmom_failure based on CP_90 and NNV (NNV==0 means FAIL)
    %  - T_N95: Cmom_failure based on CP_95 and NNV (NNV==0 means FAIL)

    Ns = [5, 7, 9, 11];
    T_N90 = table();
    T_N95 = table();


for n = Ns
        % --- Select variables for this N ---
        switch n
            case 5
                R = randi([1 100], 50, 1);
                t3   = T3_5(R);      % scalar or vector
                t4   = T4_5(R);      % scalar or vector
                nnv  = NNV_5_L(R);     % vector (0=FAIL, 1=PASS)  <-- updated meaning
                cp90 = LP_90_5(R);   % vector/logical (1=PASS, 0=FAIL)
                cp95 = LP_95_5(R);   % vector/logical (1=PASS, 0=FAIL)

            case 7
                R = randi([1 100], 50, 1);
                t3   = T3_7(R);
                t4   = T4_7(R);
                nnv  = NNV_7_L(R);
                cp90 = LP_90_7(R);
                cp95 = LP_95_7(R);

            case 9
                R = randi([1 100], 50, 1);
                t3   = T3_9(R);
                t4   = T4_9(R);
                nnv  = NNV_9_L(R);
                cp90 = LP_90_9(R);
                cp95 = LP_95_9(R);

            case 11
                R = randi([1 100], 50, 1);
                t3   = T3_11(R);
                t4   = T4_11(R);
                nnv  = NNV_11_L(R);
                cp90 = LP_90_11(R);
                cp95 = LP_95_11(R);

            otherwise
                error('Unsupported N = %d', n);
        end

        % --- Normalize shapes to column vectors ---
        nnv  = nnv(:);
        cp90 = cp90(:);
        cp95 = cp95(:);

        rows = numel(nnv);
        if numel(cp90) ~= rows || numel(cp95) ~= rows
            error('Length mismatch for N=%d: NNV(%d), CP_90(%d), CP_95(%d)', ...
                n, numel(nnv), numel(cp90), numel(cp95));
        end

        % Expand t3/t4 if needed
        if isscalar(t3),  t3_col  = repmat(t3,  rows, 1); else, t3_col  = t3(:);  end
        if isscalar(t4),  t4_col  = repmat(t4,  rows, 1); else, t4_col  = t4(:);  end
        if numel(t3_col) ~= rows || numel(t4_col) ~= rows
            error('t3/t4 length mismatch for N=%d.', n);
        end

        % --- Compute Common Failure flags (using new NNV rule) ---
        % N90: fail if NNV==0 OR CP_90==0
        cmom90 = (nnv == 1) & (cp90==1);
        % N95: fail if NNV==0 OR CP_95==0
        cmom95 = (nnv == 1) & (cp95==1);

        % --- Assemble rows for each table ---
        T90_n = table( ...
            repmat(n, rows, 1), ...
            t3_col, ...
            t4_col, ...
            nnv, ...
            cp90,...
            cmom90, ...
            'VariableNames', {'N','t3','t4','NNV','CP_90','Lmom_Succ'});

        T95_n = table( ...
            repmat(n, rows, 1), ...
            t3_col, ...
            t4_col, ...
            nnv, ...
            cp95, ...
            cmom95, ...
            'VariableNames', {'N','t3','t4','NNV','CP_95','Lmom_Succ'});

        % --- Accumulate ---
        T_N90 = [T_N90; T90_n]; %#ok<AGROW>
        T_N95 = [T_N95; T95_n]; %#ok<AGROW>


        T_N90.Lmom_Succ = double(T_N90.Lmom_Succ); % Lmom succ
        T_N95.Lmom_Succ = double(T_N95.Lmom_Succ);

    end

    save (Folder+"MLData_test"+C+".mat", 'T_N90', 'T_N95');%
end


