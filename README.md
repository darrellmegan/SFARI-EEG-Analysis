# SFARI-EEG-Analysis
EEG processing & analysis of SFARI paradigms (ASD vs. controls)
***
## [Main script](EEG-processing-steps\Processing_EEGdata_template.m)
Loops through various paradigms in SFARI protocol to process EEG data (in BDF files)

### 1.  [Reads in variables](EEG-processing-steps\set_variables.m), given threshold values in [variable excel](EEG-processing-steps\variables_per_paradigm.xlsx)
### 2.  Define [list of subjects](EEG-processing-steps\define_subjects.m) for analysis & set groups
### 3.  [Merge subjects, downsample, set low & high-pass filters, and remove channels](EEG-processing-steps\STEP1_2_Merge_RejectChan.m) 
- Filtering values & voltage thresholds are pre-defined in [variable excel](EEG-processing-steps\variables_per_paradigm.xlsx)
### 4.  [ICA](EEG-processing-steps\STEP3_ICA.m) (by runica EEGLab function)
### 5.  [Create ERPs](EEG-processing-steps\STEP4_EPOCHING.m) by epoching data & removing noisy trials
### 6.  ERP Analysis
- Individual analyses
  - [Save individual ERP datasets](EEG-processing-steps\STEP5_ERPanalysis_createERPdatasets.m) to drive (required for plotting)
  - [Plot individual ERPs](EEG-processing-steps\STEP5_ERPanalysis_plotChannelsbyIndividual.m) (on a per-participant basis, separated by channels of interest)
- Group analyses
  - [Save group ERP datasets](EEG-processing-steps\STEP5_ERPanalysis_make_groupERP_matrix.m) to drive (required for plotting)
  - [Plot group ERPs](EEG-processing-steps\STEP5_ERPanalysis_plotChannelsbyGroup.m) (on a per-group basis, separated by channels of interest)
### 7.  [Frequency Analysis](EEG-processing-steps\STEP6_FreqAnalysis.m)
- Individual analyses
  - Plots FFT by individual (for channels of interest)
- Group analyses 
  - Plots FFT by group (for channels of interest)
  - Plots Welch freq by group (for channels of interest) - requires [plotpWelch](plotpWelch.m) script
