function out = difff(in)

[rr cc] = size(in);

if rr > 1
  out = diff(in);
  out = [out;out(rr-1,:)];
else
  out = zeros(1,cc);
end;
return


