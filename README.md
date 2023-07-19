# SFARI-EEG-Analysis
EEG processing & analysis of SFARI paradigms (ASD vs. controls)
***
## [Main script](Processing_EEGdata_template.m)
Loops through various paradigms in SFARI protocol to process EEG data (in BDF files)

### 1.  [Reads in variables](set_variables.m), given threshold values in [variable excel](variables_per_paradigm.xlsx)
### 2.  Define [list of subjects](define_subjects.m) for analysis & set groups
### 3.  [Merge subjects, downsample, set low & high-pass filters, and remove channels](STEP1_2_Merge_RejectChan.m) 
- Filtering values & voltage thresholds are pre-defined in [variable excel](variables_per_paradigm.xlsx)
### 4.  [ICA](STEP3_ICA.m) (by runica EEGLab function)
### 5.  [Create ERPs](STEP4_EPOCHING.m) by epoching data & removing noisy trials
### 6.  ERP Analysis
- Individual analyses
  - [Save individual ERP datasets](STEP5_ERPanalysis_createERPdatasets.m) to drive (required for plotting)
  - [Plot individual ERPs](STEP5_ERPanalysis_plotChannelsbyIndividual.m) (on a per-participant basis, separated by channels of interest)
      - [EXAMPLE: ERP for individual X at Cz channel (40 Hz condition)](ERPs_Cz_40Hz_std_10214.png)
- Produce [topographical map animations](STEP5_TopoMovies.m) by individual
- Group analyses
  - [Save group ERP datasets](STEP5_ERPanalysis_make_groupERP_matrix.m) to drive (required for plotting)
  - [Plot group ERPs](STEP5_ERPanalysis_plotChannelsbyGroup.m) (on a per-group basis, separated by channels of interest)
      - [EXAMPLE: ERPs by group at Cz channel (40 Hz condition)](ASDvsControls_40Hz_Cz.png)
  - Produce [topographical map animations](STEP5_TopoMovies_Group.m) by group to identify channels of interest
      - [EXAMPLE: Topo map for ASD group (40 Hz condition)](ASD_40Hz_topomovie.mp4)
### 7.  [Frequency Analysis](STEP6_FreqAnalysis.m)
- Individual analyses
  - Plots FFT by individual (for channels of interest)
      - [EXAMPLE: FFT for individual X at Cz channel (40 Hz condition)](freq-time_Cz_40Hz_std_10214.png)
- Group analyses 
  - Plots FFT by group (for channels of interest)
      - [EXAMPLE: FFT for ASD group at Cz channel (27 Hz condition)](freq-time-analysis_27Hz_ASD_Cz.png)
  - Plots Welch freq by group (for channels of interest) - requires [plotPwelch](plotPwelch.m) script
      - [EXAMPLE: Welch frequency for ASD group at Cz channel](freq-time-WELCH_ASD_Cz.png)
  - Exports .txt files of power vectors necessary for machine learning classification
### 8.  [Build EEG study](STEP7_buildStudy.m)
- Sets frequency windows of interest for given conditions (for ERP plotting)
- Assigns patients to groups (for ERP plotting by group)
### 9.  [Plot ERPs within frequency windows of interest](STEP8_plotERPs_byWindow.m)
- [EXAMPLE: Group ERPs for Cz channel](ERP_Cz.png)

## [Machine Learning Classification](classifier_linearSVC.py)
Classifies patients as ASD or control by their power spectra bands (as exported in Step 7)
