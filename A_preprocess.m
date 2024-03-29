main_dir = 'C:\Users\User\Documents\MATLAB\ProjectPTB\1\prepro\';
addpath([main_dir '\utils']);
set_paths
% FieldTrip
addpath ('C:\Users\User\Documents\MATLAB\fieldtrip-20230125')
ft_defaults
%EEGlab
addpath ('C:\Users\User\Documents\MATLAB\ProjectPTB\1\prepro\eeglab_current\eeglab2023.1\')
eeglab
% list of subjects
subjects = dir(eegpath);
subjects = subjects([subjects.isdir]);  % keep only directories
subjects = subjects(~ismember({subjects.name}, {'.', '..'}));  % remove '.' and '..'

%% read data
for i = 1:size(subjects)

    tic
    clear info
    subj = subjects(i).name;

    subj_list = dir([eegpath subj '\' '*.mat']); %checks if there is an .eeg file
    subj_eeg = subj_list(1).name;


    sub_report_path = [report_path subj(1:end-4) '\']; 
    mkdir (sub_report_path);

    load([eegpath subj '\' subj_eeg]);

    filepath = [eegpath subj '\' subj_eeg];
    
    data = eeglab2fieldtrip(EEG, 'raw', bone);    

    
    %% plot Raw data
    mkdir([plots_path subj]);
    plot_psd(EEG,'before', [plots_path subj]);     
    
 %% set preprocessing parameters
    cfg = [];
    cfg.datafile = filepath;
    cfg.layout = 'layout.mat'
   

    info.orig_sf = data.fsample;
    info.nchan = length(data.label);
    info.minutes = (size(data.time{1,1},2)/data.fsample)/60;


    time = data.time{1};
    epochLeng =2;
    %epochLeng = ((time(2)-time(1))*1000); % length of epochs in sec

    %some parameters for connectivity estimation
    lpFilter =   45;       % low-pass filter cut-off
    bsFilter =   [47 53];% additional notch filter 

    dsRate =  data.fsample/100;       % downsampling rate    

    %% zero-phase filtering

    [b_low, a_low] = butter(5, lpFilter/(data.fsample/2), 'low');
    [b_notch, a_notch] = butter(2, bsFilter/(data.fsample/2),'stop');
    a_all = poly([roots(a_low); roots(a_notch)]);
    b_all = conv(b_low, b_notch);
    data.trial{1} = filtfilt(b_all, a_all, double(data.trial{1})')';   

    % %% regress out EOG - 17
    % eogs = [17];
    % eeg_data = data.trial{1,1}';
    % eog_data = data.trial{1,1}(eogs,:)';
    % eeg_data = eeg_data - eog_data*(eog_data\eeg_data);
    % data.trial{1,1} = eeg_data';

    %% interpolate outlying channels
    % this part detects outlying channels 
    % (outliers: 3 scaled median deviations from the median)
    % and interpolates them using a weighted average of
    % neighbors
    layout = ft_prepare_layout(cfg,data);
    chanlist = 1:length(data.label);
    all_bad_ch = [];
    [interdata, bc] = detect_bad_channels(sub_report_path,chanlist, data, layout);
    all_bad_ch = [all_bad_ch;bc];
    info.badchans = all_bad_ch;
    clearvars bc

     %% downsampling
    data.xmin= 0;
    data.trial{1} = data.trial{1}(:, 1:dsRate:end);
    data.fsample = data.fsample/dsRate;
    data.pnts  = size(data.trial{1},2);
    data.xmax    = data.xmin + (data.pnts -1)/data.fsample;
    data.times  = linspace(data.xmin*1000, data.xmax*1000, data.pnts);
    %data = eeg_checkset( data );

    %% epoching
    [Nchan, Ntp]=size(data.trial{1});
    data = copy_fields(data, EEG);

    % 
    % save(fullfile(prep_path, 'data.mat'), 'data');
    % load(fullfile(prep_path, 'data.mat'));


    data = pop_select(data,'point',[1 (Ntp - mod(Ntp, data.fsample * epochLeng))] );
    Nepoch = data.pnts / (data.fsample * epochLeng);
    %data = eeg_checkset(data);
    for ievent = 1: Nepoch
        data.event(ievent).type = num2str(epochLeng);
        data.event(ievent).latency = (ievent-1)*(data.fsample *epochLeng)+1;
        data.event(ievent).duration = epochLeng;
    end
    data = eeg_checkset( data);
    data = pop_epoch( data, {  num2str(epochLeng)  }, [0  epochLeng], 'epochinfo', 'yes');

    save(fullfile(prep_path, 'data_epoched.mat'), 'data');
    load(fullfile(prep_path, 'data_epoched.mat'));

    info.ntri = data.trials;
    info.prestim = data.time{1,1}(1);
    info.poststim = data.time{1,1}(end);
    info.nsam = length(data.time{1,1})/data.fsample;

    %% reject outlier trials
    all_bad_tri = [];
    bt = detect_bad_trials(sub_report_path, data);
    all_bad_tri = [all_bad_tri;bt];
    all_bad_tri = unique(all_bad_tri);
    disp('bad trials:');
    fprintf(1, '%d \n', all_bad_tri);

    data.trial = data.data;

    cfg = [];
    cfg.trials = [1:data.trials];
    cfg.trials(all_bad_tri) = [];
    cfg.channel = 'eeg';
    data = ft_selectdata(cfg,data);
    info.badtrials = all_bad_tri;
    info.prcbadtri = length(all_bad_tri)/length(data.trial)*100;

    %% plot Preprocessed data

    plot_psd(data,'after', [plots_path subj]);



   %% finish and save report
    timer = toc;
    info.time = timer;
    ft_write_data([prep_path subj], data, 'dataformat','matlab')
    save([sub_report_path 'info.mat'],'info');
    % preproc_report(info,sub_report_path);
    % convert tex to pdf
    % command = ['cd ', sub_report_path,'; ', 'yes " " | /usr/bin/pdflatex  ',...
    %    'report.tex;'];
    % system(command);
    close all
end