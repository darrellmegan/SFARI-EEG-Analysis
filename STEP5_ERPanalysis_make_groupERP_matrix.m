
function myReturn = STEP5_ERPanalysis_make_groupERP_matrix(save_path,grp_controls,grp_ASD,...
    streams,conditions,chan_of_interest,epoch_min,epoch_max,downsampling_rate);
myReturn='';

% ---------------------------------------------------------------------------------------------------
% STEP 5: create ERP matrix per group
%---------------------------------------------------------------------------------------------------

% Path to the parent folder, which contains the data folders for all subjects
home_path  = [save_path '\AfterStep5_ERPAnalysis\'];

colNames = {'group','condition','channel', 'subject'};
part_excluded = [colNames];

%Loop through all subjects
groups = {grp_controls,grp_ASD};
grp_name = {'control','ASD'};

for group_count = 1:length(groups)
    subject_list = groups{group_count};
    myGrp = grp_name{group_count};

    for condition_count = 1:length(conditions)
        myCondition = streams{condition_count};

        for chan_count = 1:length(chan_of_interest)
         
            subject_matrix = zeros(length(subject_list),(epoch_max-epoch_min)/1000*downsampling_rate);
            for subject_count=1:length(subject_list)
                
                data_path = [home_path subject_list{subject_count} ,'\'];
                % separating epochs
                myFileName = [data_path subject_list{subject_count} '_' char(streams(condition_count)) '_std.set'];
                % value of 2 indicates file exists at this location
                if exist(myFileName, 'file')==2
                    EEG = pop_loadset('filename',[subject_list{subject_count} '_' char(streams(condition_count)) '_std.set'], 'filepath', data_path);

                    myChan = char(chan_of_interest(chan_count));
                    chan_loc = struct2table(EEG.chanlocs).labels;
                    index = find(ismember(chan_loc,myChan));
                    if ~isempty(index)
                        chan_number = EEG.chanlocs(index).urchan;

                        chan=EEG.data(chan_number,:,:);
                        avg_ofchan = mean(chan,3);

                        subject_matrix(subject_count,:) = avg_ofchan;

                                         
                    else
                        part_excluded=[part_excluded;{myGrp,myCondition,myChan,subject_list{subject_count}}];
                    end


                    
                    fprintf(['\n\n\n********************************\n']);
                    fprintf(['--GROUP: ', myGrp, ' ......(', num2str(group_count),' out of ',num2str(length(groups)),')\n']);
                    fprintf(['--CONDITION: ', myCondition, ' Hz ......(', num2str(condition_count),' out of ',num2str(length(conditions)),')\n']);
                    fprintf(['--CHANNEL: ', myChan, ' ........(', num2str(chan_count),' out of ',num2str(length(chan_of_interest)),')\n']);
                    fprintf(['-----Processing subject ', num2str(subject_count),' out of ',num2str(length(subject_list)),'\n']);
                    data_path  = [home_path subject_list{subject_count} '\'];


                    %time_ms = epoch_min:(epoch_max-epoch_min)/length(avg_ofchan):epoch_max-(epoch_max-epoch_min)/length(avg_ofchan);


                end
            end
            mat_save_path = [save_path '\Figures\subj_ERP_matrix\'];mkdir(mat_save_path);
            writematrix(subject_matrix,[mat_save_path myGrp '_' myCondition '_' myChan '_subjectERPs.txt']);
        end
    end
end

writecell(part_excluded,[mat_save_path '\' 'participants_excluded_withoutChan.txt']);


