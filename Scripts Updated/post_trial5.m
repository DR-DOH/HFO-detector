function post_trial5(path_main,state_path,fs,fs_new,rat,sd,channels,tetrodes)

sleep_names = {'PT5.1','PT5.2','PT5.3','PT5.4'};
filename = getstates(state_path,{'post_Trial5','post_trial5'});
states = load(strcat(state_path,filename),'states');
states = states.states;
states = states(1:min(length(states),10800));
fold = getfoldername(path_main,{'post_Trial5','post_trial5'});

parfor a = 1:length(sleep_names)
    all_tetrodes(strcat(path_main,fold,'\'),channels,fs,fs_new,states((a-1)*2700 + 1 : min(a*2700,length(states))),a,rat,sd,sleep_names{a},tetrodes);
end

end
