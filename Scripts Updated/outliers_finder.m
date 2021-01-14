function outlier = outliers_finder(fs,path,channel,states,pt5)
%path:- main path of the aux channel data
%fs:- original sampling frequency
%channel:- array containing the channels of the used tetrode
%states:- sleep scores of the sleep
%pt5:- 0 if it isn't pt5 data, else the corresponding part of post trial 5 (ex: pt5 = 2 if the sleep is
%pt5.2)
%Output:-
%Gives the electrical noise related output

e_t=1;
e_samples=e_t*fs; 
states = states(1:min(length(states),2700));
vec_bin=states;
vec_bin(vec_bin~=3)=0;
vec_bin(vec_bin==3)=1;
v2=ConsecutiveOnes(vec_bin);
v_index=find(v2~=0);
v_values=v2(v2~=0);
outlier_all = zeros(1,length(find(vec_bin)==1)); %Lenght of NREM


    %Iterate through channels
    parfor i = 1:length(channel)
        if isfile(strcat(path,'\100_CH',num2str(channel(i)),'.mat'))
            PFC = load(strcat(path,'\100_CH',num2str(channel(i)),'.mat'),'data');
            PFC = PFC.('data');
        else
            name = strcat(path,'100_CH' , num2str(channel(i)) ,'.continuous');
            [PFC, ~, ~] = load_open_ephys_data(name);
        end
        
        if pt5
            PFC= PFC((pt5-1) * 2700 * fs + 1 : min(pt5 * 2700 * fs , length(PFC)));
        else
            PFC = PFC(1:min(length(states) * fs,length(PFC)));
        end

        
        ch=length(PFC);
        nc=floor(ch/e_samples); %Number of epochs
        epochs=[];
        
        %Iterate through 1sec epochs (Regardless of sleep stage)
        for j=1:nc
            epochs{j}= PFC(1+e_samples*(j-1):e_samples*j);
        end
        nrem_epochs = {};
        
        %Iterate through NREM bouts
        for j = 1:length(v_index)
            nrem_epochs = [nrem_epochs epochs{v_index(j) : v_index(j) + v_values(j) - 1}];
        end

        %Outlier removal
        %The maximum values of the raw signal are used epochwise to find the outliers
        
        max_epochs = cellfun(@max,cellfun(@abs,nrem_epochs,'UniformOutput',false));     
        outlier_epochs = isoutlier(max_epochs,'median','ThresholdFactor',10); 
        outlier_all = outlier_all + outlier_epochs;
        
    end


outlier_all = logical(outlier_all);
outlier = find(outlier_all == 1);
end
