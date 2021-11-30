clear all;
[y, Fs] = audioread('C_major.wav');

divs = get_boundaries(y);
segments = get_segments(y, divs);

for j=1:length(segments)
    [freqs{j}, PSDs{j}] = get_fft(segments{j}, Fs);
    [~, indices(j)] = max(PSDs{1, j});
    notes(j) = freqs{1, j}(indices(j));
end    

display(notes);

%% plots
figure;
plot(y);
hold on;

for i = 1:length(divs)
    xline(divs(i), 'b--');
end