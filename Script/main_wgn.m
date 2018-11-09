clear all;
snr_array=[10;5;0;-5;-10];
file_name = "song_synth";
file_to_read = 'Music1_bensound-happyrock.mp3';
file_output_text=file_name+".txt";
learning_rate=10^-3;
fileID = fopen(file_output_text,'wt+');
fprintf(fileID, "Learning Rate for all tests %d\n", learning_rate);

for i=1:size(snr_array)
    snr=snr_array(i);
    fprintf(fileID, "For SNR %d", snr);
    tic    
    close all;
    seed=1;

    %great guide
    %https://www.mathworks.com/help/dsp/ug/overview-of-adaptive-filters-and-applications.html#bqud8rg
    %https://www.mathworks.com/help/dsp/ug/lms-adaptive-filters.html
    %increase power of signal by 3db: x .*= 10^(3/20)

    %*** Recorded signal
    [s,Fs] = audioread(file_to_read);
    if(Fs~=48000)
        s=resample(s,48000,Fs);
        Fs=48000;
    end
    s=s(:,1); %wav from iphone returns two column-> two channels. get only one.
    T=1/Fs; %Period
    length=10; %Legth of Signal in seconds
    N=ceil(length*Fs); %Amount of samples to length
    s=s(1:min(size(s,1), N));
    t = (0:N-1)/Fs; %time vector
    %s=normalize(s); %normalize. Be careful for playing audio. between -1 to 1 is ideal.
    power_s = rms(s)^2;
    power_s_db = pow2db(power_s);

    %plot original signal
    figure('units','normalized','outerposition',[0 0 1 1])
    subplot(3,1,1);
    plot(t, s); xlabel('Seconds'); ylabel('Amplitude');title('Original Signal');

    %*** Real Noise
    power_n_db = power_s_db - snr;
    power_n = db2pow(power_n_db);
    n = wgn(N,1,power_n_db,1,seed); %column vector, with specified vector, 1 impedance and seed.
    
    nfilt = fir1(15,0.4, 'low');
    n2=filter(nfilt,1,n);
    s_n = s + n2;
    d=s_n;
    
    %plot noisy signal
    subplot(3,1,2);
    plot(t, s_n); xlabel('Seconds'); ylabel('Amplitude');title('Noisy Signal');
    
    %create noisy signal to approximate
%     n = wgn(min(size(n,1), N),1,power_n_db,1,seed); %column vector, with specified vector, 1 impedance and seed.
    %can't apply directly the noise, otherwise will always be possible.
    %However, it has to be correlated. So, pass noise by a Low pass Filter.
    

    disp('learning rate has to be smaller than: ');
    disp(2/power_n);
    fprintf(fileID, "\nlearning rate has to be smaller than: %8.4f", 2/power_n);

    %Call adaptive filter
    [y,err] = adaptiveFilter(s_n,n, learning_rate);

    %plot LMS adative filter results.
    subplot(3,1,3);
    plot(t, err);xlabel('Seconds'); ylabel('Amplitude');title('Recovered Signal');

    toc %output time
    saveas(gcf,file_name+"_snr"+string(snr)+".png")

%     play sounds
%     sound(s, Fs);
%     input('press any key to skip')
%     clear sound;
%     sound(d, Fs);
%     input('press any key to skip')
%     clear sound;
%     sound(err, Fs);
%     input('press any key to skip')
%     clear sound;

    %spectrum
    figure('units','normalized','outerposition',[0 0 1 1]);
    signals=[s, d, err];
    titles=["Original Signal FT Mag"; "Noisy Signal FT Mag"; "Recovered Signal FT Mag"];
    subplots_order=[1,2;3,4;5,6];
    for i=1:3
        % Fourier Transform:
        X(:,i) = fft(signals(:,i));

        % Frequency specifications:
        N = size(t,2);
        f = ((0:1/N:1-1/N)*Fs).';
        magnitude = mag2db(abs(X(:,i)));        % Magnitude of the FFT in db
        phase = unwrap(angle(X(:,i)));  % Phase of the FFT    

        % Plot the spectrum:
        subplot(3,2,(i-1)*2+1);
        plot(f,magnitude);
        xlabel('Frequency (in hertz)');ylabel('Magnitude in dB');
        title(titles(i));
        axis([0 20000 0 inf])

        subplot(3,2,(i-1)*2+2);
        plot(f,phase);
        xlabel('Frequency (in hertz)');ylabel('Phase in rad');
        title(titles(i));
        axis([0 20000 -inf inf]);
    end

    saveas(gcf,file_name+"_FT_snr"+string(snr)+".png")

    %Save audiofiles for future reference
    audiowrite(char(file_name+"_err"+string(snr)+".ogg"), err, Fs)
    audiowrite(char(file_name+"_inputd"+string(snr)+".ogg"), d, Fs)
    
    %Squared errors Time Domain
    SSE = sum((s-err).^2);
    disp("SSE Time Domain:")
    disp(SSE);
    fprintf(fileID, "\nSSE Time Domain: %8.4f", SSE);

    %Squared errors Frequency Domain
    disp("SSE Frequency:")
    SSE = sum((abs(X(:,1))-abs(X(:,3))).^2);
    disp(SSE);
    fprintf(fileID, "\nSSE Frequency Domain: %8.4f", SSE);
    fprintf(fileID, "\n");
end
fclose('all');