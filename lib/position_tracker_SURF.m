function [dyGood, dxGood, globalmatches1, globalmatches2, dispMap] = position_tracker_SURF(frame1,mfeatures,tol)

n_ch = double(size(frame1,3));
globalmatches1 = cell(n_ch,1);
globalmatches2 = cell(n_ch,1);

for j = 1:n_ch
    f1Surf = detectSURFFeatures(frame1(:,:,j));
    [features1, validpoints1] = extractFeatures(frame1(:,:,j), f1Surf, 'Upright', false);
    features2 = mfeatures{j,1}; 
    validpoints2 = mfeatures{j,2};
    indexPairs = matchFeatures(features1, features2, 'MaxRatio', 0.95, 'MatchThreshold', 30, 'Unique', false);
    matchedSURFPoints1 = validpoints1(indexPairs(:,1));
    matchedSURFPoints2 = validpoints2(indexPairs(:,2));
    globalmatches1{j} = matchedSURFPoints1;
    globalmatches2{j} = matchedSURFPoints2;
end

globalmatches1 = cat(2, globalmatches1{:});
globalmatches2 = cat(2, globalmatches2{:});

deltax = globalmatches1.Location(:,1) - globalmatches2.Location(:,1);
deltay = globalmatches1.Location(:,2) - globalmatches2.Location(:,2);

xpts = min(deltax):max(deltax);
ypts = min(deltay):max(deltay);
N = histcounts2(deltay(:), deltax(:), ypts, xpts);

[xG, yG] = meshgrid(-5:5);
sigma = 2.5;
g = exp(-xG.^2./(2.*sigma.^2)-yG.^2./(2.*sigma.^2));
g = g./sum(g(:));

dispMap = conv2(N, g, 'same');
thrshMap = dispMap.*(dispMap > g(6,6));%Change index of g if size of meshgrid changes

sparseMap = thrshMap.*imregionalmax(thrshMap);
[~, peakIndex] = max(sparseMap(:));
[dyGood, dxGood] = ind2sub(size(dispMap),peakIndex(1));

dyGood = dyGood + min(deltay);
dxGood = dxGood + min(deltax);

[globalmatches1,globalmatches2] = refineMatches(globalmatches1,globalmatches2,dyGood,dxGood,tol);



