function [one,two,three,four,ripple_all] = ratio_tetrode_power(path,channel,fs,fs_new,states,pt5)
%input:-
%path:- main path of the aux channel data
%channel:- array containing the channels of the used tetrode
%fs:- original sampling frequency
%fs_new:- downsampled frequency
%states:- sleep scores of the sleep
%pt5:- 0 if it isn't pt5 data, else the corresponding part of post trial 5 (ex: pt5 = 2 if the sleep is
%pt5.2)

%output:-
%one,two,three,four are the co-occuring ripples occuring at one channel, two channel,three channels, four
%channels at the same time as a structure containing the ripple details
%ripple_all gives the ripples detected across all the channels
window_detect = 0.04;
stride = 0.01;
threshold_amp = 5;

warning('off','all')
tic

ripple_all = {};

Wn=[fs_new/fs ]; % Cutoff=fs_new/2 Hz.
[b,a] = butter(3,Wn); %Filter coefficients for LPF.

Wn1=[101/(fs_new/2) 299/(fs_new/2)]; % Cutoff=101-299 Hz
[b1,a1] = butter(3,Wn1,'bandpass'); %Filter coefficients

%LPF 300 Hz:
Wn1=[320/(fs_new/2)]; % Cutoff=320 Hz
[b2,a2] = butter(3,Wn1); %Filter coefficients

notch1 = designfilt('bandstopiir','FilterOrder',4,'HalfPowerFrequency1',149,'HalfPowerFrequency2',151,'DesignMethod','butter','SampleRate',fs_new);
notch2 = designfilt('bandstopiir','FilterOrder',4,'HalfPowerFrequency1',199,'HalfPowerFrequency2',201,'DesignMethod','butter','SampleRate',fs_new);
notch3 = designfilt('bandstopiir','FilterOrder',4,'HalfPowerFrequency1',249,'HalfPowerFrequency2',251,'DesignMethod','butter','SampleRate',fs_new);

states = states(1:min(length(states),2700));
vec_bin=states;
outliers = outliers_finder(fs,path,channel,states,pt5);
outliers_aux = aux_outliers(path,fs,states,pt5);
outliers = [outliers outliers_aux];
outliers = unique(sort(outliers));
vec_bin(vec_bin~=3)=0;
vec_bin(vec_bin==3)=1;


%Cluster one values:
v2=ConsecutiveOnes(vec_bin);
v_index=find(v2~=0);
v_values=v2(v2~=0);

if isempty(v_index)
    one = [];
    two = [];
    three = [];
    four = [];
else

    %loading the channel data
    parfor i = 1:length(channel)
        name = strcat(path ,'100_CH' , num2str(channel(i)), '.continuous');
        [PFC, ti, ~] = load_open_ephys_data(name);
        if pt5
            PFC_raw = PFC((pt5-1) * 2700 * fs + 1 : min(pt5 * 2700 * fs , length(PFC)));
            ti  = ti((pt5-1) * 2700 * fs + 1 : min(pt5 * 2700 * fs , length(ti)));
        else
            PFC_raw = PFC(1:min(length(states) * fs,length(PFC)));
            ti = ti(1:min(length(states) * fs,length(ti)));
        end
        PFC=filtfilt(b,a,PFC_raw);
        PFC=downsample(PFC,fs/fs_new);
        ti = downsample(ti,fs/fs_new);

        %Convert signal to 1 sec epochs.
        e_t=1;
        e_samples=e_t*fs_new; %fs=1kHz
        e_samples_raw = e_t*fs;
        ch=length(PFC);
        nc=floor(ch/e_samples); %Number of epochs
        NC2=[];
        raw_all = [];
        ti_all = [];
        
        for kk=1:nc
            NC2(:,kk)= PFC(1+e_samples*(kk-1):e_samples*kk);
            raw_all(:,kk)= PFC_raw(1+e_samples_raw*(kk-1):e_samples_raw*kk);
            ti_all(:,kk)= ti(1+e_samples*(kk-1):e_samples*kk);
        end
        %taking only nrem epochs
        v_pfc = {};
        raw_nrem = {};
        ti_nrem = {};
        for epoch_count=1:length(v_index)
            v_pfc{epoch_count,1}=reshape(NC2(:, v_index(epoch_count):v_index(epoch_count)+(v_values(1,epoch_count)-1)), [], 1);
            raw_nrem{epoch_count,1}=reshape(raw_all(:, v_index(epoch_count):v_index(epoch_count)+(v_values(1,epoch_count)-1)), [], 1);
            ti_nrem{epoch_count,1}=reshape(ti_all(:, v_index(epoch_count):v_index(epoch_count)+(v_values(1,epoch_count)-1)), [], 1);
        end
        
        %Ripple detection
        
        V_pfc=cellfun(@(equis) filtfilt(b2,a2,equis), v_pfc ,'UniformOutput',false);
        Mono_pfc=cellfun(@(equis) filtfilt(b1,a1,equis), V_pfc ,'UniformOutput',false); %101-299 Hz
        notch1_pfc=cellfun(@(equis) filtfilt(notch1,equis), Mono_pfc ,'UniformOutput',false);
        notch2_pfc=cellfun(@(equis) filtfilt(notch2,equis), notch1_pfc ,'UniformOutput',false);
        notch3_pfc=cellfun(@(equis) filtfilt(notch3,equis), notch2_pfc ,'UniformOutput',false);
        signal2_pfc=cellfun(@(equis) times((1/0.195), equis)  ,notch3_pfc,'UniformOutput',false); %Remove convertion factor for ripple detection
        
        %%
        
        % Cortical ripples
        signal_nrem = cat(1,signal2_pfc{:});
        raw_nrem = cat(1,raw_nrem{:});
        ti_nrem = cat(1,ti_nrem{:});
        %outlier removal
        if ~isempty(outliers)
            signal = signal_nrem(1:(outliers(1) - 1)*fs_new);
            ti_original = ti_nrem(1:(outliers(1) - 1)*fs_new);
            raw_signal = raw_nrem(1:(outliers(1) - 1)*fs);
            for j = 1:length(outliers)-1
                signal = [signal ; signal_nrem(outliers(j) * fs_new + 1 : (outliers(j+1)-1)*fs_new)];
                ti_original = [ti_original ; ti_nrem(outliers(j) * fs_new + 1 : (outliers(j+1)-1)*fs_new)];
                raw_signal = [raw_signal ; raw_nrem(outliers(j) * fs + 1 : (outliers(j+1)-1)*fs)];
            end
            signal = [signal; signal_nrem(outliers(end) * fs_new + 1 : end)];
            ti_original = [ti_original; ti_nrem(outliers(end) * fs_new + 1 : end)];
            raw_signal = [raw_signal ; raw_nrem(outliers(end) * fs + 1 : end)];
        else
            signal = signal_nrem;
            raw_signal = raw_nrem;
            ti_original = ti_raw;
        end
        ti = linspace(1/fs_new,length(signal)/fs_new,length(signal)).';
        thresh_power = threshold_power(fs_new,signal,window_detect,stride,5);
        ripple_all{i} = moving_window_ripples_power(channel(i),fs,raw_signal,fs_new,signal,ti_original,ti,thresh_power,threshold_amp);
        
    end
    %finding the ripple co-occurances
    if isempty(ripple_all)
        one = [];
        two = [];
        three = [];
        four = [];
    elseif length([ripple_all{:}]) == 1
        one = cell2mat(ripple_all);
        one.mean_freq_ave = one.mean_freq;
        two = [];
        three = [];
        four = [];
    else
        [one,two,three,four] = tetrode_ripples(ripple_all);
    end
end
toc
end
