% ============================================================
% Documentation review: 2026-10-18 | Batch 05
% File: est_va.m
% MATLAB function: y=est_va(i,rt) %THE SHUNT EQUATION
% Review scope: documentation only; numerical model unchanged.
% Original source preserved verbatim below this header.
% ============================================================
% GAS DYNAMICS MODEL - ALVEOLAR VOLUME AND SHUNT
% Invoked from the no-breath pathway of update_lung_gas.
% Mechanical collapse is handled by N2_lung_coll when not at exact surface.
% The legacy exact-surface branch remains unchanged in this cleanup.

function y=est_va(i,rt) %THE SHUNT EQUATION
%this function estimates alveolar lung volume at at various pressures given
%certain initial conditions
%%%%%%%%%%%%This section computes VL based on BB's model and creates a
%%%%%%%%%%%%shunt based on data in Kooyman and Sinnett 1982 for harbour
%%%%%%%%%%%%seal, it uses either a sigmoidal or power function to relate
%%%%%%%%%%%%VA/TAC to shunt
global  SURFACE_VALUE P_AMB VLinit0 TAC LUNG_VOL VTinit

shunt=0;%shunt is between 1 (100%) and 0 (0%)%no shunt

a=1.495;%harbour seal
b=0.320;%harbour seal
%a=1.072;%California sea lion
%b=0.210;%California sea lion         
if P_AMB(i)==SURFACE_VALUE
    LUNG_VOL(i,1)=VLinit0; %initial alveolar volume
    LUNG_VOL(i,2)=VTinit;%curretn tracheal volume
    va=VLinit0;
else

    va=N2_lung_coll(P_AMB(i)*101.3,i); %this returns Va (alveolar volume) at the ambient pressure, the ambient pressure corrected to kPa is sent to the function
   %%%%%%%%%%%%%debuggung remnove
    if va==NaN
       disp('va is NaN in est_va')
       i
    end
   %%%%%%%%%%%%%debuggung remnove
end
    lungratio=va./TAC; %program returns alveolar volume

 shunt=1-a*lungratio^b;%from Brian paper
 if shunt<0 %for a ratio > 0.317 the shunt is negative so force it to be 0
     shunt=0;
 end

if shunt< 0 
    disp('FUCK in function est_va')
end

LUNG_VOL(i,5)=shunt;

y=shunt;
return
