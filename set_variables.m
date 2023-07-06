
function [load_path,save_path,binlist_location,pts_to_exclude,rem_intervals,downsampling_rate,...
    high_pass_filter,low_pass_filter,rem_channels_manually,channels_to_rem,rej_high_SD,...
    rej_low_SD,refchan_bin,refchan,volt_thresh,buffer,epoch_min,epoch_max,baseline_min,baseline_max,...
    n_bins,max_pwelch_freq,time_freq_frequencies_range,stream1,stream2,streams,conditions,...
    highpass_filter_stream2,lowpass_filter_stream2,highpass_filter_stream1,lowpass_filter_stream1,...
    trials_num_reduced,ERP_top_ref,pwelch_epoch_start,pwelch_epoch_end,chan_of_interest,grp_controls,baseline_start,baseline_end] = set_variables( paradigm, my_data_path, myVar_tab);

%%---------------------------------------------------------------------------------------------------
% SET VARIABLES!
%---------------------------------------------------------------------------------------------------


% Automatically define the rest of the file paths
load_path = [my_data_path, paradigm];

save_path= ['\\data2.einsteinmed.edu\home\cnl-interns-lab\Interns\darrellm\EEG Processing\SFARI\ProcessedData\',paradigm];
%mkdir(save_path) ;  % Make sure your save directory exists
binlist_location = save_path;


%================
% STEPS 1 & 2
%================

[rows,~]=find(myVar_tab.varname==["pts_to_exclude"]); result = myVar_tab(rows,paradigm); myVar = char(result.(1));
tmp =  split(myVar,",");
pts_to_exclude = cell(1,length(tmp));
for pt = 1:length(tmp)
    pts_to_exclude{pt} = char(tmp(pt));
end

% set to 1 if you would like to remove intervals (for breaks in EEG), 0 if not
% need to edit removeIntervals.m if TRUE
[rows,~]=find(myVar_tab.varname==["rem_intervals"]); result = myVar_tab(rows,paradigm); myVar = str2num(char(result.(1)));
rem_intervals = myVar;
[rows,~]=find(myVar_tab.varname==["downsampling_rate"]); result = myVar_tab(rows,paradigm); myVar = str2num(char(result.(1)));
downsampling_rate = myVar;

[rows,~]=find(myVar_tab.varname==["high_pass_filter"]); result = myVar_tab(rows,paradigm); myVar = str2num(char(result.(1)));
high_pass_filter = myVar;
[rows,~]=find(myVar_tab.varname==["low_pass_filter"]); result = myVar_tab(rows,paradigm); myVar = str2num(char(result.(1)));
low_pass_filter = myVar;

% set to 1 if you would like to remove specific channels manually, 0 if not
[rows,~]=find(myVar_tab.varname==["rem_channels_manually"]); result = myVar_tab(rows,paradigm); myVar = str2num(char(result.(1)));
rem_channels_manually = 0;

if rem_channels_manually
    [rows,~]=find(myVar_tab.varname==["channels_to_rem"]); result = myVar_tab(rows,paradigm); myVar = char(result.(1));
    tmp =  split(myVar,",");
    channels_to_rem = cell(1,length(tmp));
    for chan = 1:length(tmp)
        channels_to_rem{chan} = char(tmp(chan));
    end
else
    channels_to_rem = {};
end



% reject channels x SD above or below the mean spectrum
[rows,~]=find(myVar_tab.varname==["rej_high_SD"]); result = myVar_tab(rows,paradigm); myVar = str2num(char(result.(1)));
rej_high_SD = myVar;
[rows,~]=find(myVar_tab.varname==["rej_low_SD"]); result = myVar_tab(rows,paradigm); myVar = str2num(char(result.(1)));
rej_low_SD = myVar;

% if you want to re-reference to a specific channel add the name here (for example {'Cz'} or {'F1' 'F2'))
% leave empty if no re-reference
[rows,~]=find(myVar_tab.varname==["refchan_bin"]); result = myVar_tab(rows,paradigm); myVar = str2num(char(result.(1)));
refchan_bin = myVar;

if refchan_bin
    [rows,~]=find(myVar_tab.varname==["refchan"]); result = myVar_tab(rows,paradigm); myVar = result.(1);
    refchan = myVar;
else
    refchan = { };
end

%================
% STEP 4: EPOCH
%================

% voltage threshold to remove bad epochs
[rows,~]=find(myVar_tab.varname==["volt_thresh"]); result = myVar_tab(rows,paradigm); myVar = str2num(char(result.(1)));
volt_thresh = myVar;

% Epoch length of interest
[rows,~]=find(myVar_tab.varname==["buffer"]); result = myVar_tab(rows,paradigm); myVar = str2num(char(result.(1)));
buffer = myVar; % for freq analysis (freq of interest = 27Hz --> 1000/20hz*3=150ms extra on both sides)
[rows,~]=find(myVar_tab.varname==["epoch_min"]); result = myVar_tab(rows,paradigm); myVar = str2num(char(result.(1)));
epoch_min = myVar - buffer;
[rows,~]=find(myVar_tab.varname==["epoch_max"]); result = myVar_tab(rows,paradigm); myVar = str2num(char(result.(1)));
epoch_max = myVar + buffer;

% Baseline length of interest
[rows,~]=find(myVar_tab.varname==["baseline_min"]); result = myVar_tab(rows,paradigm); myVar = str2num(char(result.(1)));
baseline_min = myVar;
[rows,~]=find(myVar_tab.varname==["baseline_max"]); result = myVar_tab(rows,paradigm); myVar = str2num(char(result.(1)));
baseline_max = myVar;

% of bins in binlist
[rows,~]=find(myVar_tab.varname==["n_bins"]); result = myVar_tab(rows,paradigm); myVar = str2num(char(result.(1)));
n_bins = myVar;

%================
% STEP 5: ERP ANALYSIS
%================

%max freq plotted by Pwelch function
[rows,~]=find(myVar_tab.varname==["max_pwelch_freq"]); result = myVar_tab(rows,paradigm); myVar = str2num(char(result.(1)));
max_pwelch_freq=myVar;
%high and low freq for time/freq analysis
[rows,~]=find(myVar_tab.varname==["low_freq"]); result = myVar_tab(rows,paradigm); myVar = str2num(char(result.(1)));
low_freq = myVar;
[rows,~]=find(myVar_tab.varname==["high_freq"]); result = myVar_tab(rows,paradigm); myVar = str2num(char(result.(1)));
high_freq = myVar;
time_freq_frequencies_range = [low_freq high_freq];

% Stream 1 is 40hz; stream 2 is 27 Hz (in this paradigm)
[rows,~]=find(myVar_tab.varname==["stream1"]); result = myVar_tab(rows,paradigm); myVar = char(result.(1));
stream1 = myVar;
[rows,~]=find(myVar_tab.varname==["stream2"]); result = myVar_tab(rows,paradigm); myVar = char(result.(1));
stream2 = myVar;
streams = {stream1, stream2};

[rows,~]=find(myVar_tab.varname==["conditions"]); result = myVar_tab(rows,paradigm); myVar = char(result.(1));
tmp =  split(myVar,",");
conditions = cell(1,length(tmp));
for con = 1:length(tmp)
    conditions{con} = char(tmp(con));
end

[rows,~]=find(myVar_tab.varname==["highpass_filter_stream2"]); result = myVar_tab(rows,paradigm); myVar = str2num(char(result.(1)));
highpass_filter_stream2 = myVar;
[rows,~]=find(myVar_tab.varname==["lowpass_filter_stream2"]); result = myVar_tab(rows,paradigm); myVar = str2num(char(result.(1)));
lowpass_filter_stream2 = myVar;
[rows,~]=find(myVar_tab.varname==["highpass_filter_stream1"]); result = myVar_tab(rows,paradigm); myVar = str2num(char(result.(1)));
highpass_filter_stream1 = myVar;
[rows,~]=find(myVar_tab.varname==["lowpass_filter_stream1"]); result = myVar_tab(rows,paradigm); myVar = str2num(char(result.(1)));
lowpass_filter_stream1 = myVar;

% # of trials randomly selected per participant
[rows,~]=find(myVar_tab.varname==["trials_num_reduced"]); result = myVar_tab(rows,paradigm); myVar = str2num(char(result.(1)));
trials_num_reduced = myVar;

% timepoint (ms) to plot topography of individual ERPs
[rows,~]=find(myVar_tab.varname==["ERP_top_ref"]); result = myVar_tab(rows,paradigm); myVar = char(result.(1));
if strcmp(myVar,'NaN')
    ERP_top_ref = NaN;
else
    ERP_top_ref = myVar;
end

[rows,~]=find(myVar_tab.varname==["chan_of_interest"]); result = myVar_tab(rows,paradigm); myVar = char(result.(1));
tmp =  split(myVar,",");
chan_of_interest = cell(1,length(tmp));
for chan = 1:length(tmp)
    chan_of_interest{chan} = char(tmp(chan));
end

% pwelch settings
[rows,~]=find(myVar_tab.varname==["pwelch_epoch_start"]); result = myVar_tab(rows,paradigm); myVar = str2num(char(result.(1)));
pwelch_epoch_start = myVar;
[rows,~]=find(myVar_tab.varname==["pwelch_epoch_end"]); result = myVar_tab(rows,paradigm); myVar = str2num(char(result.(1)));
pwelch_epoch_end = myVar;

[rows,~]=find(myVar_tab.varname==["grp_controls"]); result = myVar_tab(rows,paradigm); myVar = char(result.(1));
tmp =  split(myVar,",");
grp_controls = cell(1,length(tmp));
for pt = 1:length(tmp)
    grp_controls{pt} = char(tmp(pt));
end

[rows,~]=find(myVar_tab.varname==["baseline_start"]); result = myVar_tab(rows,paradigm); myVar = str2num(char(result.(1)));
baseline_start = myVar;

[rows,~]=find(myVar_tab.varname==["baseline_end"]); result = myVar_tab(rows,paradigm); myVar = str2num(char(result.(1)));
baseline_end = myVar;

disp('----VARIABLES SET!')
