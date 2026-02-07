Probabilistic Fatigue Life Assessment & Machine Learning Pipeline
This repository provides a MATLAB-based framework for generating Probabilistic S-N (PSN) curves, performing parameter estimation via L-moments, and building Machine Learning classifiers for fatigue life prediction in composite materials.

🛠️ Project Architecture
The project is organized into four distinct functional modules:

1. PSN Generation & Statistical Analysis
This module handles the core probabilistic modeling, focusing on distribution identification and parameter estimation.

Identify_dist.m: Analyzes data to determine the best-fit statistical distribution.

Parameter_estimation.m & parameter_identify.m: Estimating distribution parameters (e.g., Weibull or Lognormal).

lmom.m: Implements L-moments for robust parameter estimation, which is often more stable than maximum likelihood for small datasets.

lhsgeneral.m: Performs Latin Hypercube Sampling (LHS) for efficient probabilistic sampling.

LegendreShiftPoly.m: Utilizes Shifted Legendre Polynomials for surrogate modeling or expansion.

2. Dataset Management
Datasetgeneration.m: Generates synthetic datasets to augment experimental data or test model sensitivity.

MLData.m: Handles feature selection and prepares raw data into a format suitable for training ML models.

3. Machine Learning & Classification
MLmodelBuilding.m: The primary script for training, validating, and testing ML classifiers to predict fatigue performance or failure modes.

4. Visualization
Boxplot.m & BoxPlotting.m: Specialized scripts for generating boxplots to visualize data spread, outliers, and the uncertainty in fatigue life predictions.

📊 Methodology
The pipeline follows a standard probabilistic engineering workflow:

Data Acquisition: Experimental data is sourced from literature (see References).

Stochastic Modeling: Distribution parameters are estimated using L-moments (lmom.m) to account for the inherent scatter in fatigue data.

Feature Engineering: Relevant features are selected and pre-processed via MLData.m.

Model Training: A classifier is built to predict fatigue life categories or reliability levels.

Validation: Performance is evaluated against synthetic samples generated through Latin Hypercube Sampling.

📚 References & Data Sources
The experimental datasets used to validate these models are derived from the following landmark studies in composite fatigue:

Carbon/Epoxy Laminates: Kang, K.W., Lim, D.M., Kim, J.K. "Probabilistic analysis for the fatigue life of carbon/epoxy laminates." Composite Structures 85.3 (2008): 258-264.

LCF Life Assessment: Li, D., Hu, D., Wang, R., Ma, Q., Liu, H. "A non-local approach for probabilistic assessment of lcf life based on optimized effective-damage-parameter." Engineering Fracture Mechanics 199 (2018): 188-200.
