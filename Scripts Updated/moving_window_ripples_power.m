function ripple_all = moving_window_ripples_power(channel,fs,raw_signal,fs_new,signal_bp,timestamps_original,timestamps,threshold_power,threshold_amp)
%Inputs:-
%channel:- channel number
%fs:- original sampling frequency
%fs_new:- downsampled frequency
%signal:- raw signal
%signal_bp:- bandpassed signal
%timestamps_original:- timestamps without filtering the nrem data
%timestamps:- timestamps that contain only nrem data
%threshold_power:- the power criteria set to the power of the [100 300] frequency band
%threshold_amp:- the amplitude threshold criteria expressed in terms of number of standard deviations
%(if threshold_amp = 5, then amplitude threshold = mean + 5 standard deviations)

%Output:-
%gives the ripples of on channel
raw_signal(isnan(raw_signal)) = 0;
signal_bp(isnan(signal_bp)) = 0;

min_duration = 0.04;    %minimum duration of the ripple
max_duration = 0.150;   %maximum duration of the ripple

threshold_ratio_amplitude = 0.1;    %percentage of peaks that should cross the threshold criteria
stride_detect_time = 0.01;          %strides taken by the window during initial detection in seconds
stride_limit_time = 0.003;          %strides taken by the window to detect the boundary of the ripple
window_detect_time = 0.04;          %window duration for initial ripple detection in seconds
window_limit_time = 0.01;           %window duration for boundary detection
stride_detect = stride_detect_time* fs_new;
stride_limit = stride_limit_time * fs_new;
window_detect = window_detect_time * fs_new;
window_limit = window_limit_time * fs_new;

start_times = [];
end_times = [];
max_times = [];

st = 1;

threshold_amplitude = mean((signal_bp)) + threshold_amp * std(abs(signal_bp));
%moving the detection window across the array of raw data
while st < (length(timestamps) - window_detect + 1)
    a = st;
    b = st + window_detect;
    power_band = bandpower(signal_bp(a:b),fs_new,[100 300]);
    power_detect = power_band;
    %checking for power detection
    if power_band > threshold_power
        i = 0;
        %boundary detection start
        while power_band > threshold_power*.8
            chunk_end = a + i * stride_limit;
            chunk_start = max(chunk_end - window_limit , 1);
            if chunk_start == chunk_end
                break;
            end
            power_band = bandpower(signal_bp(chunk_start:chunk_end),fs_new,[100 300]);
            
            i = i - 1;
            if chunk_start == 1
                break;
            end
        end
        start_times = [start_times ; timestamps(chunk_start)];
        power_band = power_detect;
        i = 0;
        %boundary detection end
        while power_band > threshold_power*.8
            chunk_start = b + i * stride_limit;
            chunk_end = min((chunk_start + window_limit),length(signal_bp));
            if chunk_start == chunk_end
                break;
            end
            power_band = bandpower(signal_bp(chunk_start:chunk_end),fs_new,[100 300]);
            
            i = i + 1;
            if chunk_end == length(signal_bp)
                break;
            end
        end
        end_times = [end_times ; timestamps(chunk_end)];
        st = chunk_end;
    else
        st = st + stride_detect;
    end
    
end
i = 1;
%ripple duration condition check
while i <= length(start_times)
    if (end_times(i) - start_times(i)) < min_duration || (end_times(i) - start_times(i)) > max_duration
        start_times = [start_times(1:i-1) ; start_times(i+1:length(start_times))];
        end_times = [end_times(1:i-1) ; end_times(i+1:length(end_times))];
        i = i - 1;
    end
    i = i + 1;
end

for i = 1:length(start_times)
    [~,idx] = max(signal_bp(ceil(start_times(i) * fs_new) : ceil(end_times(i) * fs_new)));
    max_times(i) = start_times(i) + (idx-1)/fs_new;
end
%forming the ripple structure with relevant fields
for i = 1:length(start_times)
    st_idx = find(timestamps == start_times(i));
    end_idx = find(timestamps == end_times(i));
    temp =  signal_bp(ceil(start_times(i) * fs_new) : ceil(end_times(i) * fs_new));
    amp_criteria = amplitude_checker(temp,threshold_amplitude,window_detect_time * fs_new,stride_limit_time * fs_new,threshold_ratio_amplitude);
    ripple_all(i).channel = channel;
    ripple_all(i).start_time_original = timestamps_original(st_idx);
    ripple_all(i).end_time_original = timestamps_original(end_idx);
    ripple_all(i).start_time_nrem = timestamps(st_idx);
    ripple_all(i).end_time_nrem = timestamps(end_idx);
    ripple_all(i).signal_raw = raw_signal(start_times(i) * fs : end_times(i) *fs);
    ripple_all(i).signal_bp = temp;
    ripple_all(i).peak_time = max_times(i);
    ripple_all(i).mean_freq = meanfreq(temp,fs_new);
    ripple_all(i).amplitude_criteria = amp_criteria;
end
if isempty(start_times)
    ripple_all = [];
end

end
