function ratio = threshold_peak_ratio(signal,threshold_amplitude)

        de = diff(signal);
        de1 = [de;0];
        de2 = [0;de];
        vecount = [1:length(signal)].';
        upPeaksIdx=vecount(de1 < 0 & de2 > 0);
        downPeaksIdx = vecount(de1 > 0 & de2 < 0);
        PeaksIdx = [upPeaksIdx ;downPeaksIdx];
        PeaksIdx = sort(PeaksIdx);        
        Peaks = signal(PeaksIdx);
        Peaks = abs(Peaks);
        ratio = length(find(Peaks > threshold_amplitude))/length(Peaks);
        
end