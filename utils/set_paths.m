
user_path = 'C:\Users\User\Documents\MATLAB\prepro-LEMON'; %replaced user path with 'user'
data_path = [user_path '\EEG_data\data_for_test\'];
eegpath = [data_path 'RSEEG\'];
results_path = [user_path '\results\data_for_test\'];
prep_path = [results_path 'preprocessed\'];
plots_path = [results_path 'plots\'];
report_path = [results_path 'reports\'];

mkdir(results_path);
mkdir(prep_path);
mkdir(plots_path);
mkdir(report_path);