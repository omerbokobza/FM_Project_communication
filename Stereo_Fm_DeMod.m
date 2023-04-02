function [audio_signal_L, audio_signal_R] = Stereo_Fm_DeMod(demmod_signal, fc, fs_L, fs_R)
    plot_analyzer(fc, demmod_signal, "\fontsize{18}The Stereo Recieved Signal") 

% f_delta....

    % LPF
    % frequency deviation 75k + one sided bw of 38k + 15kHz = 128kHz
    d = fdesign.lowpass('N,Fc', 200, 128*10^3, fc);
    Hd = design(d);
    LPF_filtered_signal = filter(Hd, demmod_signal);
    plot_analyzer(fc, LPF_filtered_signal, "\fontsize{18}The Stereo Signal - After LPF, According to Carson Rule")

    % Downsampling back to 200kHz
    sampling_rate = 200*10^3;
    downsampling_signal = resample(LPF_filtered_signal, sampling_rate, fc);
    plot_analyzer(fc, downsampling_signal, "\fontsize{18}DownSample to 200kHz Recieved Signal")
    
    % Demodulation - shift in phase..
    fd = 75*10^3;   % frequency deviation
    % shift phase
    shift_phase = unwrap(angle(downsampling_signal)); 
    demodulated_signal = diff(shift_phase)*sampling_rate./(2*pi*fd);
    plot_analyzer(fc, demodulated_signal, "\fontsize{18}Demodulated Signal-Recieved Signal (DSB-SC)")

    % LPF for extract L+R - *** Mono ***
    d = fdesign.lowpass('N,Fc', 200, 15*10^3, sampling_rate);
    Hd = design(d);
    L_R_mono = (2/0.9)*filter(Hd, demodulated_signal); %L+R, factor 2


    % Extract L-R part - *** Stereo part ***
    % Calculate phase diff using pilot
    fpilot = 19*10^3; % pilot tone
    d = fdesign.lowpass('N,Fc', 200, 2*10^3, sampling_rate);
    Hd = design(d);
    t = (1:length(demodulated_signal))./sampling_rate;
    filtered_phase = filter(Hd, demodulated_signal.*cos(2*pi*t*fpilot));
    filtered_quad = filter(Hd, demodulated_signal.*sin(2*pi*t*fpilot)); % the sin || cos
    delta = atan(filtered_quad./filtered_phase); % diff in phase
    plot_analyzer_L_R(fs_L, filtered_phase, fs_R, filtered_quad, "in-phase", "Quadrature")

    % Extract the L-R, L+R - ** extracting the stereo part ***
    d = fdesign.lowpass('N,Fc', 200, 15*10^3, sampling_rate);
    Hd = design(d);
    L_minus_R_part = (2/0.9)*demodulated_signal.*sin(2*pi*t*2*fpilot + delta);
    L_minus_R = filter(Hd, L_minus_R_part);
    plot_analyzer_L_R(fc, L_R_mono, fc, L_minus_R, "L+R Part", "L-R Part")
  
    % dividing the two signals - left and right
    L_signal = (L_minus_R + L_R_mono)/2; % 2L/2
    R_signal = -(L_minus_R - L_R_mono)/2; % 2R/2
    %plot_analyzer_L_R(fc, L_signal, fc, R_signal, "\fontsize{18}L Part", "\fontsize{18}R Part")

    % downsampling, after the seperation
    % fs_R/sampling_rate;
    audio_signal_L = resample(L_signal, fs_R, sampling_rate);
    audio_signal_R = resample(R_signal, fs_R, sampling_rate);
    plot_analyzer_L_R(fs_L, audio_signal_L, fs_R, audio_signal_R, "Left-Music1 file", "Right-Piano file")
