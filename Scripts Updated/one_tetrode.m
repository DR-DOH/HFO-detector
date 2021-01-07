function one_tetrode(path,channels,fs,fs_new,states,pt5,rat,sd,sleep_name,tetrodes)
%path:- full path till location of channel recording
%channels:- array of channels of one tetrode (4 channels of the tetrode)
%tetrodes:- tetrode number
[one,two,three,four,ripple_all] = ratio_tetrode_power(path,channels,fs,fs_new,states,pt5);
save(strcat(rat,'_',sd,'_',sleep_name,'_',num2str(tetrodes),'.mat'),'one','two','three','four','ripple_all');

end
