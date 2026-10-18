function y=driver_to_beakedwhale_tissue_kin (u);
global  SUMMARY_ARRAY 
%op=[2000 2000 2000 2000 2000 2000 2000 2000 2000 2000 2000 2000];%
op=[2000 2000 2000 2000 2000 2000 2000 23000 2000 23000 23000 2000];%
%s=GET_DIVE_DATA_LOAD_TISSUE_KIN(1); %loads the data file consisting of 2 columns, 1:depth in atm, 2:pectoral temp in C
for i=12:12
    %if i==4
   %     disp('skip')
   % else
        WHALE=i;%to be used in get_gas_flux to do differences in responses between whales
     clear ALL
   
     s=GET_DIVE_DATA_LOAD_TISSUE_KIN(i); %loads the data file consisting of 4 columns, 1:time sec in atm, 2:depth m, 3=odba (g), 4-odba converted to cost of locomotion (COL, watts)
     dsum=GET_DIVE_SUMMARY_DATA_METABOLIC_RATES(i);%13 columns 1=SI number, 2=SI duration, 3=row for start of SI, 4=row for end SI, 5=average MR (L O2 min-1) during SI, 6=Dive

     %number, 7=Dive duration, 8=row for start of dive, 9=row for end dive,
%10=average MR (L O2 min-1)during dive, 11=maxdepth, 12=mean depth, 13=depth cutoff for bottom 
%the two headers are removed
    %dsumsize=size(dsum)
        y=beakedwhale_tissue_kinetics1(s,op(i),i, dsum);%op is the body mass for when changing Mb
   
        SAVEDATA(SUMMARY_ARRAY)
    %%%%%%%%%%%%%%FUNCTIONS TO PLOT DATA ON DIFFERENT AXES
    %yyaxis left
    %plot(SUMMARY_ARRAY(:,6);
    %yyaxis right
    %plot(odba(:);
    %end
end
%use 'load -mat filename'   to open where file name is the name pasted in
%without the extension

return