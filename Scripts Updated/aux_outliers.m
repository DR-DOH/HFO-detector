
function outliers_aux = aux_outliers(path,fs,states,pt5)
%Function to remove the outliers based on animal movement using the AUX channels
%Inputs:-
%path:- main path of the aux channel data
%fs:- original sampling frequency
%states:- sleep scores of the sleep
%pt5:- 0 if it isn't pt5 data, else the corresponding part of post trial 5 (ex: pt5 = 2 if the sleep is
%pt5.2)

%Output:-
%gives the movement related outliers
%Using only the NREM epochs
%Using NREM states and corresponding AUX channel data
states = states(1:min(length(states),2700));
vec_bin=states;
vec_bin(vec_bin~=3)=0;          
vec_bin(vec_bin==3)=1;

v2=ConsecutiveOnes(vec_bin);
v_index=find(v2~=0);
v_values=v2(v2~=0);
if isempty(v_index)
    outliers_aux = [];
else
    
    if isfile(strcat(path,'\100_AUX1.mat'))
        aux1 = load(strcat(path,'\100_AUX1.mat'),'data');
        aux1 = aux1.('data');
    else
        name = strcat(path,'100_AUX1.continuous');
        [aux1, ~, ~] = load_open_ephys_data(name);
    end
    
    if pt5
        aux1 = aux1((pt5-1) * 2700 * fs + 1 : min(pt5 * 2700 * fs , length(aux1)));
    else
        aux1 = aux1(1:min(length(states) * fs,length(aux1)));
    end
    
    if isfile(strcat(path,'\100_AUX2.mat'))
        aux2 = load(strcat(path,'\100_AUX2.mat'),'data');
        aux2 = aux2.('data');
    else
        name = strcat(path,'100_AUX2.continuous');
        [aux2, ~, ~] = load_open_ephys_data(name);
    end
    if pt5
        aux2 = aux2((pt5-1) * 2700 * fs + 1 : min(pt5 * 2700 * fs , length(aux2)));
    else
        aux2 = aux2(1:min(length(states) * fs,length(aux2)));
    end
    
    if isfile(strcat(path,'\100_AUX3.mat'))
        aux3 = load(strcat(path,'\100_AUX3.mat'),'data');
        aux3 = aux3.('data');
    else
        name = strcat(path,'100_AUX3.continuous');
        [aux3, ~, ~] = load_open_ephys_data(name);
    end
    if pt5
        aux3 = aux3((pt5-1) * 2700 * fs + 1 : min(pt5 * 2700 * fs , length(aux3)));
    else
        aux3 = aux3(1:min(length(states) * fs,length(aux3)));
    end
    e_t=1;
    e_samples_raw = e_t*fs;
    ch=length(aux1);
    nc=floor(ch/e_samples_raw); %Number of epochs
    NC=[];
    NC2=[];
    
    parfor kk=1:nc
        aux1_all(:,kk)= aux1(1+e_samples_raw*(kk-1):e_samples_raw*kk);
        aux2_all(:,kk)= aux2(1+e_samples_raw*(kk-1):e_samples_raw*kk);
        aux3_all(:,kk)= aux3(1+e_samples_raw*(kk-1):e_samples_raw*kk);
    end
    parfor epoch_count=1:length(v_index)
        aux1_nrem{epoch_count,1}=reshape(aux1_all(:, v_index(epoch_count):v_index(epoch_count)+(v_values(1,epoch_count)-1)), [], 1);
        aux2_nrem{epoch_count,1}=reshape(aux2_all(:, v_index(epoch_count):v_index(epoch_count)+(v_values(1,epoch_count)-1)), [], 1);
        aux3_nrem{epoch_count,1}=reshape(aux3_all(:, v_index(epoch_count):v_index(epoch_count)+(v_values(1,epoch_count)-1)), [], 1);
    end
    
    aux1_arr = cat(1,aux1_nrem{:});
    aux2_arr = cat(1,aux2_nrem{:});
    aux3_arr = cat(1,aux3_nrem{:});
    
    %Calculating the standard deviations epoch wise for the nrem part with each epoch being 1 second
    parfor i = 1:length(aux1_arr)/fs
        aux1_sd(i) = std(aux1_arr((i-1)*fs+1:i*fs));
        aux2_sd(i) = std(aux2_arr((i-1)*fs+1:i*fs));
        aux3_sd(i) = std(aux3_arr((i-1)*fs+1:i*fs));
    end
    %Cumulating the outliers from all the 3 aux channels
    outliers_aux1 = find(isoutlier(aux1_sd,'median')==1);
    outliers_aux2 = find(isoutlier(aux2_sd,'median')==1);
    outliers_aux3 = find(isoutlier(aux3_sd,'median')==1);
    
    outliers_aux = find(isoutlier(aux1_sd,'median','ThresholdFactor',8) + isoutlier(aux2_sd,'median','ThresholdFactor',8) + isoutlier(aux3_sd,'median','ThresholdFactor',8));
end
end