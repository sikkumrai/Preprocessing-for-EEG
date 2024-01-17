function plot_freq_analysis(data,filename,dir)
    % Check the number of trials in the data structure
    numTrials = data.trials;

    if numTrials == 1
        % Single trial analysis
        freqData = struct();
        freqData.label = {data.chanlocs.labels};
        freqData.time = {data.times / 1000}; % Assuming data.times is in milliseconds
        freqData.trial = {single(data.data)};

        cfg = [];
        cfg.method = 'mtmfft';
        cfg.output = 'pow';
        cfg.taper = 'hanning';
        cfg.keeptrials = 'no'; % No need to keep trials for a single trial

        % Perform the frequency analysis
        freqanalysis = ft_freqanalysis(cfg, freqData);

        % Plot the frequency analysis
         psdB = figure ('visible','on');
         semilogy(freqanalysis.freq, freqanalysis.powspctrm);
         grid on;
         xlim([0 1300]);
         xlabel('Frequency (Hz)');
         ylabel('Power');
         saveas(psdB, fullfile(dir, ['PSD_' filename]), 'png');

         % Find the indices of frequencies for the delta, theta, alpha and beta bands
        freq_bounds = {find(freqanalysis.freq < 4), find((freqanalysis.freq > 4) & (freqanalysis.freq < 7)), find((freqanalysis.freq > 8) & (freqanalysis.freq < 13)), find((freqanalysis.freq > 14) & (freqanalysis.freq < 30))};
        fnames = {'delta', 'theta', 'alpha', 'beta'};
        
        
        % Define the configuration for the frequency analysis
        cfg = [];
        cfg.figure = 'gcf';
        cfg.baseline     = [-0.5 -0.3];
        cfg.baselinetype = 'absolute';
        cfg.marker       = 'on';
        cfg.layout       =  'layout.mat';
        
        
        topoB= figure ('Visible','on');
        for nfreq = 1:length(freq_bounds)
            temp_freq = freqanalysis; %Seperate each time struct temp_freq for each band
            temp_freq.freq = freqanalysis.freq(freq_bounds{nfreq});
            temp_freq.powspctrm = freqanalysis.powspctrm(:, freq_bounds{nfreq});    
            
            % Plot the topographic map
            subplot(2,2,nfreq)
            ft_topoplotTFR(cfg, temp_freq); colorbar
            title(['Topomap - ' fnames{nfreq}]);
        end
         saveas(topoB, fullfile(dir, ['topomap_' filename ]), 'png');


    else


        % Multi-trial analysis
        freqData = struct();
        freqData.label = {data.chanlocs.labels};
        freqData.time = cell(1, numTrials);
        freqData.trial = cell(1, numTrials);

        for ntri = 1:numTrials
            freqData.time{ntri} = data.times / 1000; % Convert times to seconds
            freqData.trial{ntri} = single(data.data(:, :, ntri));
        end

        cfg = [];
        cfg.method = 'mtmfft';
        cfg.output = 'pow';
        cfg.taper = 'hanning';
        cfg.keeptrials = 'yes';
        cfg.toi = 0:0.4:(data.pnts-1) / data.srate; % Assuming data.pnts is the number of points

        % Perform the frequency analysis
        freqanalysis = ft_freqanalysis(cfg, freqData);

        % Calculate average power across trials for each channel
        average_power = squeeze(mean(freqanalysis.powspctrm, 1));

        % Plot the frequency analysis
        psdA= figure('Visible','on');
        semilogy(freqanalysis.freq, average_power);
        grid on;
        xlabel('Frequency (Hz)');
        ylabel('Power');
        title('Power Spectral Density - AVG Trial');
        saveas(psdA, fullfile(dir, ['PSD_' filename]), 'png');


        freq_bounds = {find(freqanalysis.freq < 4), find((freqanalysis.freq > 4) & (freqanalysis.freq < 7)), find((freqanalysis.freq > 8) & (freqanalysis.freq < 13)), find((freqanalysis.freq > 14) & (freqanalysis.freq < 30))};
        fnames = {'delta', 'theta', 'alpha', 'beta'};
        
        
        % Define the configuration for the frequency analysis
        cfg = [];
        cfg.figure = 'gcf';
        cfg.baseline     = [-0.5 -0.3];
        cfg.baselinetype = 'absolute';
        cfg.marker       = 'on';
        cfg.layout       = 'layout.mat';
        
        
        topoA= figure
        for nfreq = 1:length(freq_bounds)
            temp_freq = freqanalysis; %Seperate each time struct temp_freq for each band
            temp_freq.freq = freqanalysis.freq(freq_bounds{nfreq});
            temp_freq.powspctrm = average_power(:, freq_bounds{nfreq});    
            
            % Plot the topographic map
            subplot(2,2,nfreq)
            ft_topoplotTFR(cfg, temp_freq); colorbar
            title(['Topomap - ' fnames{nfreq}])
        end
         saveas(topoA, fullfile(dir, ['topomap_' filename]), 'png');
end
