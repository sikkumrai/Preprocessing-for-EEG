 function data = copy_fields(data, EEG)
    % Copy specified fields from EEG to data
    data.srate= data.fsample;
    data.data = single(data.trial{1});
    data.nbchan= EEG.nbchan;
    data.trials = EEG.trials;
    data.chanlocs = EEG.chanlocs;
    data.chanifo = EEG.chaninfo;
    data.comments = EEG.comments;
    data.condition = EEG.condition;
    data.event = EEG.event;
    data.urevent = EEG.urevent;
    data.eventdescription = EEG.eventdescription;
    data.epoch = EEG.epoch;
    data.ref = EEG.ref;
    data.epochdescription = EEG.epochdescription;
    data.reject = EEG.reject;
    data.stats = EEG.stats;
    data.specdata = EEG.specdata;
    data.specicaact = EEG.specicaact;
    data.splinefile = EEG.splinefile;
    data.icasplinefile = EEG.icasplinefile;
    data.dipfit = EEG.dipfit;
    data.history = EEG.history;
    data.etc = EEG.etc;
    data.run = EEG.run;
    data.roi = EEG.roi;
    data.setname= EEG.setname;
    data.icachansind = EEG.icachansind;
    data.icaweights = EEG.icaweights;
    data.icasphere = EEG.icasphere;
    data.icawinv = EEG.icawinv;
    data.icaact = EEG.icaact; 
end