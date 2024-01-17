%% Define Layout struct for the topomap
set_paths
addpath ('C:\Users\User\Documents\MATLAB\fieldtrip-20230125')
ft_defaults
load([data_path 'sub-032304.mat'])
load([data_path 'acticap-64ch-standard2.mat'])
EEG = pop_biosig([eegpath 'sub-032304.eeg']);
list1={'Fp1', 'Fp2', 'F7', 'F3', 'Fz', 'F4', 'F8', 'FC5', 'FC1', 'FC2', 'FC6', 'T7', 'C3', 'Cz', 'C4', 'T8', 'VEOG', 'CP5', 'CP1', 'CP2', 'CP6', 'AFz', 'P7', 'P3', 'Pz', 'P4', 'P8', 'PO9', 'O1', 'Oz', 'O2', 'PO10', 'AF7', 'AF3', 'AF4', 'AF8', 'F5', 'F1', 'F2', 'F6', 'FT7', 'FC3', 'FC4', 'FT8', 'C5', 'C1', 'C2', 'C6', 'TP7', 'CP3', 'CPz', 'CP4', 'TP8', 'P5', 'P1', 'P2', 'P6', 'PO7', 'PO3', 'POz', 'PO4', 'PO8'};
list2 = lay.label;



layout = struct();

% layout.outline = lay.outline;
% layout.mask = lay.mask;
% layout.cfg = lay.cfg;
layout.label = cell(EEG.nbchan,1);
layout.pos =zeros(62, 2);
layout.width = lay.width(1,1) * ones(size(layout.pos, 1), 1);
layout.height = lay.height(1,1) * ones(size(layout.pos, 1), 1); 
% Arrange list 2 based on the order of list 1
for i = 1:length(list1)
    index = find(strcmp(list1{i}, list2));
    layout.label{i} = EEG.chanlocs(i).labels;
    if ~isempty(index)    
        
        layout.pos(i,1)= lay.pos(index,1);
        layout.pos(i,2)= lay.pos(index,2);
    else
        %layout.label{i} = list1{i}; % Leave blank if no corresponding channel is found
        layout.pos(22,1)= (lay.pos(33,1)+lay.pos(34,1))/2;
        layout.pos(22,2)= (lay.pos(33,2)+lay.pos(34,2))/2;
        layout.pos(17,1)= (lay.pos(1,1)+lay.pos(2,1))/2;
        layout.pos(17,2)= (lay.pos(1,2)+lay.pos(2,2))/2;
    end
end

% Check the layout 
ft_plot_layout(layout);
% Save the layout
save('layout.mat', 'layout')
load('layout.mat')
