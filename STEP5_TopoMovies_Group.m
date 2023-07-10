
function myReturn = STEP5_TopoMovies_Group(save_path,subject_list,conditions,streams,downsampling_rate,epoch_min,epoch_max);
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
group_fig_path = [fig_path '\Group\']; mkdir(group_fig_path);

chan_64={'FP1','AF7','AF3','F1','F3','F5','F7','FT7','FC5','FC3'...
    'FC1','C1','C3','C5','T7','TP7','CP5','CP3','CP1','P1','P3'...
    'P5','P7','P9','PO7','PO3','O1','Iz','Oz','POz','Pz','CPz'...
    'FPz','FP2','AF8','AF4','AFz','Fz','F2','F4','F6','F8','FT8'...
    'FC6','FC4','FC2','FCz','Cz','C2','C4','C6','T8','TP8','CP6'...
    'CP4','CP2','P2','P4','P6','P8','P10','PO8','PO4','O2'};

%Loop through all subjects

concat_40_ASD=[];concat_27_ASD=[];
concat_40_control=[];concat_27_control=[];

for s=1:length(subject_list)

    fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
    data_path  = [home_path subject_list{s} '\'];

    for condition_count = 1:length(conditions)
        % separating epochs
        myFileName = [data_path subject_list{s} '_' char(streams(condition_count)) '_std.set'];
        % value of 2 indicates file exists at this location
        if exist(myFileName, 'file')==2
            EEG = pop_loadset('filename',[subject_list{s} '_' char(streams(condition_count)) '_std.set'], 'filepath', data_path);
            if length(EEG.chanlocs) ~= 64
                list_chan={};
                for nchan =1:length(EEG.chanlocs)
                    list_chan=[list_chan EEG.chanlocs(nchan).labels];
                end
                [missing_chan, index] = setdiff(chan_64,list_chan);

                index=sort(index,'ascend');
                for i = 1:length(index)

                    new_index = index(i);
                    if i == 1 && length(index)==1
                        concat_blanks = vertcat(EEG.data(1:new_index-1,:,:), zeros(1,size(EEG.data,2),size(EEG.data,3)));
                    elseif i==1
                        concat_blanks = vertcat(EEG.data(1:new_index-1,:,:), zeros(1,size(EEG.data,2),size(EEG.data,3)));
                        concat_blanks = vertcat(concat_blanks, EEG.data(new_index:index(i+1)-i-1,:,:));

                    elseif i~=1 && i ~=length(index)
                        concat_blanks = vertcat(concat_blanks, zeros(1,size(EEG.data,2),size(EEG.data,3)));
                        concat_blanks = vertcat(concat_blanks, EEG.data(new_index-i+(i-1):index(i+1)-i-(i-1),:,:));
                    else
                        concat_blanks = vertcat(concat_blanks, zeros(1,size(EEG.data,2),size(EEG.data,3)));

                    end
                end
                concat_blanks = vertcat(concat_blanks, EEG.data(new_index+1-(length(index)):size(EEG.data,1),:,:));



                data_to_concat=concat_blanks;
            else
                data_to_concat =  EEG.data(:,:,:);
            end

            if strcmp(subject_list{s}(1:2),'10')
                % pt is a control
                if strcmp(char(streams(condition_count)),'40')
                    concat_40_control = cat(3, concat_40_control,data_to_concat);%data for newtimef function (time freq)

                else
                    concat_27_control = cat(3, concat_27_control,data_to_concat);%data for newtimef function (time freq)

                end

            else
                % pt is in ASD group
                if strcmp(char(streams(condition_count)),'40')
                    concat_40_ASD = cat(3, concat_40_ASD,data_to_concat);%data for newtimef function (time freq)

                else
                    concat_27_ASD = cat(3, concat_27_ASD,data_to_concat);%data for newtimef function (time freq)

                end
            end



        end
    end

end

% Simple 2-D movie

% Above, convert latencies in ms to data point indices
pnts1 = round(eeg_lat2point(-100/1000, 1, downsampling_rate, [epoch_min epoch_max]));
pnts2 = round(eeg_lat2point( 600/1000, 1, downsampling_rate, [epoch_min epoch_max]));
scalpERP = mean(concat_40_ASD(:,pnts1:pnts2),3);

% Smooth data
for iChan = 1:size(scalpERP,1)
    scalpERP(iChan,:) = conv(scalpERP(iChan,:) ,ones(1,5)/5, 'same');
end

% 2-D movie
figure; [Movie,Colormap] = eegmovie(scalpERP, downsampling_rate, EEG.chanlocs, 'framenum', 'off', 'vert', 0, 'startsec', -0.1, 'topoplotopt', {'numcontour' 0});

% save movie
vidObj = VideoWriter([group_fig_path 'ASD_40Hz_topomovie.mp4'], 'MPEG-4');
open(vidObj);
title(['Topo Map for ASD participants: 40 Hz']);

writeVideo(vidObj, Movie);
close(vidObj);
close all;


% Simple 2-D movie

% Above, convert latencies in ms to data point indices
pnts1 = round(eeg_lat2point(-100/1000, 1, downsampling_rate, [epoch_min epoch_max]));
pnts2 = round(eeg_lat2point( 600/1000, 1, downsampling_rate, [epoch_min epoch_max]));
scalpERP = mean(concat_27_ASD(:,pnts1:pnts2),3);

% Smooth data
for iChan = 1:size(scalpERP,1)
    scalpERP(iChan,:) = conv(scalpERP(iChan,:) ,ones(1,5)/5, 'same');
end

% 2-D movie
figure; [Movie,Colormap] = eegmovie(scalpERP, downsampling_rate, EEG.chanlocs, 'framenum', 'off', 'vert', 0, 'startsec', -0.1, 'topoplotopt', {'numcontour' 0});

% save movie
vidObj = VideoWriter([group_fig_path 'ASD_27Hz_topomovie.mp4'], 'MPEG-4');
open(vidObj);
title(['Topo Map for ASD participants: 27 Hz']);

writeVideo(vidObj, Movie);
close(vidObj);
close all;

% Simple 2-D movie

% Above, convert latencies in ms to data point indices
pnts1 = round(eeg_lat2point(-100/1000, 1, downsampling_rate, [epoch_min epoch_max]));
pnts2 = round(eeg_lat2point( 600/1000, 1, downsampling_rate, [epoch_min epoch_max]));
scalpERP = mean(concat_40_control(:,pnts1:pnts2),3);

% Smooth data
for iChan = 1:size(scalpERP,1)
    scalpERP(iChan,:) = conv(scalpERP(iChan,:) ,ones(1,5)/5, 'same');
end

% 2-D movie
figure; [Movie,Colormap] = eegmovie(scalpERP, downsampling_rate, EEG.chanlocs, 'framenum', 'off', 'vert', 0, 'startsec', -0.1, 'topoplotopt', {'numcontour' 0});

% save movie
vidObj = VideoWriter([group_fig_path 'control_40Hz_topomovie.mp4'], 'MPEG-4');
open(vidObj);
title(['Topo Map for control participants: 40 Hz']);

writeVideo(vidObj, Movie);
close(vidObj);
close all;


% Simple 2-D movie

% Above, convert latencies in ms to data point indices
pnts1 = round(eeg_lat2point(-100/1000, 1, downsampling_rate, [epoch_min epoch_max]));
pnts2 = round(eeg_lat2point( 600/1000, 1, downsampling_rate, [epoch_min epoch_max]));
scalpERP = mean(concat_27_control(:,pnts1:pnts2),3);

% Smooth data
for iChan = 1:size(scalpERP,1)
    scalpERP(iChan,:) = conv(scalpERP(iChan,:) ,ones(1,5)/5, 'same');
end

% 2-D movie
figure; [Movie,Colormap] = eegmovie(scalpERP, downsampling_rate, EEG.chanlocs, 'framenum', 'off', 'vert', 0, 'startsec', -0.1, 'topoplotopt', {'numcontour' 0});

% save movie
vidObj = VideoWriter([group_fig_path 'control_27Hz_topomovie.mp4'], 'MPEG-4');
open(vidObj);
title(['Topo Map for control participants: 27 Hz']);

writeVideo(vidObj, Movie);
close(vidObj);
close all;


