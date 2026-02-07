# Probabilistic Fatigue Life Assessment using L-Moments and ML

This repository contains a MATLAB-based framework for generating Probabilistic S-N (PSN) curves and utilizing Machine Learning for fatigue life classification. The project integrates statistical parameter estimation with predictive modeling for composite materials.

---

## 🛠️ Project Modules

### 1. PSN Generation & Statistical Analysis
Used for core probabilistic modeling and distribution fitting.
* `Identify_dist.m`: Statistical identification of the best-fit distribution.
* `Parameter_estimation.m` & `parameter_identify.m`: Estimating parameters for life distribution.
* `lmom.m`: Implementation of **L-Moments** for robust parameter estimation.
* `lhsgeneral.m`: Latin Hypercube Sampling for stochastic data generation.
* `LegendreShiftPoly.m`: Shifted Legendre Polynomials for surrogate modeling.

### 2. Classifier Performance & Model Building
* `MLmodelBuilding.m`: Core script for training and evaluating the ML classification models.

### 3. Data Management (Synthetic & Features)
* `Datasetgeneration.m`: Script for generating **Synthetic Datasets**.
* `MLdata.m`: Handles **Feature Selection** and preparation of ML-ready data structures.

### 4. Plotting & Visualization
* `Boxplot.m`: Specialized plotting script to visualize data distribution and fatigue scatter.

---

## 🔬 Methodology

The workflow follows a rigorous engineering approach to handle uncertainty in material fatigue:
1.  **Stochastic Modeling:** Distribution parameters are identified using L-moments to handle small sample sizes effectively.
2.  **Synthetic Augmentation:** Where experimental data is sparse, `Datasetgeneration.m` expands the feature space.
3.  **Classification:** ML models are trained to classify fatigue performance based on the processed features.



---

## 📚 References & Data Sources

The experimental data utilized in this project is based on the following research:

1.  **Kang, K.W., Lim, D.M., Kim, J.K. (2008).** "Probabilistic analysis for the fatigue life of carbon/epoxy laminates." *Composite Structures*, 85(3), 258–264.
2.  **Li, D., Hu, D., Wang, R., Ma, Q., Liu, H. (2018).** "A non-local approach for probabilistic assessment of lcf life based on optimized effective-damage-parameter." *Engineering Fracture Mechanics*, 199, 188–200.

---

## 🚀 Getting Started

1.  Ensure MATLAB is installed with the Statistics and Machine Learning Toolbox.
2.  Run `Parameter_estimation.m` to identify the probabilistic baseline of your dataset.
3.  Use `MLmodelBuilding.m` to execute the classification pipeline.

## 📖 Citation & Research

If you find this code or the associated methodology useful for your research, please cite my work. You can find my full list of publications on **Google Scholar**:

👉 [**Deepan Jayaraman - Google Scholar Profile**](https://scholar.google.com/citations?user=270_P4EAAAAJ&hl=en)

Your citations help support the continued development of open-source engineering tools.
