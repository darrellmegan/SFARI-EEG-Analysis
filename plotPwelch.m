% calc and plot signal's frequency content with welch. 
% Inputs: x: signal (rows: signals; columns: time points)
%           Color: colors to plot the results (default: random)
%           freqPlot: figure number (default: 100)
%           freq: highest frequency to calculate
%           Fs: data sampling rate
%           Shlomit Beker 2018  <shlomitbeker@gmail.com>



function [pxx,f] = plotPwelch(x,colors,freqPlot,freq,Fs,subject_ID,myChan)

%setting defaults
if ~exist('colors','var') || isempty(colors)
    colors = rand(270,3);
end

if ~exist('freqPlot','var') || isempty(freqPlot)
    freqPlot = 100;
end

if ~exist('Fs','var')|| isempty(Fs)
    Fs = 256;
end

%

for i = 1:size(x,1)
   % figure(freqPlot); 
    freqVec = x(i,:);
    [pxx,f] = pwelch(freqVec,length(x),length(x).*0.9,0:0.01:freq,Fs);
    %plot(f,pxx,'Color',colors(i,:),'LineWidth',2);
    hold on;
end

%title(['time-frequency conversion with Welch: Subject ' subject_ID ' - Channel ' myChan]);
%xlabel('Frequency (Hz)')
%ylabel('Magnitude (dB)')
%set(gca,'fontsize', 8);
close all
end