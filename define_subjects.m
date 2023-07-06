
function subject_list = define_subjects(load_path,pts_to_exclude);

%% ---------------------------------------------------------------------------------------------------
% DEFINE SUBJECTS
%---------------------------------------------------------------------------------------------------

% DEFINE YOUR SUBJECT IDs
topLevelFolder = load_path;
% Get a list of all files and folders in this folder.
files = dir(topLevelFolder);
% Extract only those that are directories.
subFolders = files([files.isdir]);
% Get only the folder names into a cell array.
% Start at 3 to skip . and ..
subIDs = {subFolders(3:end).name};

subject_list = setdiff(subIDs, pts_to_exclude);

disp('----SUBJECTS DEFINED!')
