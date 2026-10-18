function y=est_va(i,rt) %THE SHUNT EQUATION
%this function estimates alveolar lung volume at at various pressures given
%certain initial conditions
%%%%%%%%%%%%This section computes VL based on BB's model and creates a
%%%%%%%%%%%%shunt based on data in Kooyman and Sinnett 1982 for harbour
%%%%%%%%%%%%seal, it uses either a sigmoidal or power function to relate
%%%%%%%%%%%%VA/TAC to shunt
%%%%%%%%%%%%%Pint_init=101.3; %Pint_init=initial pressure inside the respiratory system in mbar, BB=Pinto
global  SURFACE_VALUE P_AMB VLinit0 TAC LUNG_VOL VTinit Pint_init
global BREATH_FLAG %new global to keep track of breaths happening in the code
global BREATH_FLAG VLmax VTinit V_BREATH %new global to keep track of breaths happening in the code
global VLinit VLprev Pint FLAGGA Pint_init %new global to keep track of breaths happening in the code
shunt=0;%shunt is between 1 (100%) and 0 (0%)%no shunt

a=1.495;%harbour seal
b=0.320;%harbour seal
%a=1.072;%California sea lion
%b=0.210;%California sea lion         
%if P_AMB(i)==SURFACE_VALUE %Animal at the surface
if BREATH_FLAG(i)==1
     V_old_total = LUNG_VOL(i-1,1) + LUNG_VOL(i-1,2);

    if V_old_total < VTinit
        error('Previous lung volume is below the surface residual volume.');
    end

    V_residual = VTinit;
    V_inspired = V_BREATH;

    if V_residual + V_inspired > VLmax
        error('Breath volume exceeds total lung capacity.');
    end

    V_final = V_residual + V_inspired;

    LUNG_VOL(i,1) = V_final - VTinit;
    LUNG_VOL(i,2) = VTinit;

    VLinit = LUNG_VOL(i,1);
    VLprev = VLinit;
    Pint = Pint_init;
    FLAGGA = 0;

    va = LUNG_VOL(i,1);

    LUNG_VOL(i,3) = Pint;
    LUNG_VOL(i,4) = P_AMB(i)*101.3;  
else
    
    %%%%%%%%%%%%%%%%%DEBUG portion
    if i == 91
        fprintf('\nBEFORE N2_lung_coll\n');
        fprintf('VLinit = %.6f\n',VLinit);
        fprintf('VLprev = %.6f\n',VLprev);
        fprintf('Pint = %.6f\n',Pint);
        fprintf('Pint_init = %.6f\n',Pint_init);
        fprintf('Previous total volume = %.6f\n', ...
        sum(LUNG_VOL(i-1,1:2)));
    end
    %%%%%%%%%%%%%%%%%%END DEBUG
    
    va=N2_lung_coll(P_AMB(i)*101.3,i); %this returns Va (alveolar volume) at the ambient pressure, the ambient pressure corrected to kPa is sent to the function
   
     %%%%%%%%%%%%%%%%%DEBUG portion
     if i == 91
        fprintf('\nAFTER N2_lung_coll\n');
        fprintf('VLprev = %.6f\n',VLprev);
        fprintf('Pint = %.6f\n',Pint);
        fprintf('New total volume = %.6f\n', ...
        sum(LUNG_VOL(i,1:2)));
    end
      %%%%%%%%%%%%%%%%%DEBUG end
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
