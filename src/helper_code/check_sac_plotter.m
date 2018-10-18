%% plot eye traces with detected saccade onset, offset, and locations
%
% -------------------
% Jeff Mohl
% 8/18/18
% -------------------
%
% Description: this is a plotting script for comparing the saccade
% detection code with the actual eye traces, so that the code can be tuned


figure

plot(HEyeTrace,'b')
hold on
plot(VEyeTrace,'r')
for j=1:length(sac_start_times)
    plot([sac_start_times(j),sac_start_times(j)],[-20 20],'g')
    plot([sac_end_times(j),sac_end_times(j)],[-20 20],'k')
    plot(sac_end_times(j),Hsac_endpoints(j),'b.','MarkerSize',10)
    plot(sac_end_times(j),Vsac_endpoints(j),'r.','MarkerSize',10)
end

legend('H eye', 'V eye')


