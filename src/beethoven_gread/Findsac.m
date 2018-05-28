function Z=findsac(gazep,sample_interval,velocity_threshold)

% FINDSAC.M
%
% Purpose	finds saccade in gaze position
%		returns onset and offet times
%		in element units, not in real time units.
%
% Call		Z=findsac(gazep,sample_interval,velocity_threshold)
%
% March 28, 1996
% Choongkil Lee
%		 
if nargin<3
	error('Usaga: Z=(gazep, sample_interval,velocity_threshold)');
end;

gazep=smooth(gazep);
gazev=difff(gazep).*ceil(1000./sample_interval);
gazev=(smooth(smooth(gazev)));

moving=find(abs(gazev)>velocity_threshold);

if numel(moving) ==0
Z=[999999 999999];
return; end;

m=1;
left(1)=moving(1);

for n=1:length(moving)-1,
	if moving(n+1)-moving(n)>ceil(100./sample_interval)
			% intersaccade interval is bigger than 100msec.
            %% 100ms 내에 다른 saccade가 또 일어났을 때는 제거한다. 
		right(m)=moving(n);
		left(m+1)=moving(n+1);
		m=m+1;
	end;
end;

right(m)=moving(length(moving));

Z=[left', right'];		% rough estimate of onset and offset

% Sliding to find exact boudary of saccade.
[p,q]=size(Z);
for i=1:p
	for n=Z(i,1):-1:1

		%sliding leftward to find sac onset at 10deg/sec.

		if abs(gazev(n))< 10 % This value can be adjusted by user.
			break; end;
		Z(i,1)=n;
	end;

	for n=Z(i,2):length(gazev)	%sliding rightward to find sac offset at 10deg/sec.
		if abs(gazev(n))<10  % This value can be adjusted by user.
			break; end;
		Z(i,2)=n;
	end;
end;

return;

