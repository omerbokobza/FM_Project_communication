function [] = Stereo_Fm_Mod(audio_signal_L, fs_L, audio_signal_R, fs_R)
    plot_analyzer_L_R(fs_L, audio_signal_L, fs_R, audio_signal_R,"Signal Left", "Signal Right")

    % upsampling to 200kHz, by factor of 200k/fs
    sampling_rate = 200*10^3;
    upsampled_signal_L = resample(audio_signal_L,sampling_rate,fs_L); 
    upsampled_signal_R = resample(audio_signal_R,sampling_rate,fs_R); 
    plot_analyzer_L_R(fs_L, upsampled_signal_L, fs_R, upsampled_signal_R,"Upsamled 200kHz Signal Left", "Upsamled 200kHz Signal Right")

    % filter to one sided BW of 15kHz, Applying a LPF
    d = fdesign.lowpass('N,Fc', 200, 15*10^3, sampling_rate);
    Hd = design(d);
    LPF_filtered_signal_L = filter(Hd, upsampled_signal_L);
    LPF_filtered_signal_R = filter(Hd, upsampled_signal_R);

    % process for the concatenate vectors
    min_length = min(length(LPF_filtered_signal_L), length(LPF_filtered_signal_R));
    LPF_filtered_signal_L = LPF_filtered_signal_L(1:min_length);
    LPF_filtered_signal_R = LPF_filtered_signal_R(1:min_length);
    plot_analyzer_L_R(fs_L, LPF_filtered_signal_L, fs_R, LPF_filtered_signal_R,"Filtered Signal Left", "Filtered Signal Right")
    
    
    % the DSB-SC
    fp = 19*10^3; % pilot tone
    fd = 75*10^3; %frequency deviation
    t = (1:min_length)./sampling_rate;
    A = (LPF_filtered_signal_L+LPF_filtered_signal_R)/2;
    A2 = (LPF_filtered_signal_L-LPF_filtered_signal_R)/2;
    DSB_SC = 0.9*((A + A2.*sin(4*pi*fp*t)) + 0.1*sin(2*pi*fp*t));
    plot_analyzer(fs_R, DSB_SC, "\fontsize{18}The DSB-SC Signal")

    % modulate the signal using a frequency deviation of 75kHz, FM modulation
    % according to the page 1.
    norm_signal = DSB_SC./max(abs(DSB_SC)); %normalized filtered signal
    modulated_signal = exp(2*pi*1i*(fd.*cumsum(norm_signal)/sampling_rate)); % integral into the exponent
    plot_analyzer(fs_R, modulated_signal, "Modulated Signal")

    %upsampling to 1MHz, by factor of 1MHz/200k
    sampling_rate2 = 10^6;
    upsampled_signal = resample(modulated_signal,sampling_rate2,sampling_rate); 
    plot_analyzer(fs_R, upsampled_signal, "\fontsize{18}Upsamled 1MHz Signal")

    % LPF: CARSON BW Rule
    % frequency deviation 75k + one sided bw of 38k = 128kHz
    d = fdesign.lowpass('N,Fc', 200, 128*10^3, sampling_rate2);
    Hd = design(d);
    LPF_filtered_signal = filter(Hd, upsampled_signal);
    plot_analyzer(fs_R, LPF_filtered_signal, "\fontsize{18}The Transmitted Signal According to Carson Rule- BW = 128kHz")
    
    % saving the data
    WR_bin_file('data_tx.bin',LPF_filtered_signal.');

end
