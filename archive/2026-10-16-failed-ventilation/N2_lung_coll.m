%NOTE%NOTE%NOTE%NOTE%NOTE%NOTE%NOTE%NOTE%NOTE%
%NOTE%NOTE%NOTE%NOTE
%PAMB HAS TO BE IN kPa absolute i.e. surface
%PAMB = 101.3 kPa so 2 ATA is 101.3 x 2 kPa

function y=N2_lung_coll(ambientpressure,i)
%pressure in kPa
%%%%%%%%%Initial conditions%%%%%%%%%%%%%%%%
format long;
global  VLinit VLmax VTinit  Pint_init A1 A2 A3 A4  FLAGGA VLprev  VT VLmin VL  Pint LUNG_VOL VLinit0 P_AMB
global  VTmax  KP NN 
%VL=alveolar volume, VT=tracheal volume
%%%%%%These should be initialized in the "GET_VARIABLES" list%%
%parameters for fitting change in VT when trachea is collapsing%
%%%%%%%%%%%%a1=0;
%%%%%%%%%%%%%a2=1.1;
%%%%%%%%%%%%%a3=1.23;
%%%%%%%%%%%%%%a4=1.33;

%%%%%%%%%%%%%%kp=-10.82;
%%%%%%%%%%%%%n=1.01;

%%%%%%%%%%%%%VLinit=4.3; %VLinit=initial dive lung volume at surface ; BB=VLo2
%%%%%%%%%%%%%flag=0;%set to 0 if Pint <= Pamb and no tracheal collapse else it is set to 1 and use tracheal collapse
%%%%%%%%%%%%%VLmax=10;%VLmax=maximum volume of lung; BB=VLo
%%%%%%%%%%%%%VTmax=1;%VTmax=maximum volume of trachea; BB=VTo
%%%%%%%%%%%%%VTinit=1;%VTinit=initial tracheal volume; BB=VTo2
%%%%%%%%%%%%%Pint_init=101.3; %Pint_init=initial pressure inside the respiratory system in mbar, BB=Pinto
%%%%%%%%%%%%%VT=1;
%%%%%%%%%%%%%a=VLinit;%a is used in fzero to search for a value close to VL, this is set as the last VL as that should be fairly close to the new VL with the assumption that the change in pressyre has not been tremendous
%%%%%%%%%%%%%VLprev=VLinit; % this should be kept and passed to the function and is the previous alveolar volume
 %This function relies on a set of initial conditions for and returns the
 %estimated VL at a certain depth. The initial conditions for VLinit,
 %VTinit, VL, VT, VLprev
PAMB=ambientpressure;%the ambient pressure in kPa

if i>1671020
            i
           PAMB
            VLmax
            VTinit
            Pint_init
           VLinit
            VTinit
            %vlprevdummy
  end
if VLmin(2)<=PAMB %VLmin(2) is the pressure where lung collapse
    VL=0;%VLmin(1)-VLmin(1)*0.01;%changed from being 0 on 080101, the assumption is that there is always a small amount of gas exhange

elseif FLAGGA==0%The case when Pamb >=Pint, i.e. no tracheal collapse, the case when structural pressure <0
    if P_AMB(i)==P_AMB(i-1)%same ambient pressure as before
        
       VL=fzero(@(x)(-(A3-(log((A2./((x./VLmax)-A1))-1)./A4))+Pint_init*(VLinit+VTinit)./(x+VTinit)-PAMB),VLprev);%changed range from [000000001, VLinit0] 
    elseif P_AMB(i)>P_AMB(i-1)%descent
        
       
       VL=fzero(@(x)(-(A3-(log((A2./((x./VLmax)-A1))-1)./A4))+Pint_init*(VLinit+VTinit)./(x+VTinit)-PAMB),VLprev*0.9);%changed range from [000000001, VLinit0] 
    elseif P_AMB(i)<P_AMB(i-1) %ascent do VLprev*1.1
       vlprevdummy=VLprev*1.1;%a dummy variable to check that VLprev*1.1 is not much larger than VLinit as then fzero will crash
        if vlprevdummy>VLinit%101007
           vlprevdummy=VLinit;
        end
        if i > 2
            vlprevdummy=vlprevdummy*0.95;
        end
       
       
        VL=fzero(@(x)(-(A3-(log((A2./((x./VLmax)-A1))-1)./A4))+Pint_init*(VLinit+VTinit)./(x+VTinit)-PAMB),vlprevdummy);%changed range from [000000001, VLinit0] 
    else
        
      VL=fzero(@(x)(-(A3-(log((A2./((x./VLmax)-A1))-1)./A4))+Pint_init*(VLinit+VTinit)./(x+VTinit)-PAMB),[0.00000000001,VLinit]);%changed range from [000000001, VLinit0] 
    end
   VT=VTinit;
   Pint=Pint_init*(VLinit+VTinit)./(VL+VT); 
   VLprev=VL; %sets VLprev to the the current VL for next time the function is used, VLprev is used in fzero to "search in the area close to VL
  
   if Pint< PAMB% now structural pressure > 0
      
       FLAGGA=1;
   end    
   if VL<VLmin(1)%if VL has become less than VLmin, set VL to 0 and FLAGGA to 2. Update VLmin(2) to the PAMB and when this is exceeded VL will always be 0
       VL=0;%VLmin(1)-VLmin(1)*0.01;%changed from being 0 on 080101, the assumption is that there is always a small amount of gas exhange
       if VLmin(2)==900000 %update the first time VL<VLmin to the current pressure but never again
          VLmin(2)=PAMB;
          
       end   
   end   
