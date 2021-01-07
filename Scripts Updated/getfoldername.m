function fold =getfoldername(path,str)

A = dir(path);
A = A(~ismember({A.name},{'.','..'})); %Remove dots
A = A([A.isdir]); %Only folders.
A = {A.name};
fold = A(or(cellfun(@(x) ~isempty(strfind(x,str{1})),A),cellfun(@(x) ~isempty(strfind(x,str{2})),A)));
fold = cell2mat(fold);

end
