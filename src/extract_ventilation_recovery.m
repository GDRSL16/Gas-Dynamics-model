function [Breaths, Intervals] = extract_ventilation_recovery(modelName, profileName, summaryFile, breathFile, diveSummaryFile, storesFile, outputFile)
% EXTRACT_VENTILATION_RECOVERY  Read-only analysis of saved gas dynamics output.
%  Model name: 'A' ... 'H'; profile: 'shallow','intermediate','deep'.
%  summaryFile: model_outputs/*-summary-array.txt (27 columns, two header rows)
%  breathFile: 2-column time/breath-flag CSV with one header row
%  diveSummaryFile: original 13-column dive summary CSV (SI start/end in cols 3/4)
%  storesFile: optional model_outputs/*-STORES.txt (10 columns; one header row)
%  outputFile: Excel workbook path. No model variables are changed.
%
% Example:
% extract_ventilation_recovery('A','intermediate', ...
%   '14-intermediate-summary-array.txt', ...
%   '14-intermediate_10x1200s_400m_breath_flag.csv', ...
%   '14-intermediate_10x1200s_400m_summary.csv', ...
%   '14-intermediate-STORES.txt','recovery_A_intermediate.xlsx');
%
% IMPORTANT: This assumes the dive summary's columns 3 and 4 give inclusive
% surface interval row indices, as described in the existing model.
% Check the printed alignment diagnostics before interpreting results.

if nargin < 6, storesFile = ''; end
if nargin < 7 || isempty(outputFile)
    outputFile = sprintf('recovery_%s_%s.xlsx',modelName,profileName);
end

S = readmatrix(summaryFile,'FileType','text');
S = S(all(isfinite(S(:,1:min(22,size(S,2)))),2),:);
assert(size(S,2)>=25,'SUMMARY_ARRAY requires at least 25 columns.');
N=size(S,1);
B=readmatrix(breathFile,'NumHeaderLines',1);
assert(size(B,2)>=2,'Breath file must contain time and flag columns.');
assert(size(B,1)==N,'Breath rows (%d) do not match summary rows (%d).',size(B,1),N);
flag=B(:,2);
assert(all(flag==0 | flag==1),'Breath flags must be 0 or 1.');
D=readmatrix(diveSummaryFile,'NumHeaderLines',1);
D=D(all(isfinite(D(:,1:min(4,size(D,2)))),2),:);
assert(size(D,2)>=4,'Dive summary needs SI start/end columns 3 and 4.');

% Existing model header: N2 cols 1:5, O2 6:10, CO2 11:15;
% arterial/venous O2 18:19, CO2 20:21, pressure 22,
% alveolar and tracheal volume 23:24.
labels={'Heart','Muscle','Brain','Fat','Lung'};
siStart=round(D(:,3)); siEnd=round(D(:,4));
valid=(siStart>=1 & siEnd<=N & siEnd>=siStart);
if ~all(valid)
    warning('Skipping %d invalid surface intervals.',sum(~valid));
end
siStart=siStart(valid); siEnd=siEnd(valid);

haveStores=~isempty(storesFile) && isfile(storesFile);
if haveStores
    ST=readmatrix(storesFile,'FileType','text');
    ST=ST(all(isfinite(ST(:,1:min(10,size(ST,2)))),2),:);
    assert(size(ST,1)==N && size(ST,2)>=10, ...
        'STORES must have N rows and 10 columns.');
end

% Build one record for each breath occurring within a summary-defined SI.
rec=[];
for k=1:numel(siStart)
    b=find(flag(siStart(k):siEnd(k))==1)+siStart(k)-1;
    for j=1:numel(b)
        r=b(j);
        if r<=1, continue; end
        rec(end+1,:)=[k,j,numel(b),r-1,r]; %#ok<AGROW>
    end
end
if isempty(rec), error('No breaths found inside the summary-defined surface intervals. Check indices.'); end

Breaths=table(repmat(string(modelName),size(rec,1),1), ...
    repmat(string(profileName),size(rec,1),1),rec(:,1),rec(:,2),rec(:,3),rec(:,4),rec(:,5), ...
    'VariableNames',{'Model','Profile','SI_Number','Breath_Number','Breaths_In_SI','BeforeStep','AtBreathStep'});
pre=rec(:,4); post=rec(:,5);
for gas=1:2
    if gas==1, base=5; prefix='O2'; else, base=10; prefix='CO2'; end
    for c=1:5
        nm=sprintf('%s_%s',prefix,labels{c});
        Breaths.([nm '_Before_atm'])=S(pre,base+c);
        Breaths.([nm '_After_atm'])=S(post,base+c);
    end
    if gas==1, ac=18; else, ac=20; end
    Breaths.([prefix '_Art_Before_atm'])=S(pre,ac);
    Breaths.([prefix '_Art_After_atm'])=S(post,ac);
    Breaths.([prefix '_Ven_Before_atm'])=S(pre,ac+1);
    Breaths.([prefix '_Ven_After_atm'])=S(post,ac+1);
end
Breaths.LungVolume_Before_L=S(pre,23)+S(pre,24);
Breaths.LungVolume_After_L=S(post,23)+S(post,24);
Breaths.Pamb_atm=S(post,22);

storeNames={'O2_Muscle','O2_Tissue','O2_Arterial','O2_Venous','O2_Lung', ...
            'CO2_Muscle','CO2_Tissue','CO2_Arterial','CO2_Venous','CO2_Lung'};
if haveStores
    for c=1:10
        Breaths.([storeNames{c} '_Before'])=ST(pre,c);
        Breaths.([storeNames{c} '_After'])=ST(post,c);
    end
end

% Interval endpoints: surface start, surface end, and the next dive start.
K=numel(siStart);
Intervals=table(repmat(string(modelName),K,1),repmat(string(profileName),K,1), ...
    (1:K)',siStart,siEnd,siEnd-siStart+1, ...
    'VariableNames',{'Model','Profile','SI_Number','SI_StartStep','SI_EndStep','SI_Rows'});
for gas=1:2
    if gas==1, base=5; prefix='O2'; else, base=10; prefix='CO2'; end
    for c=1:5
        nm=sprintf('%s_%s',prefix,labels{c});
        Intervals.([nm '_Start_atm'])=S(siStart,base+c);
        Intervals.([nm '_End_atm'])=S(siEnd,base+c);
    end
    if gas==1, ac=18; else, ac=20; end
    Intervals.([prefix '_Art_Start_atm'])=S(siStart,ac);
    Intervals.([prefix '_Art_End_atm'])=S(siEnd,ac);
    Intervals.([prefix '_Ven_Start_atm'])=S(siStart,ac+1);
    Intervals.([prefix '_Ven_End_atm'])=S(siEnd,ac+1);
end
Intervals.BreathCount=arrayfun(@(k)sum(flag(siStart(k):siEnd(k))==1),(1:K)');
if haveStores
    for c=1:10
        Intervals.([storeNames{c} '_Start'])=ST(siStart,c);
        Intervals.([storeNames{c} '_End'])=ST(siEnd,c);
    end
end

% Create focused, descriptive output sheets. All values are sampled from
% the existing saved outputs; no model calculation is modified.
meta=Breaths(:,{'Model','Profile','SI_Number','Breath_Number','Breaths_In_SI','BeforeStep','AtBreathStep'});
position=strings(height(Breaths),1);
for q=1:height(Breaths)
    if Breaths.Breath_Number(q)==1
        position(q)="First";
    elseif Breaths.Breath_Number(q)==Breaths.Breaths_In_SI(q)
        position(q)="Last";
    elseif Breaths.Breath_Number(q)==ceil(Breaths.Breaths_In_SI(q)/2)
        position(q)="Middle";
    else
        position(q)="Other";
    end
end
meta.BreathPosition=position;
meta=movevars(meta,'BreathPosition','After','Breaths_In_SI');

EndTidal=meta;
PostBreath=meta;
for gas=1:2
    if gas==1, prefix='O2'; else, prefix='CO2'; end
    for c=1:5
        name=sprintf('%s_%s',prefix,labels{c});
        EndTidal.([name '_Tension_PreBreath_atm'])=Breaths.([name '_Before_atm']);
        PostBreath.([name '_Tension_PostBreath_atm'])=Breaths.([name '_After_atm']);
    end
    for loc={'Art','Ven'}
        name=[prefix '_' loc{1}];
        EndTidal.([name '_Tension_PreBreath_atm'])=Breaths.([name '_Before_atm']);
        PostBreath.([name '_Tension_PostBreath_atm'])=Breaths.([name '_After_atm']);
    end
end
EndTidal.LungVolume_PreBreath_L=Breaths.LungVolume_Before_L;
PostBreath.LungVolume_PostBreath_L=Breaths.LungVolume_After_L;
EndTidal.DryAmbientPressure_atm=S(pre,22);
PostBreath.DryAmbientPressure_atm=S(post,22);

StoresBefore=meta;
if haveStores
    for c=1:10
        StoresBefore.([storeNames{c} '_PreBreath_L_STPD'])=ST(pre,c);
    end
end

% Surface interval summary:
% Retain gas tensions and one set of gas stores.
% Remove duplicate store columns without changing their values.

SurfaceRecovery = Intervals;

if haveStores
    for c = 1:10
        oldStart = [storeNames{c} '_Start'];
        oldEnd   = [storeNames{c} '_End'];

        newStart = [storeNames{c} '_Start_L_STPD'];
        newEnd   = [storeNames{c} '_End_L_STPD'];

        SurfaceRecovery.Properties.VariableNames{ ...
            strcmp(SurfaceRecovery.Properties.VariableNames,oldStart)} = newStart;

        SurfaceRecovery.Properties.VariableNames{ ...
            strcmp(SurfaceRecovery.Properties.VariableNames,oldEnd)} = newEnd;
    end
end
% Keep the original interval data in SurfaceRecovery for continuity.

variable={}; meaning={}; units={};
for q=1:width(EndTidal)
    name=EndTidal.Properties.VariableNames{q};
    variable{end+1,1}=['EndTidal_BeforeBreath: ' name]; %#ok<AGROW>
    if contains(name,'Lung_Tension'), desc='Lung gas partial pressure immediately before the scheduled breath (model-derived end-tidal proxy)';
    elseif contains(name,'_Tension_'), desc='Blood or tissue gas tension immediately before the scheduled breath';
    elseif contains(name,'LungVolume'), desc='Total lung volume immediately before the breath, at modeled physiological conditions';
    elseif contains(name,'Pressure'), desc='Dry ambient pressure at the pre-breath time step';
    else, desc='Breath identifier or time-step index'; end
    meaning{end+1,1}=desc; %#ok<AGROW>
    if endsWith(name,'_atm'), units{end+1,1}='atm'; elseif endsWith(name,'_L'), units{end+1,1}='L'; else, units{end+1,1}='index / label'; end %#ok<AGROW>
end
for q=1:width(StoresBefore)
    name=StoresBefore.Properties.VariableNames{q};
    if ~contains(name,'_L_STPD'), continue; end
    variable{end+1,1}=['Stores_BeforeBreath: ' name]; %#ok<AGROW>
    if contains(name,'_Tissue_'), desc='Combined heart + muscle + brain + fat store; already includes muscle';
    elseif contains(name,'_Muscle_'), desc='Muscle store shown separately; DO NOT add to total tissue store';
    elseif contains(name,'_Arterial_') || contains(name,'_Venous_'), desc='Arterial or venous blood store estimate; not necessarily additive to whole-blood total';
    else, desc='Lung gas store'; end
    meaning{end+1,1}=desc; units{end+1,1}='L STPD'; %#ok<AGROW>
end
variable(end+1,1)={'Surface_Recovery'}; meaning(end+1,1)={'Start and end of each summary-defined surface interval; tension values in atm and store values in L STPD'}; units(end+1,1)={'mixed'};
variable(end+1,1)={'PostBreath_Check'}; meaning(end+1,1)={'Values at the breath event, after the modeled ventilation update; not end-tidal measurements'}; units(end+1,1)={'atm / L'};
Guide=table(string(variable),string(meaning),string(units),'VariableNames',{'Column','Meaning','Units'});

for k=1:K
    if k<=3
        fprintf('SI %d: rows %d-%d; %d breaths; Pamb start/end %.6f/%.6f atm\n', ...
            k,siStart(k),siEnd(k),Intervals.BreathCount(k),S(siStart(k),22),S(siEnd(k),22));
    end
end
fprintf('Extracted %d breaths in %d surface intervals. STORES present: %d\n',height(Breaths),K,haveStores);
% Remove an existing workbook so that obsolete sheets cannot linger.
if isfile(outputFile), delete(outputFile); end
writetable(EndTidal,outputFile,'Sheet','EndTidal_BeforeBreath');
writetable(StoresBefore,outputFile,'Sheet','Stores_BeforeBreath');
writetable(SurfaceRecovery,outputFile,'Sheet','Surface_Recovery');
writetable(Guide,outputFile,'Sheet','Column_Guide');
writetable(PostBreath,outputFile,'Sheet','PostBreath_Check');
fprintf('Saved %s\n',outputFile);
end
