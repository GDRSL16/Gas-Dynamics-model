function T = check_ascent_O2_CO2(dive_number,seconds_before)
% CHECK_ASCENT_O2_CO2  Read-only ascent gas-gradient diagnostic.
% 2026-11-05
% T = check_ascent_O2_CO2(10,20)  % intermediate dive 10
% T = check_ascent_O2_CO2(2,20)   % deep dive 2
% Uses current simulation globals; does not alter model calculations.
% All pressures are in atm, gas inventories in mol.
%
% Caution: row-to-row blood package inventory changes are NOT pulmonary
% gas fluxes. Positive lung inventory change is supportive, not proof of
% the direction of exchange. See model's gas-specific exchange functions.

if nargin<1 || isempty(dive_number), dive_number=10; end
if nargin<2 || isempty(seconds_before), seconds_before=20; end

global O2_ARRAY CO2_ARRAY ART_VEN_PO2 ART_VEN_PCO2
 global ART_VEN_nO2 ART_VEN_nCO2
 global LUNG_VOL P_AMB BREATH_FLAG SURFACE_VALUE

N=numel(P_AMB);
assert(N>1 && numel(BREATH_FLAG)==N,'Breath and pressure arrays must match');
assert(size(O2_ARRAY,1)>=N && size(CO2_ARRAY,1)>=N,'Gas arrays shorter than pressure');
assert(size(ART_VEN_PO2,1)>=N && size(ART_VEN_PCO2,1)>=N,'Blood pressure arrays too short');
assert(size(ART_VEN_nO2,1)>=N && size(ART_VEN_nCO2,1)>=N,'Blood mole arrays too short');

surface=abs(P_AMB(:)-SURFACE_VALUE)<1e-8;
surfacing=find(diff(surface)==1)+1;
assert(dive_number>=1 && dive_number<=numel(surfacing), ...
    'Dive number must be between 1 and %d',numel(surfacing));
s=surfacing(dive_number);
rows=(max(2,s-seconds_before):s-1)';
assert(~isempty(rows),'No pre-surfacing rows selected');

% Approximate depth for a 10 m/atm hydrostatic relation.
% For exact depth, use the dive-data depth column instead.
depth=10*(P_AMB(rows)/SURFACE_VALUE-1);
shunt=LUNG_VOL(rows,5);
no_breath=BREATH_FLAG(rows)==0;
active=shunt<1;

pO2lung=O2_ARRAY(rows,5,1); pO2ven=ART_VEN_PO2(rows,2);
pO2art=ART_VEN_PO2(rows,1);
pCO2lung=CO2_ARRAY(rows,5,1); pCO2ven=ART_VEN_PCO2(rows,2);
pCO2art=ART_VEN_PCO2(rows,1);

dO2lung=O2_ARRAY(rows,5,2)-O2_ARRAY(rows-1,5,2);
dCO2lung=CO2_ARRAY(rows,5,2)-CO2_ARRAY(rows-1,5,2);
dO2art=ART_VEN_nO2(rows,1)-ART_VEN_nO2(rows-1,1);
dCO2art=ART_VEN_nCO2(rows,1)-ART_VEN_nCO2(rows-1,1);

gradO2=pO2lung-pO2ven;
gradCO2=pCO2lung-pCO2ven;
% O2 usual lung -> blood: gradient positive. Reverse if negative.
revO2=gradO2<0;
candidateO2=revO2 & dO2lung>0 & no_breath & active;
% CO2 usual blood -> lung: gradient negative. Reverse if positive.
revCO2=gradCO2>0;
candidateCO2=revCO2 & dCO2lung<0 & no_breath & active;

T=table(rows,depth,pO2lung,pO2ven,pO2art,gradO2, ...
    O2_ARRAY(rows,5,2),dO2lung,ART_VEN_nO2(rows,1),dO2art, ...
    pCO2lung,pCO2ven,pCO2art,gradCO2, ...
    CO2_ARRAY(rows,5,2),dCO2lung,ART_VEN_nCO2(rows,1),dCO2art, ...
    shunt,revO2,candidateO2,revCO2,candidateCO2, ...
    'VariableNames',{'TimeStep','Depth_m','Lung_PO2_atm','Venous_PO2_atm', ...
    'Arterial_PO2_atm','LungMinusVenous_O2_atm','Lung_O2_mol', ...
    'Change_Lung_O2_mol','Arterial_O2_mol','Change_Arterial_O2_mol', ...
    'Lung_PCO2_atm','Venous_PCO2_atm','Arterial_PCO2_atm', ...
    'LungMinusVenous_CO2_atm','Lung_CO2_mol','Change_Lung_CO2_mol', ...
    'Arterial_CO2_mol','Change_Arterial_CO2_mol','Shunt', ...
    'O2_ReversedGradient','O2_CandidateReverseTransfer', ...
    'CO2_ReversedGradient','CO2_CandidateReverseTransfer'});

disp(T);
for gas=1:2
    if gas==1
        label='O2'; pl=pO2lung; pv=pO2ven; pa=pO2art; gg=gradO2;
        dn=dO2lung; da=dO2art; rev=revO2; cand=candidateO2;
    else
        label='CO2'; pl=pCO2lung; pv=pCO2ven; pa=pCO2art; gg=gradCO2;
        dn=dCO2lung; da=dCO2art; rev=revCO2; cand=candidateCO2;
    end
    figure('Name',sprintf('%s ascent dive %d',label,dive_number));
    tiledlayout(4,1,'TileSpacing','compact');
    ax(1)=nexttile; plot(depth,pl,'b-',depth,pv,'r--',depth,pa,'k-','LineWidth',1.3);
    ylabel(['P' label ' (atm)']); legend('Lung','Mixed venous','Arterial','Location','best');
    title(sprintf('%s: dive %d, final %d s before surfacing',label,dive_number,seconds_before)); grid on;
    ax(2)=nexttile; plot(depth,gg,'b-','LineWidth',1.3); hold on;
    yline(0,'k--'); plot(depth(rev),gg(rev),'ro');
    ylabel('Lung - venous (atm)'); grid on;
    ax(3)=nexttile; plot(depth,dn,'b-',depth,da,'r--','LineWidth',1.3);
    yline(0,'k:'); ylabel('Delta mol / step');
    legend('Lung inventory change','Arterial package change','Location','best'); grid on;
    ax(4)=nexttile; plot(depth,shunt,'k-','LineWidth',1.3); hold on;
    plot(depth(cand),shunt(cand),'ro','MarkerFaceColor','r');
    xlabel('Approximate depth (m)'); ylabel('Shunt fraction'); grid on;
    for a=ax, set(a,'XDir','reverse'); end
    fprintf('\n%s dive %d, surfacing row %d\n',label,dive_number,s);
    fprintf('Reversed-gradient rows: %d; candidate transfer rows: %d\n',sum(rev),sum(cand));
    if any(cand)
        j=find(cand,1,'first');
        fprintf('First candidate at row %d, approximate depth %.2f m\n',rows(j),depth(j));
    end
end

% Optional export to Excel, preserving full numeric precision:
% writetable(T,sprintf('ascent_dive_%d_O2_CO2.xlsx',dive_number));
end
