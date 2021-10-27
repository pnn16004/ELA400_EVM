function HRR = getHR(s,fs)

[pks, locs] = findpeaks(s);

t = 0:1/fs:(length(s)-1)/fs;
tPL = t(locs(2:end)); %Time locations of peaks
HBduration = diff(t(locs)); %Difference in time
HR = 1./HBduration;
HRR(1) = mean(HR) * 60;
numPks = length(pks);
sec = length(s) / fs;
HRR(2) = 60 * (numPks / sec);

%fixed time distances
TInterpolated = tPL(1):tPL(end);
vq1 = interp1(tPL,HR,TInterpolated);

%HR stairs plot
stairs(TInterpolated,vq1*60,'r')
xlabel('sec')
ylabel('bpm')