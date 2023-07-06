% -------------------------------------------------------------------------
% Name: Seydanur Reisli
% Email: seydareisli@gmail.com
% Last Updated: 06/12/2023
% -------------------------------------------------------------------------


function EEG = setChanLocs(EEG)
    % This function assumes that you are working with either a 64-channel or 160-channel system.
    
    % If there are fewer than 100 channels, we assume it's a 64-channel system.
    if EEG.nbchan < 100
        % Remove channels beyond the 64th
        EEG.data(65:end,:) = []; 
        EEG.nbchan = 64;
        
        % Apply the Biosemi64.sfp channel locations
        EEG = pop_editset(EEG, 'chanlocs', 'Biosemi64.sfp');
        EEG.chanlocs = pop_chanedit(EEG.chanlocs, 'load', { 'Biosemi64.sfp', 'filetype', 'autodetect'});
    else
        % If there are 100 or more channels, we assume it's a 160-channel system.
        % Remove channels beyond the 166th
        EEG.data(167:end,:) = []; 
        EEG.nbchan = 166;
        
        % Apply the Biosemi166.sfp channel locations
        EEG = pop_editset(EEG, 'chanlocs', 'Biosemi166.sfp');
        EEG.chanlocs = pop_chanedit(EEG.chanlocs, 'load', { 'Biosemi166.sfp', 'filetype', 'autodetect'});
    end

    % Plot the channel locations
    figure; 
    topoplot([], EEG.chanlocs, 'style', 'blank', 'electrodes', 'labelpoint', 'chaninfo', EEG.chaninfo); 
end
