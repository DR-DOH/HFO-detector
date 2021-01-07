function all_sleep(path_main,state_path,fs,fs_new,rat,sd,channels,tetrodes)

sleep = {{'Presleep','presleep'} , {'post_Trial1','post_trial1'} , {'post_Trial2','post_trial2'} , {'post_Trial3','post_trial3'} , {'post_Trial4','post_trial4'}} ;
sleep_names = {'PRE','PT1','PT2','PT3','PT4'};

parfor a = 1:length(sleep)
    filename = getstates(state_path,sleep{a});
    states = load(strcat(state_path,filename),'states');
    states = states.states;
    fold = getfoldername(path_main,sleep{a});
    tic
    all_tetrodes(strcat(path_main,fold,'\'),channels,fs,fs_new,states,0,rat,sd,sleep_names{a},tetrodes);
    toc
end

end
