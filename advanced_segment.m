function [] = advanced_segment()
    % Read in the waveform
    [y, Fs] = audioread('Test_Tune2.wav');
    
    % Selecting one channel from the input audio
    y = y(:, 1);
    
    % Some niceties
    t = linspace(0, length(y) / Fs, length(y));
    n = 1:length(y);
    
    % Synthetically add in WGN
    y = awgn(y, 10, 'measured');
    
    % Scale the audio for preprocessing calculations
    y_mod = denoise(y);
    y_mod = normalize(y_mod, 'range', [-1, 1]);
    y_mod = exp(abs(y_mod.^2) + 1) - 2.718;
    
    %% Thresholding and separate note detection
    % Set a moving average threshold
    movingMean = 2 * movmean(y_mod, floor(Fs/10));
    
    % Get all the local minima, which indicate the thresholds
    minima = islocalmin(movingMean, 'MinProminence', mean(abs(y)));
    
    % Force detection of the beginning and end
    minima(1) = 1;
    minima(end) = 1;

    % Extract all the local minima points, throw away all zeros
    localMinima = find(minima);
    
    % Detect outliers and remove them
    outlierEdges = isoutlier(movingMean(localMinima), 'movmean', floor(Fs/20));
    localMinima = localMinima(outlierEdges == 0);

    % Just for fun
    disp("Detected " + (length(localMinima) - 1) + " notes.");
    
    % Zero padding length, for storing and FFT
    maxLength = 2^nextpow2(max(localMinima.' - [0 localMinima(1:end-1).']));
    segments = [];
    
    % Extract individual segments
    for i = 1:length(localMinima) - 1
        temp = y(localMinima(i):localMinima(i+1)-1);
        temp = vertcat(zeros(maxLength - length(temp), 1), temp);
        segments(:, i) = temp;
    end
    
    % Get all the frequencies in each note
    for j=1:length(localMinima) - 1
        [freqs, PSD] = GetPSD(segments(:, j), Fs);
        [~, index] = max(PSD);
        notes(j) = round(abs(freqs(index)), 1);
    end    
    
    %% Plotting stuff
    locations = localMinima(2:end);
    locations(end+1) = 0;
    locations = floor((localMinima + locations) / 2);
    locations = locations(1:end-1).';

    % Plot the moving average threshold, along with detected frequency in
    % the segment
    subplot(2, 2,[1 2]);
    plot(n, movingMean, '-b', n(minima), movingMean(minima), 'ro');
    text(n(locations), movingMean(locations), string(notes), ...
        'VerticalAlignment','bottom','HorizontalAlignment','center');
    for i = 1:length(localMinima) - 1
        xline(n(localMinima(i)), '--k', i);
    end
    xlim([-0.05*length(y) 1.05*length(y)]);
    title("The moving average threshold used for segmentation. (Label = freq)");
    xlabel("Number of samples (n)");
    ylabel("Amplitude (V)");
    grid on;
    
    % Plot the transformed input, with the tbreshold
    subplot(2, 2, [3 4]);
    plot(t, y_mod);
    title("Modified audio, with threshold");
    for i = 1:length(localMinima) - 1
        xline(t(localMinima(i)), '--k', i);
    end
    xline(t(localMinima(end)), '--k');
    xlim([-1 ceil(t(end))]);
    xlabel("Time (s)");
    ylabel("Amplitude (V)");
    grid on;

end

%% Function to denoise the input signal
function [de] = denoise(noisy)
    [c,l] = wavedec(noisy, 3, 'db6');
    b = wthresh(c, 's', 0.045);
    de = waverec(b, l, 'db6');
end

%% Function to get the PSD of a signal
function [f_axis, PSD] = GetPSD(signal, Fs)
    f_axis = -Fs/2: Fs/length(signal) : Fs/2 - Fs/length(signal);
    signal_fft = abs(fftshift(fft(signal)/length(signal)));
    
    PSD = signal_fft.^2;
end