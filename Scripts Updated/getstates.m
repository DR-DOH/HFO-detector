function fold = getstates(path,str)

A = dir(path);
A=A(~ismember({A.name},{'.','..'})); %Remove dots
A={A.name};
A=A(cellfun(@(x) ~isempty(strfind(x,'-states')),A));
A=A(cellfun(@(x) ~isempty(strfind(x,'.mat')),A));
fold=A(or(cellfun(@(x) ~isempty(strfind(x,str{1})),A),cellfun(@(x) ~isempty(strfind(x,str{2})),A)));
fold = cell2mat(fold);

end
