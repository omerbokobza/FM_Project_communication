function [] = plot_analyzer(fs, signal, title_name)
    figure('Name','vnfejnveojfso');
    L = length(db(fftshift(fft(signal))));
    x = linspace(-fs,fs,L);
    plot(x, db(fftshift(fft(signal))));
    grid on
    title(title_name);
end