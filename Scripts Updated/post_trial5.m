function post_trial5(path_main,state_path,fs,fs_new,rat,sd,channels,tetrodes)

%input:-
%path_main:- The path which contains recordings of all PT5 in a folder
%state_path:- The path that contains the sleep scoring file of PT5
%fs:- original sampling freq
%fs_neww:- downsampled freq
%rat:- rat number
%sd:- study day number
%channels:- cell array with each element being an array of channels of each tetrode
%tetrodes:- cell array with tetrode numbers

%output:-
%outer function to loop around in the main script so that it can save the ripple detections for post trial 5, split into 4 sleep of 45mins eaach

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
