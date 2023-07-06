
function myReturn = STEP4_EPOCHING(save_path,subject_list,paradigm,epoch_min,epoch_max,baseline_min,baseline_max,...
    n_bins,binlist_location,volt_thresh);
myReturn='';

% ---------------------------------------------------------------------------------------------------
% STEP 4: Delete noisy epochs, create ERPs, record how much data was
% deleted
%---------------------------------------------------------------------------------------------------
% Reset the data path with the processed data, which should be the previous save folder
home_path  = [save_path,'\AfterStep3_ICA'];

% Location of binlist.txt
epoch_time = [epoch_min epoch_max];
baseline_time = [baseline_min baseline_max];

% Pre-define array (to record how much data is being deleted)
participant_info=[];
participant_info_temp = string(zeros(length(subject_list), n_bins+3)); % pre-allocating space for speed

% Loop through subjects
for s=1:length(subject_list)

    % reset participant info for each loop
    clear data_subj

    fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});

    % Path to the folder containing the current subject's data
    data_path  = [home_path '\' subject_list{s} '\'];

    % Load original dataset
    EEG = pop_loadset('filename', [subject_list{s} '_reref.set'], 'filepath', data_path);

    % epoching
    EEG = eeg_checkset( EEG );
    EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' } );
    EEG = eeg_checkset( EEG );
    EEG  = pop_binlister( EEG , 'BDF', [binlist_location '\binlist.txt'], 'IndexEL',  1, 'SendEL2', 'EEG', 'Voutput', 'EEG' );
    EEG = eeg_checkset( EEG );
    EEG = pop_epochbin( EEG , epoch_time,  baseline_time); %epoch size and baseline size
    EEG = eeg_checkset( EEG );

    num_events = size(EEG.event,2);
    num_epochs = size(EEG.epoch,2);
    % deleting bad epochs
    EEG = pop_artmwppth( EEG , 'Channel', 1:EEG.nbchan, 'Flag',  1, 'Threshold',  volt_thresh, 'Twindow', epoch_time, 'Windowsize',  200, 'Windowstep',  200 );% to flag bad epochs
    percent_deleted = (length(nonzeros(EEG.reject.rejmanual))/(length(EEG.reject.rejmanual)))*100; %looks for the length of all the epochs that should be deleted / length of all epochs * 100
    EEG = pop_rejepoch( EEG, [EEG.reject.rejmanual] ,0);%this deletes the flaged epoches

    % creating ERPS
    ERP = pop_averager( EEG , 'Criterion', 1, 'DSindex',1, 'ExcludeBoundary', 'on', 'SEM', 'on' );

    % save files
    subject_save_path = [save_path,'\AfterStep4_Epoching_',num2str(volt_thresh),filesep,subject_list{s}];
    mkdir(subject_save_path)
    % ERP = pop_savemyerp(ERP, 'erpname', [subject_list{s} '_' name_epoch{bin_n} '.erp'], 'filename', [subject_list{s} '.erp'], 'filepath', save_path);
    EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_epoched.set'],'filepath', subject_save_path);

    % save subject ID, % deleted, % accepted for each participant
    ID                         = string(subject_list{s});
    data_subj                  = [percent_deleted, ERP.ntrials.accepted,num_epochs,num_events]; %ERP.ntrials.accepted  gives all the trials per bin
    participant_info_temp(s,:) = data_subj;
end

% append amount of data deleted, number of trials within bins for each subject
colNames                   = ['data deleted' , strcat('Amount of trials-',ERP.bindescr),'total_epochs','total_events']; %adding names for columns [ERP.bindescr] adds all the name of the bins
participant_info_b = array2table( participant_info_temp,'VariableNames',colNames); %creating table with column names
participant_info= [participant_info, participant_info_b];
total_deleted = str2double(participant_info{:,1:2:end}); participant_info.subject=subject_list';  participant_info.total_deleted = sum(total_deleted,2);
new_save_path = [save_path, '\AfterStep4_Epoching_', num2str(volt_thresh),'\']; mkdir(new_save_path)
save([new_save_path paradigm '_participant_epoching_cleaning_' volt_thresh], 'participant_info');

fprintf('_____FINISHED STEP 4!');