% ========================================================================
% Second-round internal documentation review: 2026-10-18 | Batch 07
% File: update_tissue_metabolic_rates.m
% Review focus: Metabolic demand assignment. Confirm units and timing of activity-dependent changes when creating a parameter dictionary.
% Documentation only: original MATLAB source follows unchanged.
% ========================================================================
% ============================================================
% Documentation review: 2026-10-18 | Batch 07
% File: update_tissue_metabolic_rates.m
% Function signature: update_tissue_metabolic_rates(row, multiplier_ht, multiplier_mus, multiplier_brain, multiplier_fat, dive_no, dive_response_flag)
% Scope: documentation only; numerical model unchanged.
% Original source preserved verbatim below this header.
% ============================================================
%this function adjusts the metabolic rate by a multiplier, i.1. multiplier
%=0.5 means to reduce MR by 50%
function update_tissue_metabolic_rates(row, multiplier_ht, multiplier_mus, multiplier_brain, multiplier_fat, dive_no, dive_response_flag)
%multipliers can be from -1 to 1 and negative values reduces the metbaolic
%below the basal, for example in heart during diving where the metabolic
%work is reduced due to lower cardiac output. In muscle, the metbolic rate
%is higher according to the increased swimming effort and this is a
%multiple of RMR/BMR
global nO2DOT_HEART nO2DOT_MUSCLE nO2DOT_BRAIN nO2DOT_FAT nCO2DOT_HEART nCO2DOT_MUSCLE nCO2DOT_BRAIN nCO2DOT_FAT
global nCO2DOT_HEART_ORIGINAL nCO2DOT_MUSCLE_ORIGINAL nCO2DOT_BRAIN_ORIGINAL nCO2DOT_FAT_ORIGINAL
global nO2DOT_HEART_ORIGINAL nO2DOT_MUSCLE_ORIGINAL nO2DOT_BRAIN_ORIGINAL nO2DOT_FAT_ORIGINAL METABOLIC_RATES
%dive_response_flag=1 the animal is diving, if 0=at surface
if dive_response_flag==1 %start of dive alter metabolism
   nO2DOT_HEART=nO2DOT_HEART_ORIGINAL*multiplier_ht+nO2DOT_HEART_ORIGINAL;%the "new" metabiolic rate is original [BMR]+COL
   nO2DOT_MUSCLE=nO2DOT_MUSCLE_ORIGINAL*multiplier_mus+nO2DOT_MUSCLE_ORIGINAL;
   nO2DOT_BRAIN=nO2DOT_BRAIN_ORIGINAL*multiplier_brain+nO2DOT_BRAIN_ORIGINAL;
   nO2DOT_FAT=nO2DOT_FAT_ORIGINAL*multiplier_fat+nO2DOT_FAT_ORIGINAL;

   nCO2DOT_HEART=nCO2DOT_HEART_ORIGINAL*multiplier_ht+nCO2DOT_HEART_ORIGINAL;
   nCO2DOT_MUSCLE=nCO2DOT_MUSCLE_ORIGINAL*multiplier_mus+nCO2DOT_MUSCLE_ORIGINAL;
   nCO2DOT_BRAIN=nCO2DOT_BRAIN_ORIGINAL*multiplier_brain+nCO2DOT_BRAIN_ORIGINAL;
   nCO2DOT_FAT=nCO2DOT_FAT_ORIGINAL*multiplier_fat+nCO2DOT_FAT_ORIGINAL;
   METABOLIC_RATES(dive_no,1)=dive_no;
   METABOLIC_RATES(dive_no,2)=nCO2DOT_HEART;%diving adjusted MR of heart
   METABOLIC_RATES(dive_no,3)=nCO2DOT_MUSCLE;%diving adjusted MR of muscle
   METABOLIC_RATES(dive_no,4)=nCO2DOT_BRAIN;%diving adjusted MR of brain
   METABOLIC_RATES(dive_no,5)=nCO2DOT_FAT;%diving adjusted MR of fat
   METABOLIC_RATES(dive_no,6)=nCO2DOT_HEART+nCO2DOT_MUSCLE+nCO2DOT_BRAIN+nCO2DOT_FAT;%diving adjusted total MR
elseif dive_response_flag==0 %start of surface interval   
   nO2DOT_HEART=nO2DOT_HEART_ORIGINAL*multiplier_ht+nO2DOT_HEART_ORIGINAL;
   nO2DOT_MUSCLE=nO2DOT_MUSCLE_ORIGINAL*multiplier_mus+nO2DOT_MUSCLE_ORIGINAL;%the "new" metabiolic rate is original [BMR]+COL
   nO2DOT_BRAIN=nO2DOT_BRAIN_ORIGINAL*multiplier_brain+nO2DOT_BRAIN_ORIGINAL;
   nO2DOT_FAT=nO2DOT_FAT_ORIGINAL*multiplier_fat+nO2DOT_FAT_ORIGINAL;
   
   nCO2DOT_HEART=nCO2DOT_HEART_ORIGINAL*multiplier_ht+nCO2DOT_HEART_ORIGINAL;
   nCO2DOT_MUSCLE=nCO2DOT_MUSCLE_ORIGINAL*multiplier_mus+nCO2DOT_MUSCLE_ORIGINAL;
   nCO2DOT_BRAIN=nCO2DOT_BRAIN_ORIGINAL*multiplier_brain+nCO2DOT_BRAIN_ORIGINAL;
   nCO2DOT_FAT=nCO2DOT_FAT_ORIGINAL*multiplier_fat+nCO2DOT_FAT_ORIGINAL;
   METABOLIC_RATES(dive_no,7)=nCO2DOT_HEART;%surface adjusted MR of heart
   METABOLIC_RATES(dive_no,8)=nCO2DOT_MUSCLE;%surfaceadjusted MR of muscle
   METABOLIC_RATES(dive_no,9)=nCO2DOT_BRAIN;%surface MR of brain
   METABOLIC_RATES(dive_no,10)=nCO2DOT_FAT;%surface MR of fat
   METABOLIC_RATES(dive_no,11)=nCO2DOT_HEART+nCO2DOT_MUSCLE+nCO2DOT_BRAIN+nCO2DOT_FAT;%surface adjusted total MR
end

%tot=nO2DOT_HEART+nO2DOT_MUSCLE+nO2DOT_BRAIN+nO2DOT_FAT
%per=nO2DOT_MUSCLE/tot

return