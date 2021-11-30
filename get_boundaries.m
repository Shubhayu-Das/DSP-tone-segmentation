function [divs] = get_boundaries(data)
len = length(data);
threshup = 0.42*max(data);
threshdown = 0.21*max(data);

quiet=1; 
j=1; k=1;
for i=51:len-50
   if quiet == 1  % trying to find the begining of a note
      if (max(abs(data(i-50:i+50))) > threshup)
         quiet = 0;  % found it
         divs(j) = i;  % record this division point
         j=j+1; k=k+1;
      end
	else
      if (max(abs(data(i-50:i+50))) < threshdown)
         quiet = 1;  % note over
         divs(j) = i;
         j=j+1;
      end
   end
end  

end