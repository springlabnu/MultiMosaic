[filenameG, pathG] = uigetfile('*.mat','Ground Truth Mosaic Path');
if isequal(filenameG,0)
    return
end
[filenameT, pathT] = uigetfile('*.mat','Test Mosaic Path');
if isequal(filenameT,0)
    return
end

GroundTruthMosaic = load(strcat(pathG, filenameG)).mosaic;
TestMosaic = load(strcat(pathT, filenameT)).mosaic;

if ~ GroundTruthMosaic.IsValidMosaic || ~ TestMosaic.IsValidMosaic
    disp("Not Valid Mosaics")
    return
end

if ~ length(GroundTruthMosaic.Tforms) == length(TestMosaic.Tforms)
    disp("Differing Number of Transforms")
end

instError = zeros(1,length(GroundTruthMosaic.Tforms));
cumulError = zeros(1,length(GroundTruthMosaic.Tforms));

for i = 1:length(GroundTruthMosaic.Tforms)
    instError(i) = sqrt(sum((GroundTruthMosaic.Tforms(1,i).T(3, 1:2) - TestMosaic.Tforms(1,i).T(3, 1:2)).^2));
    cumulError(i) = sqrt(sum((GroundTruthMosaic.GlobalTforms(1,i).T(3, 1:2) - TestMosaic.GlobalTforms(1,i).T(3, 1:2)).^2));
end

micron_per_pixel = 1.66; % Change to pixel size in the image
instError = instError*micron_per_pixel;
cumulError = cumulError*micron_per_pixel;

%figure

ax1 = subplot(2,1,1);
ax2 = subplot(2,1,2);
hold([ax1 ax2], 'on')
plot(ax1, instError);
plot(ax2, cumulError);
hold([ax1 ax2], 'off')