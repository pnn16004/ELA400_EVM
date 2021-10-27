% amplify_spatial_Gdown_temporal_ideal(vidFile, outDir, alpha,
%                                      level, fl, fh, samplingRate,
%                                      chromAttenuation)
%
% Spatial Filtering: Gaussian blur and down sample
% Temporal Filtering: Ideal bandpass
%
% Copyright (c) 2011-2012 Massachusetts Institute of Technology,
% Quanta Research Cambridge, Inc.
%
% Authors: Hao-yu Wu, Michael Rubinstein, Eugene Shih,
% License: Please refer to the LICENCE file
% Date: June 2012
%
function amplify_spatial_Gdown_temporal_ideal(vidFile,outDir,alpha,level, ...
    fl,fh,samplingRate, chromAttenuation)

[~,vidName] = fileparts(vidFile);

outName = fullfile(outDir,[vidName '-ideal-from-' num2str(fl) ...
    '-to-' num2str(fh) ...
    '-alpha-' num2str(alpha) ...
    '-level-' num2str(level) ...
    '-chromAtn-' num2str(chromAttenuation) '.avi']);

% Read video
vid = VideoReader(vidFile);
% Extract video info
%-
if strcmp(vidName,'face2')
    %boxSize = [vid.Width*0.7 vid.Height*0.25];
    %boxPos = [(vid.Width-boxSize(1))/2 (vid.Height-boxSize(2))/7]; %fh
    boxSize = [vid.Width*0.75 vid.Height*0.19];
    boxPos = [(vid.Width-boxSize(1))/1.8 (vid.Height-boxSize(2))/1.5];
elseif strcmp(vidName,'face')
    boxSize = [vid.Width*0.6 vid.Height*0.19];
    boxPos = [(vid.Width-boxSize(1))/2.2 (vid.Height-boxSize(2))/6.5];
elseif strcmp(vidName,'baby2')
    boxSize = [vid.Width*0.25 vid.Height*0.5];
    boxPos = [(vid.Width-boxSize(1))/1.85 (vid.Height-boxSize(2))/2.2];
elseif strcmp(vidName,'peter')
    boxSize = [vid.Width*0.4 vid.Height*0.06];
    boxPos = [(vid.Width-boxSize(1))/2.6 (vid.Height-boxSize(2))/4.1];
elseif strcmp(vidName,'mathias_130')
    boxSize = [vid.Width*0.27 vid.Height*0.24];
    boxPos = [(vid.Width-boxSize(1))/1.95 (vid.Height-boxSize(2))/6.0];
elseif strcmp(vidName,'mathias_57')
    boxSize = [vid.Width*0.20 vid.Height*0.20];
    boxPos = [(vid.Width-boxSize(1))/1.98 (vid.Height-boxSize(2))/5.4];
elseif strcmp(vidName,'mathias_61bpm')
    boxSize = [vid.Width*0.18 vid.Height*0.20];
    boxPos = [(vid.Width-boxSize(1))/1.93 (vid.Height-boxSize(2))/3.7];
elseif strcmp(vidName,'mathias_60_ish')
    boxSize = [vid.Width*0.14 vid.Height*0.18];
    boxPos = [(vid.Width-boxSize(1))/1.99 (vid.Height-boxSize(2))/3.1];
else
    boxSize = [vid.Width*0.27 vid.Height*0.24];
    boxPos = [(vid.Width-boxSize(1))/1.95 (vid.Height-boxSize(2))/6.0];
end
box = [boxPos; boxSize];
vidWidth = abs(ceil(box(1,1)+box(2,1))-floor(box(1,1)));
vidHeight = abs(ceil(box(1,2)+box(2,2))-floor(box(1,2)));
%-
%vidHeight = vid.Height;
%vidWidth = vid.Width;
nChannels = 3;
fr = vid.FrameRate;
%len = vid.NumberOfFrames;
len = vid.NumFrames;
temp = struct('cdata', zeros(vidHeight, vidWidth, nChannels, 'uint8'), 'colormap', []);

startIndex = 1;
endIndex = len-10;

