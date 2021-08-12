function [dyGood, dxGood, peakVals, globalmatches1, globalmatches2, dispMap, passMatches] = mchannel_SURF_reg(frame1,frame2,dyGood,dxGood)
%mchannel_SURF_reg Computes and maps the density of dx, dy of feature
%matches between two frames, as well as the first 5 maxima of that map
%   frame1, frame2 are yres by xres by n_channels multi-channel frames
%   peakWidth is the tolerance for displacement
%   dyGood, dxGood can be supplied by user which overrides
%   auto-determination by the function

frame1 = im2uint8(frame1);
frame2 = im2uint8(frame2);
n_ch = double(size(frame1,3)); xres = double(size(frame1,2)); yres = double(size(frame1,1));
globalmatches1 = cell(n_ch,1);
globalmatches2 = cell(n_ch,1);
passMatches = cell(n_ch,2);

for j = 1:n_ch
    f1Surf = detectSURFFeatures(frame1(:,:,j),'MetricThreshold', 100);
    f2Surf = detectSURFFeatures(frame2(:,:,j),'MetricThreshold', 100);
    [features1, validpoints1] = extractFeatures(frame1(:,:,j), f1Surf, 'Upright', true);
    [features2, validpoints2] = extractFeatures(frame2(:,:,j), f2Surf, 'Upright', true);
    passMatches{j,1} = features2;  
    passMatches{j,2} = validpoints2;  
    indexPairs = matchFeatures(features1, features2, 'MaxRatio', 0.95, 'MatchThreshold', 30, 'Unique', true);
    matchedSURFPoints1 = validpoints1(indexPairs(:,1));
    matchedSURFPoints2 = validpoints2(indexPairs(:,2));
    globalmatches1{j} = matchedSURFPoints1;
    globalmatches2{j} = matchedSURFPoints2;
end

globalmatches1 = cat(2, globalmatches1{:});
globalmatches2 = cat(2, globalmatches2{:});

deltax = globalmatches1.Location(:,1) - globalmatches2.Location(:,1);
deltay = globalmatches1.Location(:,2) - globalmatches2.Location(:,2);

xpts = linspace(-xres, xres, 2*xres+1);
ypts = linspace(-yres, yres, 2*yres+1);
N = histcounts2(deltay(:), deltax(:), ypts, xpts);

[xG, yG] = meshgrid(-5:5);
sigma = 2.5;
g = exp(-xG.^2./(2.*sigma.^2)-yG.^2./(2.*sigma.^2));
g = g./sum(g(:));

dispMap = conv2(N, g, 'same');
thrshMap = dispMap.*(dispMap > g(6,6));%Change index of g if size of meshgrid changes
peakVals = zeros(1,5);

if nargin < 4
    sparseMap = thrshMap.*imregionalmax(thrshMap);
    [peakVals, peakIndices] = maxk(sparseMap(:), 5); % Could change 5 to be any number of peaks to find
    [ygs, xgs] = ind2sub(size(dispMap),peakIndices);
    dyGood = ygs - yres;
    dxGood = xgs - xres;
end


