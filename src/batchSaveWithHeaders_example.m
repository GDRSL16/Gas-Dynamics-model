% batchSaveWithHeaders_example.m
% Example driver showing how to call saveTabWithHeader in a loop.
% Put this in the same folder and run it after your data for each iteration is
% created/populated into the relevant variables (SUMMARY_ARRAY, dADL, ...).

clearvars -except SUMMARY_ARRAY dADL QTOTARRAY STORES O2_CO2_N2_PP
% (you probably compute these inside the loop before saving)

% --- 1) Define filename prefixes (one per iteration) ---
prefixes = {
 '1-Zica-20191012-144029'
 '2-Zica-20191012-145101'
 '3-Zica-20191111-94810'
 '4-Zica-20191117-195993'
 '5-Zica-20211112-94819'
 '6-Zica-20211113-195993'
 '7-Zica-20220112-195994'
 '8-Zica-20230518-233391'
 '9-Zica-20230519-232950'
 '10-Zica-20230723-233394'
 '11-Zica-20240227-233396'
 '12-Zica-20240227-240128'
};

% --- 2) Define headers (use cell arrays of full lines) ---
headers.summary = {
    'N2\t\t\t\tO2\t\t\t\tCO2\t\t\t\tPN2-blood\tPO2-blood\tPCO2-blood\tPamb\tLung'
    'Heart\tMuscle\tBrain\tFat\tLung\tHeart\tMuscle\tBrain\tFat\tLung\tHeart\tMuscle\tBrain\tFat\tLung\tArt\tVen\tArt\tVen\tArt\tVen\tAlv\tTrac\tShunt\tODBA\tCOL'
};

headers.dADL = {
    'Pre dive\t\t\t\tPost-dive\t\t\t\tMR: l O2 min-1\t\t\t\tMuscle O2 store\t\tdADL\tdADL'
    'tissue O2 store\tlung O2 store\tblood O2 store\ttotal O2 store\tpre-dive surface interval\tPamb\ttissue O2 store\tlung O2 store\tblood O2 store\ttotal O2 store\theart\tmuscle\tbrain\tfat\ttotal MR-for past dive\tdive duration\tmax dive depth\tPamb post dive\tPre-dive\tPost-dive\tpre\tpost\tStart of dive (row num)\tEnd of dive (row num)'
};

headers.O2_CO2_N2_PP = {
    'Pre-dive-N2\t\t\tO2\t\t\tCO2\t\t\tPost-dive-N2\t\t\tO2\t\t\tCO2\t\t\t\tN2'
    'CC\tmuscle\tbrain\tfat\tCC\tmuscle\tbrain\tfat\tCC\tmuscle\tbrain\tfat\tCC\tmuscle\tbrain\tfat\tCC\tmuscle\tbrain\tfat\tCC\tmuscle\tbrain\tfat\tdive duration\tmax depth\tarterial\tvenous'
};

headers.QTOTARRAY = {
    'Dive Qtot\t\t\tSurface Qtot'
    'Total\tHeart\tMuscle\tBrain\tFat\tTotal\tHeart\tMuscle\tBrain\tFat'
};

headers.STORES = {
    'O2\t\t\tCO2'
    'Muscle\ttissue\tarterial\tvenous\tlung\tMuscle\ttissue\tarterial\tvenous\tlung'
};

% --- 3) Map variable names to suffixes and header fields ---
saveTable = {
    %- varname (string),    suffix,             headerField
    'SUMMARY_ARRAY',       '-summary-array.txt', 'summary';
    'dADL',                '-dADL.txt',         'dADL';
    'QTOTARRAY',           '-QTOTARRAY.txt',    'QTOTARRAY';
    'STORES',              '-STORES.txt',       'STORES';
    'O2_CO2_N2_PP',        '-O2_CO2_N2_PP.txt', 'O2_CO2_N2_PP';
};

% --- 4) Optional: output folder ---
outFolder = fullfile(pwd, 'outputs_with_headers');
if ~exist(outFolder, 'dir'), mkdir(outFolder); end

% --- 5) Loop over prefixes (this replaces your long if/elseif) ---
n = numel(prefixes);
for i = 1:n
    base = prefixes{i};
    fprintf('Iteration %d: saving files with base: %s\n', i, base);

    % --- HERE you must ensure the variables exist/are computed in workspace ---
    % Example: you might compute SUMMARY_ARRAY, dADL, etc. inside this loop.
    % For demonstration we'll assume they already exist (or are produced above).
    % If they are per-iteration variables, compute them here.

    % For each mapped variable, build filename & call save function
    for s = 1:size(saveTable,1)
        varName = saveTable{s,1};       % name of variable in workspace
        suffix  = saveTable{s,2};       % filename suffix
        headerKey = saveTable{s,3};     % key into headers struct

        % check variable exists
        if ~exist(varName, 'var')
            warning('Variable %s does not exist in workspace. Skipping file %s%s', ...
                varName, base, suffix);
            continue;
        end
        data = eval(varName); % read variable by name (common pattern in MATLAB scripts)

        outFile = fullfile(outFolder, [base suffix]);

        % call function
        try
            saveTabWithHeader(outFile, data, headers.(headerKey), 'Delimiter', '\t', 'Precision', '%.8g');
        catch ME
            warning('Failed to save %s: %s', outFile, ME.message);
        end
    end
end

fprintf('All done. Files written to: %s\n', outFolder);
