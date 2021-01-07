function all_tetrodes(path,channels,fs,fs_new,states,pt5,rat,sd,sleep_name,tetrodes)
%path:- full path till location of channel recording
%channels:- cell array consisting of channels of all tetrodes individual each array consisting of
%channels of one tetrode
%tetrodes:- array of characters of tetrode number
parfor i = 1:length(channels)
    one_tetrode(path,channels{i},fs,fs_new,states,pt5,rat,sd,sleep_name,tetrodes{i});
end
end
