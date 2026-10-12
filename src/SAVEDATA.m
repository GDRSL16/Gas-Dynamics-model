function savedata(SUMMARY_ARRAY)
%creating a filename as date-time to save data
%not working
timearray = clock;
month = int2str(timearray(2));
   if length(month)<2
      month = ['0' month];
   end
day = int2str(timearray(3));
   if length(day)<2
      day = ['0' day];
   end
hour = int2str(timearray(4));
   if length(hour)<2
      hour = ['0' hour];
   end
minute = int2str(timearray(5));
   if length(minute)<2
      minute = ['0' minute];
   end
%u=u';
filename = [month day '-' hour minute '.mat'];
file=num2str(filename);
save(file, 'SUMMARY_ARRAY');
%fid = fopen(file,'w');
%fprintf(fid, 'CC-PN2 M-PN2 B-PN2 F-PN2 L-PN2 CC-PO2 M-PO2 B-PO2 F-PO2 L-PO2 CC-PCO2 M-PCO2 B-PCO2 F-PCO2 L-PCO2 Art-PN2 Ven-PN2 Art-PO2 Ven-PO2 Art-PCO2 Ven-PCO2 Pamb VA VD Shunt\n')
%for i=1:length(u)
%    fprintf(fid,'%2.0f %12.8f %12.8f %12.8f\n',u);
%end
%fclose(fid);
return
   


