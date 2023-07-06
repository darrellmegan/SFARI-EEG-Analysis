
function myReturn = STEP5_ERPanalysis_createERPdatasets(save_path,subject_list,paradigm,volt_thresh,conditions,...
    trials_num_reduced,streams);
myReturn='';
% ---------------------------------------------------------------------------------------------------
% STEP 5: 
    % create EEGLAB structures with epochs of one type
    % reduce # of trials to be same for everyone (by randomly deleting)
%---------------------------------------------------------------------------------------------------

% Path to the parent folder, which contains the data folders for all subjects
home_path  = [save_path '\AfterStep4_Epoching_' num2str(volt_thresh) '\'];
study_save = [save_path '\AfterStep5_ERPAnalysis\']; mkdir(study_save);


colNames = {'subjectID','num_good_epochs','condition'};
part_excluded = [colNames];

%Loop through all subjects
for s=1:length(subject_list)

    fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
    data_path  = [home_path subject_list{s} '\\'];



    for count = 1:length(conditions)
        % separating epochs
        EEG = pop_loadset('filename', [subject_list{s} '_epoched.set'], 'filepath', data_path);

        myCondition = conditions(count);
        type = {EEG.event.type}.';
        Index = find(contains(type,myCondition));
        if length(Index)>0
            % select events for selected condition only
            EEG = pop_selectevent( EEG, 'type',{myCondition},'deleteevents','off','deleteepochs','on','invertepochs','off');
            num_epochs_cond = size(EEG.data,3);
            % if patient has enough trials, otherwise will be excluded
            if num_epochs_cond>trials_num_reduced

                subject_save_path  = [study_save '\' subject_list{s} '\'];mkdir(subject_save_path);

                % randomly select N number of trials per participant
                EEG = pop_select(EEG, 'trial', randsample(1:size(EEG.data,3), trials_num_reduced));
                EEG_std = EEG;
                % save ERPs for condition
                EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_' char(streams(count)) '_std.set'],'filepath', subject_save_path);%save

            else
                disp(' ----------- PATIENT HAS TOO FEW TRIALS & WILL BE EXCLUDED!');
                part_excluded=[part_excluded;{subject_list{s},num2str(num_epochs_cond),string(myCondition)}];
            end
        else
            disp(' ----------- PATIENT HAS TOO FEW TRIALS & WILL BE EXCLUDED!');
            part_excluded=[part_excluded;{subject_list{s},num2str(num_epochs_cond),string(myCondition)}];

        end

    end

end

writecell(part_excluded,[study_save '\' 'particants_excluded_' num2str(volt_thresh) '_threshold.txt']);

fprintf('_____FINISHED STEP 5 (ERP datasets created)!');

