
function myReturn = STEP5_ERPanalysis_plotChannelsbyGroup(save_path,epoch_min,epoch_max,plotInd);
myReturn='';

% ---------------------------------------------------------------------------------------------------
% STEP 5: plot ERPs by group
%---------------------------------------------------------------------------------------------------

% Path to the parent folder, which contains the data folders for all subjects
home_path = [save_path '\Figures\subj_ERP_matrix\'];
fig_path  = [save_path '\Figures\ERP_analysis\Group\'];mkdir(fig_path);

MyFolderInfo = dir(home_path);
for count = 3:length(MyFolderInfo)
    txt_file = MyFolderInfo(count).name;
    if txt_file(1:3) == 'ASD'

        values = strfind(txt_file,'_');
        myCondition = txt_file(values(1)+1:values(2)-1);
        myChan = txt_file(values(2)+1:values(3)-1);

        ASD_matrix = readmatrix([home_path txt_file]);
        avg_ASD_erp = mean(ASD_matrix,1);

        time_ms = epoch_min:(epoch_max-epoch_min)/length(avg_ASD_erp):epoch_max-(epoch_max-epoch_min)/length(avg_ASD_erp);


        hold on

        if plotInd
            num_dim = size(ASD_matrix);
            num_patients = num_dim(1);
            for count = 1:num_patients
                plot(time_ms,ASD_matrix(count,:),color=[1,0.85,0.85]);
                hold on
            end

        end


        control_txt_file = ['control' txt_file(4:length(txt_file))];
        control_matrix = readmatrix([home_path control_txt_file]);
        avg_erp = mean(control_matrix,1);


        if plotInd
            num_dim = size(control_matrix);
            num_patients = num_dim(1);
            for count = 1:num_patients
                plot(time_ms,control_matrix(count,:),color=[0.85,0.85,0.85]);
                hold on
            end
            plot(time_ms,avg_ASD_erp,'r'); xline(0,'--k');
            hold on
            plot(time_ms,avg_erp,'k');title(['ASD vs. Controls: ' myCondition 'Hz - Channel ' myChan]);legend('ASD','','controls');

            print([fig_path 'ASDvsControls_individuals_' myCondition 'Hz_' myChan], '-dpng' ,'-r300');

        else
            plot(time_ms,avg_ASD_erp,'r'); xline(0,'--k');

            hold on
            plot(time_ms,avg_erp,'k');title(['ASD vs. Controls: ' myCondition 'Hz - Channel ' myChan]);legend('','','ASD','','controls');

            print([fig_path 'ASDvsControls_' myCondition 'Hz_' myChan], '-dpng' ,'-r300');

        end
        close all
    end

end

