% audio_processor.m
% Script to read, analyze, and process audio signals.
clear; clc; close all;

%% 1. Configuration
% We will look for an audio file in the data/ folder.
filename = fullfile('..', 'data', 'test_audio.wav');

% Generate a temporary test tone if the file does not exist
if ~isfile(filename)
    disp('Test file not found in data/. Generating a 1kHz sine wave for testing...');
    fs = 44100; % Sampling frequency (Hz)
    t = 0:1/fs:2; % 2 seconds duration
    audio_data = 0.5 * sin(2 * pi * 1000 * t)'; % 1kHz tone
    
    % Ensure data directory exists
    if ~exist(fullfile('..', 'data'), 'dir')
        mkdir(fullfile('..', 'data'));
    end
    audiowrite(filename, audio_data, fs);
else
    disp(['Found test file: ', filename]);
end

%% 2. Load Audio
[audio_data, fs] = audioread(filename);

% If stereo, convert to mono for basic processing by averaging channels
if size(audio_data, 2) > 1
    audio_data = mean(audio_data, 2);
end

num_samples = length(audio_data);
duration = num_samples / fs;
time_vector = linspace(0, duration, num_samples);

disp(['Successfully loaded audio. Duration: ', num2str(duration), ' seconds.']);
disp(['Sampling Frequency: ', num2str(fs), ' Hz']);

%% 3. Time Domain Analysis
figure('Name', 'Audio Signal Analysis', 'NumberTitle', 'off', 'Position', [100, 100, 800, 600]);

subplot(2, 1, 1);
plot(time_vector, audio_data, 'b');
title('Time Domain waveform');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

%% 4. Frequency Domain Analysis (FFT)
% Compute the Fast Fourier Transform
fft_result = fft(audio_data);

% Compute the two-sided spectrum, then the one-sided spectrum
P2 = abs(fft_result / num_samples);
P1 = P2(1:floor(num_samples/2)+1);
P1(2:end-1) = 2 * P1(2:end-1);

% Define frequency array
f = fs * (0:(floor(num_samples/2))) / num_samples;

subplot(2, 1, 2);
plot(f, 20*log10(P1), 'r'); % Plot magnitude in Decibels
title('Single-Sided Amplitude Spectrum (Frequency Domain)');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
xlim([0, fs/2]); % Limit to Nyquist frequency
grid on;

disp('Analysis complete. Close the figure to finish.');
