function val = amplitude_checker(signal,threshold,window,stride,threshold_ratio)
%To check whether the a certain percentage of peaks cross the threshold limit or not, outputting a binary
%value
val = 0;
i = 1;
while i <= length(signal) + 1 - window
    if threshold_peak_ratio(signal(i:i+window-1),threshold) >= threshold_ratio
        val = 1;
        break;
    end
    
    i = i + stride;
    
end

end