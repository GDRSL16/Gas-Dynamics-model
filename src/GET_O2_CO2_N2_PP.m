% ========================================================================
% Documentation reviewed: 2026-10-18 | Batch 01
% Purpose: Extract compartment gas tensions near dive start and end.
% Interface: dsum supplies dive boundaries; SUMMARY_ARRAY contains the gas-tension output columns.
% Review note: The original backward-looking averaging window and indices are unchanged.
% Scope: Documentation only; all pre-existing lines remain unchanged.
% ========================================================================

% ============================================================
% Documentation review: 2026-10-18 | Batch 01
% Scope: Review tracking header only; original code preserved.
% Numerical calculations, logic, and existing comments unchanged.
% ============================================================
%This function pulls out the value of PO2, PCO2 and PN2 at the start of the
%dive and the mean of the last 3 values before reaching the surface
function O2_CO2_N2_PP=GET_O2_CO2_N2_PP(dsum, SUMMARY_ARRAY)

num_dives= length(dsum)-1;%number of dives in record
%no_dive=1;%dive counter which is used to get row of dADL
N=5; %number of seconds (row) to scan backwards
for x=1:size(dsum,1)-1
    pre_row=dsum(x,8);%row for start of dive
    post_row=dsum(x,9);%row for end of dive
    
   %%%%%%%%Pre section
    O2_CO2_N2_PP(x,1)=mean(SUMMARY_ARRAY(pre_row-N:pre_row,1));%N2 heart
    O2_CO2_N2_PP(x,2)=mean(SUMMARY_ARRAY(pre_row-N:pre_row,2));%N2 muscle
    O2_CO2_N2_PP(x,3)=mean(SUMMARY_ARRAY(pre_row-N:pre_row,3));%N2 brain
    O2_CO2_N2_PP(x,4)=mean(SUMMARY_ARRAY(pre_row-N:pre_row,4));%N2 fat

    O2_CO2_N2_PP(x,5)=mean(SUMMARY_ARRAY(pre_row-N:pre_row,6));%O2 heart
    O2_CO2_N2_PP(x,6)=mean(SUMMARY_ARRAY(pre_row-N:pre_row,7));%O2 muscle
    O2_CO2_N2_PP(x,7)=mean(SUMMARY_ARRAY(pre_row-N:pre_row,8));%O2 brain
    O2_CO2_N2_PP(x,8)=mean(SUMMARY_ARRAY(pre_row-N:pre_row,9));%O2 fat
    
    O2_CO2_N2_PP(x,9)=mean(SUMMARY_ARRAY(pre_row-N:pre_row,11));%CO2 heart
    O2_CO2_N2_PP(x,10)=mean(SUMMARY_ARRAY(pre_row-N:pre_row,12));%CO2 muscle
    O2_CO2_N2_PP(x,11)=mean(SUMMARY_ARRAY(pre_row-N:pre_row,13));%CO2 brain
    O2_CO2_N2_PP(x,12)=mean(SUMMARY_ARRAY(pre_row-N:pre_row,14));%Co2 fat

    %%%%%%%%%%Post section
    O2_CO2_N2_PP(x,13)=mean(SUMMARY_ARRAY(post_row-N:post_row,1));%N2 heart
    O2_CO2_N2_PP(x,14)=mean(SUMMARY_ARRAY(post_row-N:post_row,2));%N2 muscle
    O2_CO2_N2_PP(x,15)=mean(SUMMARY_ARRAY(post_row-N:post_row,3));%N2 brain
    O2_CO2_N2_PP(x,16)=mean(SUMMARY_ARRAY(post_row-N:post_row,4));%N2 fat

    O2_CO2_N2_PP(x,17)=mean(SUMMARY_ARRAY(post_row-N:post_row,6));%O2 heart
    O2_CO2_N2_PP(x,18)=mean(SUMMARY_ARRAY(post_row-N:post_row,7));%O2 muscle
    O2_CO2_N2_PP(x,19)=mean(SUMMARY_ARRAY(post_row-N:post_row,8));%O2 brain
    O2_CO2_N2_PP(x,20)=mean(SUMMARY_ARRAY(post_row-N:post_row,9));%O2 fat
    
    O2_CO2_N2_PP(x,21)=mean(SUMMARY_ARRAY(post_row-N:post_row,11));%CO2 heart
    O2_CO2_N2_PP(x,22)=mean(SUMMARY_ARRAY(post_row-N:post_row,12));%Co2 muscle
    O2_CO2_N2_PP(x,23)=mean(SUMMARY_ARRAY(post_row-N:post_row,13));%CO2 brain
    O2_CO2_N2_PP(x,24)=mean(SUMMARY_ARRAY(post_row-N:post_row,14));%CO2 fat
  
    O2_CO2_N2_PP(x,25)=dsum(x,7);%dive duration
    O2_CO2_N2_PP(x,26)=dsum(x,11);%MAX DIVE DEPTH

 
    O2_CO2_N2_PP(x,27)=mean(SUMMARY_ARRAY(pre_row-N-1:pre_row-1,16));%N2 arterial right before dive 
    O2_CO2_N2_PP(x,28)=mean(SUMMARY_ARRAY(pre_row-N-1:pre_row,17));%N2 mixed venous, right before dive
    O2_CO2_N2_PP(x,29)=mean(SUMMARY_ARRAY(post_row-N:post_row,16));%N2 arterial, right before surfacing
    O2_CO2_N2_PP(x,30)=mean(SUMMARY_ARRAY(post_row-N:post_row,17));%N2 mixed venous right before surfaing
    O2_CO2_N2_PP(x,31)=mean(SUMMARY_ARRAY(post_row-N:post_row,20));%CO2 arterial, right before surfacing
    O2_CO2_N2_PP(x,32)=mean(SUMMARY_ARRAY(post_row-N:post_row,21));%CO2 mixed venous right before surfaing
end
return



                       