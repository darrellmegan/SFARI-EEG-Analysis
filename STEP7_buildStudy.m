
function myReturn = STEP7_buildStudy(save_path,extr_high_pass_filter_cond1,extr_high_pass_filter_cond2,extr_low_pass_filter_cond1,extr_low_pass_filter_cond2,...
    subject_list,conditions,streams,paradigm,ALLEEG,STUDY);
myReturn='';


data_path = [save_path '\AfterStep5_ERPAnalysis\'];
study_save = [save_path '\AfterStep7_BuildStudy\']; mkdir(study_save);

% building a study
for s=1:length(subject_list)
    fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
    subj_data_path  = [data_path '\' subject_list{s} '\'];

    for count = 1:length(conditions)
        % separating epochs
        myFileName = [subj_data_path subject_list{s} '_' char(streams(count)) '_std.set'];
        % value of 2 indicates file exists at this location

        if strcmp(char(streams(count)), '40')
            highpass_filter = extr_high_pass_filter_cond1;
            lowpass_filter = extr_low_pass_filter_cond1;
        else
            highpass_filter = extr_high_pass_filter_cond2;
            lowpass_filter = extr_low_pass_filter_cond2;
        end

        if exist(myFileName, 'file')==2

            EEG = pop_loadset('filename',[subject_list{s} '_' char(streams(count)) '_std.set'], 'filepath', subj_data_path);
            EEG = pop_eegfiltnew(EEG, 'locutoff',highpass_filter,'plotfreqz',1);
            EEG = pop_eegfiltnew(EEG, 'hicutoff',lowpass_filter,'plotfreqz',1);
            EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_' char(streams(count)) '_std_erp.set'],'filepath', study_save);%save
            close all

        end
    end

end
% Obtain all .set file under /data/makoto/exampleProject/.
% In this example, suppose all set files have names like subj123_group2.set
allSetFiles = dir([study_save filesep '*.set']); % filesep inserts / or \ depending on your OS.
study_name = [paradigm '_std.study'];
% Start the loop.

eeglab redraw % This is to update EEGLAB GUI so that you can build STUDY from GUI menu.

for setIdx = 1:length(allSetFiles)
    
    % Obtain the file names for loading.
    loadName = allSetFiles(setIdx).name; % subj123_group2.set
    dataName = loadName(1:end-4);        % subj123_group2
    
    % Load data. Note that 'loadmode', 'info' is to avoid loading .fdt file to save time and RAM.
    EEG = pop_loadset('filename', loadName, 'filepath', study_save, 'loadmode', 'info');
    
    underscore_indices = strfind(dataName,'_'); 

    % Enter EEG.subjuct.
    EEG.subject = dataName(1:underscore_indices(1)-1); % is the 5 numbers of the id 12000
    
    % Enter EEG.condition.
    EEG.condition = dataName(underscore_indices(1)+1:underscore_indices(3)-1); % 21_std
    
    if strcmp(dataName(1:2),'10')
        %pt is a control
        EEG.group = 'control';
    else
        EEG.group = 'ASD';
    end

    % Store the current EEG to ALLEEG.
    [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 0);
end
[STUDY ALLEEG] = std_editset( STUDY, ALLEEG, 'name',paradigm,'updatedat','on','rmclust','off' );
[STUDY ALLEEG] = std_checkset(STUDY, ALLEEG);
CURRENTSTUDY = 1; EEG = ALLEEG; CURRENTSET = [1:length(EEG)];
[STUDY EEG] = pop_savestudy( STUDY, EEG, 'filename',study_name,'filepath',study_save);




