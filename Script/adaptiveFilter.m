function [y,err] = adaptiveFilter(s_n,n, learning_rate)
    %**** Description ****
    %s_n is  column vector containing signal and noise together. The noise
    %on this signal cannot be exactly the noise on vector "n".
    %n is a columnn vector containing only the noise

    N=size(s_n,1); %get signal length
    
    M = 15; %Fs/30; % # of weights
    W = zeros(M,1); % format: W = [W0; W1; ...; WM-1] W0=weight related to k-0=k;
    y = zeros(N,1); % zero from 1 to M-1 
    err = zeros(N,1); % zero from 1 to M-1 
    d = s_n; % primary signal

    %for each sample, get the M last samples and apply the algorithm
    for i=M:N
        U = n(i:-1:i-M+1); %U in reverse order so the algorithm works as expected
        y(i) = W'*U; %calculate approximate noise.
        err(i) = d(i) - y(i);
        W = W + learning_rate * err(i) * U;
    end
end