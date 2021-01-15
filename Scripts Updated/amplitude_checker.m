function val = amplitude_checker(temp,threshold_amplitude,window,stride,threshold_ratio_amplitude)
%To check whether the a certain percentage of peaks cross the threshold limit or not, outputting a binary
%value
val = 0;
i = 1;
while i <= length(temp) + 1 - window
    if threshold_peak_ratio(temp(i:i+window-1),threshold_amplitude) >= threshold_ratio_amplitude
        val = 1;
        break;
    end
    
    i = i + stride;
    
end

end
