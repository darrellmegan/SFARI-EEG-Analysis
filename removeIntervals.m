% -------------------------------------------------------------------------
% Name: Seydanur Reisli
% Email: seydareisli@gmail.com
% Adapted by: Megan Darrell
% Last Updated: 06/14/2023
% -------------------------------------------------------------------------


function [EEG] = removeIntervals(EEG,subjectID,save_path)
    minutes_initial = round(length(EEG.data)/EEG.srate/60);
    x=[]; y=[]; m=1;
    for n=1:length(EEG.event)-1
        t1 = EEG.event(n).latency;
        t2 = EEG.event(n+1).latency; 
        if t2-t1> EEG.srate %EEG.srate should do the job, but doesn't have to be exactly that
            x(m,1)=t1; x(m,2)=t2; m=m+1; end
    end
    x(m,1)=EEG.event(end).latency;
    x(m,2)=length(EEG.data);
    x = x + [EEG.srate/2 -EEG.srate/8];

    dfr=x(:,2)-x(:,1); 
    minutes_removed = round(sum(dfr)/EEG.srate/60);
    EEG = eeg_eegrej( EEG, x);
    minutes_remains = round(length(EEG.data)/EEG.srate/60);
    dlmwrite([save_path,filesep,'MinutesRemoved.txt'],[num2str(minutes_removed) ' minutes is removed from the subject ' subjectID],'delimiter','','precision','%.0f','newline','pc','-append');               
    dlmwrite([save_path,filesep,'MinutesRemaining.txt'],[num2str(minutes_remains) ' minutes remaining from the subject ' subjectID],'delimiter','','precision','%.0f','newline','pc','-append');               
    fprintf('%d minutes is removed from data \n',minutes_removed);
end