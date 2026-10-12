function my=GET_MY_FOR_PENGUIN(l,depth,t); 
my=zeros(l,1);

for i=2:l
   my(i)=(depth(i)-depth(i-1))/t;
end
return