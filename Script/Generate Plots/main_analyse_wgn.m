clear all;

file_name="WGNSignal";
file_output_text="WGNSignal.txt";
fileID = fopen(file_output_text,'wt+');

tic    
close all;
seed=1;

%great guide
%https://www.mathworks.com/help/dsp/ug/overview-of-adaptive-filters-and-applications.html#bqud8rg
%https://www.mathworks.com/help/dsp/ug/lms-adaptive-filters.html
%increase power of signal by 3db: x .*= 10^(3/20)

length=10;
Fs=48000;
figure('units','normalized','outerposition',[0 0 1 1]);
N=length*Fs;
%*** create wgn -15dB power
s=wgn(N,1,-15,1,seed); %15db
if(Fs~=48000)
    s=resample(s,48000,Fs);
    Fs=48000;
end
N=ceil(length*Fs); %Amount of samples to length
s=s(1:min(size(s,1), N));
t = (0:N-1)/Fs; %time vector
power_s_2 = rms(s)^2;
power_s_2_db = pow2db(power_s_2);
fprintf(fileID, "\n Power: %4.4f Power dBW: %4.4f", power_s_2, power_s_2_db);
%plot music signal.
subplot(1,1,1);
plot(t, s);xlabel('Seconds'); ylabel('Amplitude');title("White Gaussian Noise -15dB");
sig(:,1)=s;

saveas(gcf,file_name+"TimeDomain.png")


%spectrum
figure('units','normalized','outerposition',[0 0 1 1]);
signals=sig;
m=size(sig,2);
titles=["White Gaussiam Noise FT"];
for i=1:size(signals,2)
    % Fourier Transform:
    X(:,i) = fft(signals(:,i));

    % Frequency specifications:
    N = size(t,2);
    f = ((0:1/N:1-1/N)*Fs).';
    magnitude = mag2db(abs(X(:,i)));        % Magnitude of the FFT in db
    phase = unwrap(angle(X(:,i)));  % Phase of the FFT    

    % Plot the spectrum:
    subplot(m,2,(i-1)*2+1);
    plot(f,magnitude);
    xlabel('Frequency (in hertz)');ylabel('Magnitude in dB');
    title(titles(i));
    axis([0 20000 0 inf])

    subplot(m,2,(i-1)*2+2);
    plot(f,phase);
    xlabel('Frequency (in hertz)');ylabel('Phase in rad');
    title(titles(i));
    axis([0 20000 -inf inf]);
end

saveas(gcf,file_name+"FourierTransform.png")
fclose('all');