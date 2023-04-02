close all;
clear all;
clc;

%% Set a breakpoint in stere mode on elseif command - if not put a break point
%% it's close the windows and open the DEMMOD windows
%% Mono part
global debug
mode = 'sim'; % [sim,hw]
% if there's a problem with listening - fix in chrome settings
[audio, fs] = audioread("piano2.wav");
%[audio, fs] = audioread("music1.wav");
% soundsc(audio, fs);

% Transmitter 
Mono_Fm_Mod(audio,fs);

length_piano = 6306500; %piano2 after modulation
length_music1 = 65966080; %music1 after modulation

if strcmp(mode,'hw')
    rx_signal = RD_bin_file('data_rx.bin',4*10^6);
elseif strcmp(mode,'sim')
    rx_signal = RD_bin_file('data_tx.bin',length_piano);
    %rx_signal = RD_bin_file('rx_data_4MSamples1MsPs_978MHz.bin',4*10^6);
end

sampling_rate = 10^6;  % 1 MHz
% Receiver and comparison
[mono_audio_sig] = Mono_Fm_DeMod(rx_signal, sampling_rate, fs); %1Mhz per sec

soundsc(mono_audio_sig, fs);

%% Stereo part
close all;
clear all;
clc

mode = 'sim';
[audio_signal_R, fs_R] = audioread("piano2.wav");
[audio_signal_L, fs_L] = audioread("music1.wav");

% Transmitter 
Stereo_Fm_Mod(audio_signal_L, fs_L,audio_signal_R, fs_R )

% Channel 
if strcmp(mode,'hw')
        rx_signal_stereo = RD_bin_file('data_rx.bin',6306500); %piano2 after modulation
elseif strcmp(mode,'sim')
        rx_signal_stereo = RD_bin_file('data_tx.bin',6306500); %piano2 after modulation
end


% receiver and comparison
% RECEIVER
[audio_signal_restored_L, audio_signal_restored_R] = Stereo_Fm_DeMod(rx_signal_stereo, 10^6, fs_L, fs_R);

%%
figure('Name','Qfenicn');
subplot(2,2,1)
plot(1:length(audio_signal_restored_R), audio_signal_restored_R);
title('\fontsize{14}The reconstraction of the L original signal');
grid on
subplot(2,2,2);
plot(1:length(audio_signal_restored_L), audio_signal_restored_L);
title('\fontsize{14}The reconstraction of the R original signal');
subplot(2,2,3);
plot(1:length(audio_signal_L), audio_signal_L);
title('\fontsize{14}The L original signal');
grid on;
subplot(2,2,4);
plot(1:length(audio_signal_R), audio_signal_R);
title('\fontsize{14}The R original signal');
grid on;

soundsc(audio_signal_restored_L, fs_L);
soundsc(audio_signal_restored_R, fs_R);

