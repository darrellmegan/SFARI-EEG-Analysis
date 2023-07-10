
function myReturn = STEP5_TopoMovies(save_path,subject_list,conditions,streams);
myReturn='';

%% ---------------------------------------------------------------------------------------------------
% TOPO MAP

% plot FFT by individual (for channels of interest)
% plot FFT by group (for channels of interest)
% plot Welch freq by group (for channels of interest)
%---------------------------------------------------------------------------------------------------

% Path to the parent folder, which contains the data folders for all subjects
home_path  = [save_path '\AfterStep5_ERPAnalysis\'];
fig_path = [save_path '\Figures\TopoMap\']; mkdir(fig_path);
ind_fig_path = [fig_path '\Individual\']; mkdir(ind_fig_path);


%Loop through all subjects


for s=1:length(subject_list)

    fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
    data_path  = [home_path subject_list{s} '\'];

    for condition_count = 1:length(conditions)
        % separating epochs
        myFileName = [data_path subject_list{s} '_' char(streams(condition_count)) '_std.set'];
        % value of 2 indicates file exists at this location
        if exist(myFileName, 'file')==2
            EEG = pop_loadset('filename',[subject_list{s} '_' char(streams(condition_count)) '_std.set'], 'filepath', data_path);



            % Simple 2-D movie

            % Above, convert latencies in ms to data point indices
            pnts1 = round(eeg_lat2point(-100/1000, 1, EEG.srate, [EEG.xmin EEG.xmax]));
            pnts2 = round(eeg_lat2point( 600/1000, 1, EEG.srate, [EEG.xmin EEG.xmax]));
            scalpERP = mean(EEG.data(:,pnts1:pnts2),3);

            % Smooth data
            for iChan = 1:size(scalpERP,1)
                scalpERP(iChan,:) = conv(scalpERP(iChan,:) ,ones(1,5)/5, 'same');
            end

            % 2-D movie
            figure; [Movie,Colormap] = eegmovie(scalpERP, EEG.srate, EEG.chanlocs, 'framenum', 'off', 'vert', 0, 'startsec', -0.1, 'topoplotopt', {'numcontour' 0});

            % save movie
            vidObj = VideoWriter([ind_fig_path subject_list{s} '_' char(streams(condition_count)) '_topomovie.mp4'], 'MPEG-4');
            open(vidObj);
            title([subject_list{s} ': ' char(streams(condition_count)) 'Hz']);

            writeVideo(vidObj, Movie);
            close(vidObj);
            close all;
        end
    end

end


