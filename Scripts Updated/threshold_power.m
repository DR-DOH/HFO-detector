function threshold_min = threshold_power(fs,signal,window,stride,sd_min)
%Function that returns a power threshold band that would serve as a threshold criteria
%inputs:-sd_max and sd_min are standard deviation parameters used
signal(isnan(signal)) = 0;
flag = 1;
window_power = [];
stride = stride * fs;
window = window * fs;
st = 1;
et = window;
%A moving window travels throughout the original array and we find the window power and save it in an
%array. The mean + threshold parameter * standard deviation is out power threshold
while flag
    window_power = [window_power bandpower(signal(st:et),fs,[100 300])];
    st = st + stride;
    et = min(st + window , length(signal));
    if et == length(signal)
        flag = 0;
    end
end
threshold_min = mean(window_power) + sd_min*std(window_power);

end