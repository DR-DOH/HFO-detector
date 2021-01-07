function [ones,twos,threes,fours] = tetrode_ripples(ch)

% Input:-
% ch1,ch2,ch3,ch4 are ripple timestamps of 4 channels of the tetrode
% channel is a string array consisting of channel numbers

% Output:-
%one,two,three,four are the co-occuring ripples occuring at one channel, two channel,three channels, four
%channels at the same time as a structure containing the ripple details

max_difference = 0.125;     %ripples occuring within the max_difference duration would be considered as one ripple
ripples = [];
for x = 1:length(ch)
    if ~isempty(ch{x})
    ripples = [ripples ch{x}];
    end
end

temp = struct2table(ripples);
all_ripples = table2struct(sortrows(temp,'start_time_nrem'));

%%
i = 1;
%Ripples that co-occur are grouped together
ripple_grouped = {};
while i <= length(all_ripples)
    temp = i;
    group = [];
    while all_ripples(temp).start_time_nrem - all_ripples(i).start_time_nrem < max_difference
        group = [group all_ripples(temp)];
        temp = min(temp + 1,length(all_ripples)); 
        if temp == length(all_ripples)
            break;
        end      
    end
    i = temp;
    if i == length(all_ripples)
        break;
    end  
    ripple_grouped{end + 1} = group;
end
final = [];
%Updating all the relevant ripple details for the grouped ripples
for i = 1:length(ripple_grouped)
    ripple.amplitude_criteria = sum([ripple_grouped{i}.amplitude_criteria]);
    if ripple.amplitude_criteria
        signal_bp = {};
        signal_raw = {};
        ripple.time = min([ripple_grouped{i}.peak_time]);
        ripple.channels = [ripple_grouped{i}.channel];
        ripple.start_time_original = min([ripple_grouped{i}.start_time_original]);
        ripple.end_time_original = min([ripple_grouped{i}.end_time_original]);
        ripple.start_time_nrem = min([ripple_grouped{i}.start_time_nrem]);
        ripple.end_time_nrem = min([ripple_grouped{i}.end_time_nrem]);
        ripple.mean_freq = [ripple_grouped{i}.mean_freq];
        for j = 1:length(ripple_grouped{i})
            signal_bp{j} = ripple_grouped{i}(j).signal_bp;
            signal_raw{j} = ripple_grouped{i}(j).signal_raw;
        end
        ripple.signal_bp = signal_bp;
        ripple.signal_raw = signal_raw;
        ripple.mean_freq_ave = mean(ripple.mean_freq);
        final = [final ripple];
    end
end
if isempty(final)
    ones = [];
    twos = [];
    threes = [];
    fours = [];
else
    recurrance = cellfun(@length,cellfun(@unique,{final.channels},'UniformOutput',false),'UniformOutput',false);
    recurrance = cell2mat(recurrance);
    ones = final(find(recurrance >= 1));
    twos = final(find(recurrance >= 2));
    threes = final(find(recurrance >= 3));
    fours = final(find(recurrance >= 4));
end

end