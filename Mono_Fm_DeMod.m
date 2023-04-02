function [audio_signal] = Mono_Fm_DeMod(demmod_signal, f_c, f_s)

    plot_analyzer(f_c, demmod_signal, "Recieved Signal");
    
    % LPF
    % frequency deviation 75k + one sided bw of 15 k = 90kHz
    d = fdesign.lowpass('N,Fc', 200, 90*10^3, f_c);
    Hd = design(d);
    LPF_filtered_signal = filter(Hd, demmod_signal);
    plot_analyzer(f_c, LPF_filtered_signal, "Carson Rule - LPF Signal ")
    
    % Downsampling back to 200kHz
    sampling_rate = 200*10^3;
    downsampling_signal = resample(LPF_filtered_signal, sampling_rate, f_c);
    plot_analyzer(f_c, downsampling_signal, "Down Sample to 200kHz Recieved Signal")
    
    % Demodulation
    f_d = 75*10^3; % the freauency deviation
    shift_phase = unwrap(angle(downsampling_signal)); % continous phase of sig
    demodulated_signal = diff(shift_phase)*sampling_rate./(2*pi*f_d);
    plot_analyzer(f_c, demodulated_signal, "demodulated signal");
    % LPF
    d = fdesign.lowpass('N,Fc', 200, 15*10^3, sampling_rate);
    Hd = design(d);
    LPF_filtered_signal = filter(Hd, demodulated_signal);
    plot_analyzer(f_c, LPF_filtered_signal, "demodulated signal after LPF")
    
    % downsample - to sampling_rate/f_s
    audio_signal = resample(LPF_filtered_signal, f_s, sampling_rate);
    plot_analyzer(f_c, audio_signal, "Down sample to 48 kHz recieved signal")
    L = length(db(fftshift(fft(audio_signal))));
    x = linspace(-f_s,f_s,L);
    figure('Name','Q48kHz');
    plot(x,audio_signal);
    title('\fontsize{18}The DownSampled Signal - Time Domain');
 
end

