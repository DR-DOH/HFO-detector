function fold = getstates(path,str)

%function description:-
%To get the name of the states file using the main directory using name search for 2 values

%inputs:-
%path:- the path in which sleep scoring files of all sleep trials are stored
%str:- example {'post_trial2','post-trial2'} or {'ost-trial2','ost_trial2}

A = dir(path);
A=A(~ismember({A.name},{'.','..'})); %Remove dots
A={A.name};
A=A(cellfun(@(x) ~isempty(strfind(x,'-states')),A));
A=A(cellfun(@(x) ~isempty(strfind(x,'.mat')),A));
fold=A(or(cellfun(@(x) ~isempty(strfind(x,str{1})),A),cellfun(@(x) ~isempty(strfind(x,str{2})),A)));
if isempty(fold)
fold = A(or(cellfun(@(x) ~isempty(strfind(x,str{3})),A),cellfun(@(x) ~isempty(strfind(x,str{4})),A)));
end
fold = cell2mat(fold);

end
