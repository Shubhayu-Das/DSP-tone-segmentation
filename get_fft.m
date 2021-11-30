function [freq, PSD]=get_fft(y,Fs)
dt = 1/Fs;
t = 0:dt:(length(y)-1)*dt;
N = length(t);
Y = fft(y, N);
PSD = Y.*conj(Y)/N;
freq = 1/(dt*N)*(0:N);
L = 1:floor(N/2);

freq = freq(L);
PSD = PSD(L);
end