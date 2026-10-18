% Generate standardized 1-Hz dive input, summary and breath-event CSV files.
% No changes to the gas-dynamics model. Run from the directory containing this file.
% Each dive duration includes descent, bottom time, and ascent.
% Surface intervals: 10 s initially, then 180 s BETWEEN dives.
% Breaths occur at surface offsets 20,40,...,180 s (9 per interval).
% Assumed constant locomotion cost and ODBA from the supplied dummy input.
% Summary indices are inclusive MATLAB row numbers (not boundary markers).

profiles = { ...
    'shallow_20x600s_20m',       20, 600,   20; ...
    'intermediate_10x1200s_400m',10,1200,  400; ...
    'deep_5x3000s_1200m',        5,3000, 1200};
rate = 2;                  % m/s, both descent and ascent
initial_surface = 10;     % s
surface_between = 180;    % s
breath_interval = 20;     % s
odba = 0.095062223;       % g, from supplied dummy data
locomotion = 1;           % L O2/min, from supplied dummy data
sonar = 1;                % matches supplied dummy data

for p = 1:size(profiles,1)
    name = profiles{p,1}; nDives = profiles{p,2}; diveSec = profiles{p,3}; maxDepth = profiles{p,4};
    transit = maxDepth/rate;
    assert(transit == round(transit) && 2*transit <= diveSec, 'Invalid duration/rate');
    descent = (1:transit)' * rate;
    bottom = repmat(maxDepth, diveSec-2*transit, 1);
    ascent = maxDepth - (1:transit)' * rate;
    diveDepth = [descent; bottom; ascent];
    assert(numel(diveDepth)==diveSec && diveDepth(end)==0);
    depth = zeros(initial_surface,1);
    breathFlag = zeros(initial_surface,1);
    summary = zeros(nDives,12);
    for d = 1:nDives
        if d==1
            siStart=1; siEnd=initial_surface;
        else
            siStart=numel(depth)-surface_between+1; siEnd=numel(depth);
        end
        diveStart=numel(depth)+1;
        depth=[depth;diveDepth]; %#ok<AGROW>
        breathFlag=[breathFlag;zeros(diveSec,1)]; %#ok<AGROW>
        diveEnd=numel(depth);
        summary(d,:)=[d,siEnd-siStart+1,siStart,siEnd,locomotion,d,diveSec,diveStart,diveEnd,locomotion,maxDepth,mean(diveDepth)];
        if d<nDives
            surfaceStart=numel(depth)+1;
            depth=[depth;zeros(surface_between,1)]; %#ok<AGROW>
            newBreaths=zeros(surface_between,1);
            newBreaths(breath_interval:breath_interval:surface_between)=1;
            breathFlag=[breathFlag;newBreaths]; %#ok<AGROW>
        end
    end
    time=(1:numel(depth))';
    data=table(time,depth,repmat(odba,numel(depth),1),repmat(locomotion,numel(depth),1),repmat(sonar,numel(depth),1), ...
        'VariableNames',{'Time (s)','depth (m)','ODBA (g)','Locomotion cost (l O2/min)','sonar'});
    summaryT=array2table(summary,'VariableNames',{'Surface interval number','SI duration (s)','row start SI','row end SI', ...
        'mean CL (l O2/min)','dive number','dive duration (s)','row start of dive','row end of dive', ...
        'mean CL (l O2 /min)','max depth (m)','mean depth (m)'});
    summaryT.sonar=repmat(sonar,nDives,1);
    writetable(data,[name '_data.csv']);
    writetable(summaryT,[name '_summary.csv']);
    writetable(table(time,breathFlag,'VariableNames',{'TimeStep','BREATH_FLAG'}),[name '_breaths.csv']);
    fprintf('%s: %d rows, %d breaths\n',name,numel(depth),sum(breathFlag));
end
% The data and summary headers match the supplied dummy templates.
% Load the separate breath CSV into BREATH_FLAG before running the model.
