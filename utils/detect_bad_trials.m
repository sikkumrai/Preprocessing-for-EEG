function badtrials = detect_bad_trials(outdir, data)
trials = (1:data.trials)';
for trial = 1:data.trials
     trial_data = squeeze(data.data(:, :, trial)); % Extract data for the current trial   
     vartrials(trial) = var(trial_data(:)); 
end
outliers = isoutlier(vartrials); %outside of 3 scaled abs deviations from the median
badtrials = trials(outliers);
bad_trials_fig = figure('visible','on');
hold on
plot(1:data.trials,vartrials,'o')
plot(find(outliers),vartrials(outliers),'or')
xlabel('Trials')
ylabel('Variance')
title('Variance of trials')

if ~isfolder(outdir)
    mkdir(outdir)
end
saveas(bad_trials_fig,[outdir 'bad_trials.png'])
clearvars vartrials nbad