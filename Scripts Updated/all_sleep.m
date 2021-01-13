function all_sleep(path_main,state_path,fs,fs_new,rat,sd,channels,tetrodes)

%input:-
%path_main:- The path which contains recordings of all sleep trials folder wise
%state_path:- The path that contains the sleep scoring files
%fs:- original sampling freq
%fs_neww:- downsampled freq
%rat:- rat number
%sd:- study day number
%channels:- cell array with each element being an array of channels of each tetrode
%tetrodes:- cell array with tetrode numbers

%output:-
%outer function to loop around in the main script so that it can save the ripple detections

sleep = {{'Presleep','presleep'} , {'post_Trial1','post_trial1'} , {'post_Trial2','post_trial2'} , {'post_Trial3','post_trial3'} , {'post_Trial4','post_trial4'}} ;
sleep_names = {'PRE','PT1','PT2','PT3','PT4'};

%Iterate through trials.
parfor a = 1:length(sleep)
    %Fetch sleep scoring
    filename = getstates(state_path,sleep{a});
    states = load(strcat(state_path,filename),'states');
    states = states.states;
    %Fetch trial folder name        
    fold = getfoldername(path_main,sleep{a});
    %Run detection on all tetrodes            
    tic
    all_tetrodes(strcat(path_main,fold,'\'),channels,fs,fs_new,states,0,rat,sd,sleep_names{a},tetrodes);
    toc
end

end
