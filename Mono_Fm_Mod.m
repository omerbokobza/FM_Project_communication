function []  = Mono_Fm_Mod(audio_signal,f_s)
    
    plot_analyzer(f_s, audio_signal, "\fontsize{18}The original signal - Frequency Domain");

    sampling_rate = 200*10^3; % 200 kHz
    upsampling = resample(audio_signal,sampling_rate,f_s); % upsampling, when entering to the system.
    plot_analyzer(f_s, upsampling, "\fontsize{18}Upsampled signal - sampling rate 200kHZ");
    
    
    d = fdesign.lowpass('N,Fc', 200, 15*10^3, sampling_rate); % one sided signal of 15 kHz
    Hd = design(d);
    LPF_filtered_signal = filter(Hd, upsampling); % the lowpass filter
    %plot_analyzer(f_s,LPF_filtered_signal,'\fontsize{18}The Filtered Signal - Frequency Domain');

    norm_sig = LPF_filtered_signal./max(LPF_filtered_signal); %normalize filtered signal
    f_d = 75*10^3; % frequency deviation
    modulated_signal = exp(2*pi*1i*(f_d.*cumsum(norm_sig)/sampling_rate)); % page 1, datasheet
    %plot_analyzer(f_s, modulated_signal, "\fontsize{18}The modulated signal - Frequency Domain");

    %upsampling to 1MHz, we got factor 1MHz/200k
    sampling_rate_after_modulation = 10^6;
    upsampling_signal = resample(modulated_signal,sampling_rate_after_modulation,sampling_rate); %
    plot_analyzer(f_s, upsampling_signal, "\fontsize{18}Upsampled 1MHz Signal")
    
    % pass through LPF: CARSON BW Rule
    % frequency deviation 75k + one sided bw of 15 k = 90kHz
    d = fdesign.lowpass('N,Fc', 200, 90*10^3, sampling_rate_after_modulation);
    LPF_filtered_signal = filter(design(d), upsampling_signal);
    plot_analyzer(f_s, LPF_filtered_signal, "\fontsize{18}Final transmitted signal Carson rule");
    
    WR_bin_file('data_tx.bin',LPF_filtered_signal(:,1)); % saving the data, god save the queen

end
