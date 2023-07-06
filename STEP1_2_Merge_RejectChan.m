

function myReturn = STEP1_2_Merge_RejectChan(subject_list,load_path,save_path,rem_intervals,...
    high_pass_filter,low_pass_filter,rem_channels_manually,channels_to_rem,downsampling_rate,rej_low_SD,rej_high_SD);
myReturn='';

% ---------------------------------------------------------------------------------------------------
% STEP 1: Set channel locations & merge datasets (if >1 bdf file)
% STEP 2: Automatically reject channel locations
%---------------------------------------------------------------------------------------------------


% Loop through each subject
for j = 1:length(subject_list)
    subjectID = convertStringsToChars(string(subject_list{j}));
    fprintf('___Processing ID: %s\n',subjectID);
    subject_load_path = convertStringsToChars(append(load_path,filesep,subjectID,filesep));
    subject_save_path = convertStringsToChars(append(save_path,filesep,'AfterSteps1and2_forVisualInspection',filesep,subjectID,filesep)); mkdir(subject_save_path);


    % =============================================
    % STEP 1
    % =============================================

    % List all the session files for this subject
    disp(subject_load_path)
    files = dir([subject_load_path,'*.bdf']);

    % Loop through each session file
    for k = 1:length(files)
        fprintf('___File: %s\n',files(k).name);
        % import files into EEGlab
        EEG = pop_biosig([subject_load_path,files(k).name]);

        EEG = setChanLocs(EEG); % Set channel locations
        EEG.data = double(EEG.data);

        % Merge data across sessions
        if k == 1
            temp_set = EEG;
        else
            new_set = EEG;
            temp_set = pop_mergeset(temp_set, new_set, 1);
        end
    end

    % Apply further processing
    EEG = temp_set; clear temp_set new_set

    if rem_intervals
        EEG = removeIntervals(EEG, subjectID, save_path); % Remove data during breaks
    else
        disp('Not removing intervals!');
    end



    % =============================================
    % STEP 2
    % =============================================

    % Downsample the data if needed
    EEG = pop_resample(EEG, downsampling_rate); % Resample data

    % High pass filter to remove slow drifts (below 0.01 Hz)
    % Low pass filter to remove high frequency noise (above 45 Hz)
    EEG = pop_eegfiltnew(EEG, high_pass_filter, low_pass_filter, [], 0, [], 0);

    % Remove unnecessary channels, ensure these channels match with your dataset
    if rem_channels_manually
        EEG = pop_select(EEG,'nochannel',channels_to_rem);
    else
        disp('Not removing channels manually')
    end

    % Reject channels based on their spectrum, it rejects channels whose spectrum is above 3 standard deviations from the mean
    EEG = pop_rejchan(EEG, 'elec',[1:EEG.nbchan],'threshold',[rej_low_SD rej_high_SD],'norm','on','measure','spec','freqrange',[1 45]);

    % Save the cleaned dataset
    pop_saveset(EEG, 'filename', subjectID , 'filepath', subject_save_path);

end

close all

fprintf('_____FINISHED STEP 1 & 2!');
% Note: after this step, conduct a visual inspection to identify and remove significant bad regions if they exist. Reject unplugged, non-functional, or fully flat channels

