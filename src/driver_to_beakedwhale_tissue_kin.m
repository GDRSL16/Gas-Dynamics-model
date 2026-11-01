% ========================================================================
% Second-round internal documentation review: 2026-10-18 | Batch 04
% File: driver_to_beakedwhale_tissue_kin.m
% Review focus: Review input/output dimensions, global state, units and call-site assumptions before further refactoring.
% Documentation only: original MATLAB source follows unchanged.
% ========================================================================
% ============================================================
% Documentation review: 2026-10-18 | Batch 05
% File: driver_to_beakedwhale_tissue_kin.m
% MATLAB function: y=driver_to_beakedwhale_tissue_kin (u);
% Review scope: documentation only; numerical model unchanged.
% Original source preserved verbatim below this header.
% ============================================================
function y=driver_to_beakedwhale_tissue_kin (u);
global  SUMMARY_ARRAY BREATH_FLAG

op=[2000 2000 2000 2000 2000 2000 2000 2000 2000 2000 2000 2000 2000 2000 2000];%

for i=15:15
    clear ALL 
    WHALE=i;%to be used in get_gas_flux to do differences in responses between whales
     
   
     s=GET_DIVE_DATA_LOAD_TISSUE_KIN(i); %loads the data file consisting of 4 columns, 1:time sec in atm, 2:depth m, 3=odba (g), 4-odba converted to cost of locomotion (COL, watts)
     dsum=GET_DIVE_SUMMARY_DATA_METABOLIC_RATES(i);%13 columns 1=SI number, 2=SI duration, 3=row for start of SI, 4=row for end SI, 5=average MR (L O2 min-1) during SI, 6=Dive
%%%%%%%%%%%%%%%%%%%LOAD BREATH_FLAG FILE%%%%%%%%%%%%%%%%%%%%%%    
     breath_data = GET_BREATH_FLAGS(i);

        % Column 1 = time (s)
        % Column 2 = breath flag (0 = no breath, 1 = breath)
        BREATH_FLAG = breath_data(:,2);

        % Check that the breath schedule matches the dive profile
        if numel(BREATH_FLAG) ~= size(s,1)
            error('Breath schedule length does not match dive data length');
        end
%%%%%%%%%%%%%%%%%%%LOAD BREATH_FLAG FILE-END%%%%%%%%%%%%%%%%%%%    

     %number, 7=Dive duration, 8=row for start of dive, 9=row for end dive,
%10=average MR (L O2 min-1)during dive, 11=maxdepth, 12=mean depth, 13=depth cutoff for bottom 
%the two headers are removed
    %dsumsize=size(dsum)
        y=beakedwhale_tissue_kinetics1(s,op(i),i, dsum);%op is the body mass for when changing Mb
   
        SAVEDATA(SUMMARY_ARRAY)
    
end


return