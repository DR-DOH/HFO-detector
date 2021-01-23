function threshold_min = threshold_power(fs,signal,window,stride,sd_min)
%Function that returns a power threshold band that would serve as a threshold criteria
%inputs:-sd_max and sd_min are standard deviation parameters used
signal(isnan(signal)) = 0;
% flag = 1;
window_pow = [];
stride = stride * fs;
window = window * fs;
% st = 1;
% et = window;
%A moving window travels throughout the original array and we find the window power and save it in an
%array. The mean + threshold parameter * standard deviation is out power threshold

parfor i = 1:floor((length(signal)-window)/stride) + 1

    window_pow(i) = bandpower(signal((i-1)*stride + 1 : signal((i-1))*stride + window),fs,[100 300]);

end
window_power = [window_pow bandpower(signal((floor((length(signal)-window)/stride) + 1)*stride + 1 : length(signal)),fs,[100 300])];
threshold_min = mean(window_power) + sd_min*std(window_power);

end