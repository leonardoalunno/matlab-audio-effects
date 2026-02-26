function [filtered_audio] = apply_digital_filter(audio_data, fs, filter_type, cutoff_freq)
% APPLY_DIGITAL_FILTER Applies a digital Butterworth filter to an audio signal.
%
%   [filtered_audio] = apply_digital_filter(audio_data, fs, filter_type, cutoff_freq)
%
%   Inputs:
%       audio_data  - The input audio signal (vector)
%       fs          - Sampling frequency in Hz
%       filter_type - String: 'low' or 'high'
%       cutoff_freq - Cutoff frequency in Hz
%
%   Outputs:
%       filtered_audio - The processed audio signal

    % Filter order (higher = steeper roll-off but more computational cost)
    filter_order = 4;
    
    % Normalize cutoff frequency to the Nyquist frequency (fs/2)
    nyquist_freq = fs / 2;
    Wn = cutoff_freq / nyquist_freq;
    
    % Ensure valid normalized frequency
    if Wn <= 0 || Wn >= 1
        error('Cutoff frequency must be strictly between 0 and fs/2.');
    end
    
    % Design the Butterworth filter
    if strcmpi(filter_type, 'low')
        [b, a] = butter(filter_order, Wn, 'low');
    elseif strcmpi(filter_type, 'high')
        [b, a] = butter(filter_order, Wn, 'high');
    else
        error('Invalid filter type. Supported types: ''low'', ''high''.');
    end
    
    % Apply the filter to the data using filtfilt to preserve phase (Zero-phase filtering)
    % filtfilt runs the filter forwards and backwards to cancel phase distortion.
    filtered_audio = filtfilt(b, a, audio_data);

end