elseif FLAGGA==1%else is if FLAGGA==1
    
   nextv=P_AMB(i-1)*VLprev/P_AMB(i);
   %VL=fzero(@(x)((Pint_init*(VLinit+VTinit)./(x+(Pint_init*(VLinit+VTinit)./(PAMB-(-(A3-(log((A2./((x./VLmax)-A1))-1)./A4))))-x)))+(-(.0981*KP*((((Pint_init*(VLinit+VTinit)./(PAMB-(-(A3-(log((A2./((x./VLmax)-A1))-1)./A4))))-x)./VTmax)^(-NN))-1)))-PAMB),range);    

   VL=fzero(@(x)((Pint_init*(VLinit+VTinit)./(x+(Pint_init*(VLinit+VTinit)./(PAMB-(-(A3-(log((A2./((x./VLmax)-A1))-1)./A4))))-x)))+(-(.0981*KP*((((Pint_init*(VLinit+VTinit)./(PAMB-(-(A3-(log((A2./((x./VLmax)-A1))-1)./A4))))-x)./VTmax)^(-NN))-1)))-PAMB),nextv);
   %if (isnan(VL)) %if fzero returns an imaginary number, alter nextv slightly and start over, then use that VL
   catchnan=0.01;
   r=1;
   while isnan(VL)
      %nextv=nextv*1.01;
      VL=fzero(@(x)((Pint_init*(VLinit+VTinit)./(x+(Pint_init*(VLinit+VTinit)./(PAMB-(-(A3-(log((A2./((x./VLmax)-A1))-1)./A4))))-x)))+(-(.0981*KP*((((Pint_init*(VLinit+VTinit)./(PAMB-(-(A3-(log((A2./((x./VLmax)-A1))-1)./A4))))-x)./VTmax)^(-NN))-1)))-PAMB),nextv*(1+(r*catchnan)));    
      r=r+1;
   end
   VT=(Pint_init*(VLinit+VTinit)./(PAMB+(A3-(log((A2./((VL./VLmax)-A1))-1)/A4)))-VL);       
   Pint =Pint_init*(VLinit+VTinit)./(VL+VT);
   VLprev=VL; 
   if Pint >= PAMB 
       FLAGGA=0;
       VT=VTinit;
       %Pint=Pint_init;
   end
   if VL<VLmin(1) || isnan(VL) %if VL has become less than VLmin, set VL to 0 and FLAGGA to 2. Update VLmin(2) to the PAMB and when this is exceeded VL will always be 0
       VL=0;%VLmin(1)-VLmin(1)*0.01; %changed from being 0 on 080101, the assumption is that there is always a small amount of gas exhange
       if VLmin(2)==900000 %update the first time VL<VLmin to the current pressure but never again
          VLmin(2)=PAMB;
       end   
    end   
end

LUNG_VOL(i,1)=VL;%current alveolar volume
LUNG_VOL(i,2)=VT;%curretn tracheal volume
LUNG_VOL(i,3)=Pint;%current internal pressure
LUNG_VOL(i,4)=PAMB;%the ambient pressure at i


y=VL;
return