vidOut = VideoWriter(outName);
vidOut.FrameRate = fr;

open(vidOut)

% compute Gaussian blur stack
disp('Spatial filtering...')
Gdown_stack = build_GDown_stack(vidFile, startIndex, endIndex, level, box);
%Gdown_stack = build_Lpyr_stack(vidFile, startIndex, endIndex, box);
disp('Finished')

% Temporal filtering
disp('Temporal filtering...')
filtered_stack = ideal_bandpassing(Gdown_stack, 1, fl, fh, samplingRate);
disp('Finished')

%% Extract HR (as a number)
chMean = mean(reshape(filtered_stack,endIndex,[],nChannels),[2 3]);
HRR = getHR(chMean, samplingRate);

%% amplify
filtered_stack(:,:,:,1) = filtered_stack(:,:,:,1) .* alpha;
filtered_stack(:,:,:,2) = filtered_stack(:,:,:,2) .* alpha .* chromAttenuation;
filtered_stack(:,:,:,3) = filtered_stack(:,:,:,3) .* alpha .* chromAttenuation;

%% Render on the input video
disp('Rendering...')
% output video
k = 0;
%-
%Use mask of first frame only
coloredObjectsMask = skinPixels(read(vid, startIndex), []);
%-
for i=startIndex:endIndex
    k = k+1
    temp.cdata = read(vid, i);
    [rgbframe,~] = frame2im(temp);
    rgbframe = im2double(rgbframe);
    frame = rgb2ntsc(rgbframe);
    
    filtered = squeeze(filtered_stack(k,:,:,:));
    %filtered = imresize(filtered,[vidHeight vidWidth]);
    %filtered = filtered+frame;
    
    %-
    opt = 1;
    if opt == 1
        filtered = imresize(filtered,[vid.Height vid.Width]);
        f1 = filtered(:,:,1);
        f2 = filtered(:,:,2);
        f3 = filtered(:,:,3);
        f1(coloredObjectsMask==0) = 0;
        f2(coloredObjectsMask==0) = 0;
        f3(coloredObjectsMask==0) = 0;
        fAll(:,:,1) = f1;
        fAll(:,:,2) = f2;
        fAll(:,:,3) = f3;
        fTemp = frame + fAll;
    else
        filtered = imresize(filtered,[vidHeight vidWidth]);
        %fTemp = filtered;
        %coloredObjectsMask = skinPixels(rgbframe, []);
        %         for j = 1:round(vid.Height/vidHeight)
        %             fTemp = circshift(fTemp,vidHeight,1);
        %             filtered = filtered+fTemp;
        %         end
        fTemp = frame;
        xs = floor(box(1,1));
        xr = xs:xs+vidWidth-1;
        for j = 1:vidHeight:vid.Height
            ys = mod(floor(j),vid.Height-vidHeight);
            yr = ys:ys+vidHeight-1;
            %Only amplify within mask
            %filtered(coloredObjectsMask(yr,xr)==0) = 0;
            f1 = filtered(:,:,1);
            f2 = filtered(:,:,2);
            f3 = filtered(:,:,3);
            f1(coloredObjectsMask(yr,xr)==0) = 0;
            f2(coloredObjectsMask(yr,xr)==0) = 0;
            f3(coloredObjectsMask(yr,xr)==0) = 0;
            fAll(:,:,1) = f1;
            fAll(:,:,2) = f2;
            fAll(:,:,3) = f3;
            %Add ROI part across whole object
            %fTemp(yr,xr,:) = fTemp(yr,xr,:)+filtered;
            fTemp(yr,xr,:) = fTemp(yr,xr,:)+fAll;
            %For a smoother transition
            filtered = flip(filtered,1);
        end
    end
    filtered = fTemp;
    %filtered = wdenoise2(fTemp,5,'Wavelet','db4','ThresholdRule','Soft');
    %-
    
    frame = ntsc2rgb(filtered);
    
    frame(frame > 1) = 1;
    frame(frame < 0) = 0;
    
    writeVideo(vidOut,im2uint8(frame));
end

disp('Finished')
disp(HRR)
close(vidOut);
end