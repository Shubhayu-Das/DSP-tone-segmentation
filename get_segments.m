function [segments] = get_segments(data, divs)
n = length(divs);
l = 1; m = 1;
while l<(n)
    segments{m} = data(divs(l):divs(l+1)-1);
    m = m+1;
    l = l+2;
end
end