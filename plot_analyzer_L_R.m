function [] = plot_analyzer_L_R(fs_L, signal_L, fs_R, signal_R, title_name_L, title_name_R)
    
    length_L = length(db(fftshift(fft(signal_L))));
    x_L = linspace(-fs_L,fs_L,length_L);
   
    length_R = length(db(fftshift(fft(signal_R))));
    x_R = linspace(-fs_R,fs_R,length_R);
    
    figure('Name','vnfejfso');
    subplot(1,2,1);
    plot(x_L, db(fftshift(fft(signal_L))));
    title(title_name_L);   
    grid on;
    subplot(1,2,2);
    plot(x_R, db(fftshift(fft(signal_R))));
    grid on;
    title(title_name_R);
end