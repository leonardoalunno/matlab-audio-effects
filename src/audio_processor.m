% audio_processor.m
% Script to read, analyze, and process audio signals.
clear; clc; close all;

%% 1. Configuration
% We will look for an audio file in the data/ folder.
filename = fullfile('..', 'data', 'test_audio.wav');

% Generate a temporary test tone if the file does not exist
if ~isfile(filename)
    disp('Test file not found in data/. Generating a noisy 1kHz sine wave for testing...');
    fs = 44100; % Sampling frequency (Hz)
    t = 0:1/fs:2; % 2 seconds duration
    audio_data = 0.5 * sin(2 * pi * 1000 * t)'; % 1kHz tone
    
    % Add some high-frequency noise to demonstrate the filter
    noise = 0.2 * randn(size(audio_data));
    audio_data = audio_data + noise;
    
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

%% 3. Apply Digital Filter
% Let's apply a low-pass filter to remove high-frequency noise
cutoff_freq = 2000; % Hz (Anything above 2000Hz will be attenuated)
disp(['Applying Low-Pass filter with cutoff at ', num2str(cutoff_freq), ' Hz...']);

filtered_audio = apply_digital_filter(audio_data, fs, 'low', cutoff_freq);

% Save the filtered result to the results folder
output_filename = fullfile('..', 'results', 'filtered_audio.wav');
if ~exist(fullfile('..', 'results'), 'dir')
    mkdir(fullfile('..', 'results'));
end
audiowrite(output_filename, filtered_audio, fs);
disp(['Filtered audio saved to: ', output_filename]);


%% 4. Time Domain Analysis Plot
figure('Name', 'Audio Signal Analysis', 'NumberTitle', 'off', 'Position', [100, 100, 1000, 800]);

% Plot original signal
subplot(2, 2, 1);
plot(time_vector, audio_data, 'b');
title('Original Audio (Time Domain)');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

% Plot filtered signal
subplot(2, 2, 2);
plot(time_vector, filtered_audio, 'm');
title('Filtered Audio (Time Domain)');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

%% 5. Frequency Domain Analysis (FFT)
% Function to compute Single-Sided Spectrum
compute_spectrum = @(data) ...
    deal(abs(fft(data) / num_samples), ...
         (fs * (0:(floor(num_samples/2))) / num_samples));

% Compute FFT for original
[P2_orig, f] = compute_spectrum(audio_data);
P1_orig = P2_orig(1:floor(num_samples/2)+1);
P1_orig(2:end-1) = 2 * P1_orig(2:end-1);

% Compute FFT for filtered
[P2_filt, ~] = compute_spectrum(filtered_audio);
P1_filt = P2_filt(1:floor(num_samples/2)+1);
P1_filt(2:end-1) = 2 * P1_filt(2:end-1);

% Plot original spectrum
subplot(2, 2, 3);
plot(f, 20*log10(P1_orig), 'r');
title('Original Spectrum (Frequency Domain)');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
xlim([0, fs/2]);
grid on;

% Plot filtered spectrum
subplot(2, 2, 4);
plot(f, 20*log10(P1_filt), 'g');
title(['Filtered Spectrum (Cutoff ', num2str(cutoff_freq), 'Hz)']);
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
xlim([0, fs/2]);
grid on;

disp('Analysis visualization complete.');
