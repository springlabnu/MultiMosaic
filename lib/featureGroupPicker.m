function [dyGood,dxGood] = featureGroupPicker(dydxSURFs, dydxPrev, dydxCorr, dydxNext)
% featureGroupPicker selects the best dydx from dydxSURFs choices by
% checking against previous motion direction and magnitude (dydxPrev) and
% the result of 2D cross correlation
% Arg. format [dy1 dy2 ...; dx1 dx2 ...; h1 h2 ...];

if nargin == 1
    dydxSURFs = double(squeeze(dydxSURFs));
    dyGood = dydxSURFs(1,1);
    dxGood = dydxSURFs(2,1);    
    
elseif ~isempty(dydxCorr) % Use case when generating sequential mosics, next dydx is not known
    dydxSURFs = double(squeeze(dydxSURFs)); 
    dydxPrev = double(dydxPrev); dydxCorr = double(dydxCorr);

    prevVel = repmat(dydxPrev, length(dydxSURFs), 1)';        
    A = atan2d(prevVel(1,:),prevVel(2,:)) - atan2d(dydxSURFs(1,:),dydxSURFs(2,:));
    A = A - 360*(A > 180) + 360*(A < -180); % Re-map angles > 180 

    corrVel = repmat(dydxCorr, length(dydxSURFs), 1)';
    deltav = sum((corrVel-dydxSURFs(1:2,:)).^2, 1);

    SURFscore = (max(dydxSURFs(3,:)) - abs(dydxSURFs(3,:)))/max(dydxSURFs(3,:));
    Ascore = abs(A)/180;
    Corrscore = deltav/max(deltav); 

    [~, minIndex] = min(SURFscore + Ascore + Corrscore);        
    dyGood = dydxSURFs(1,minIndex);
    dxGood = dydxSURFs(2,minIndex);    
    
else % Auto-fixing alignments, corr is wrong but we know next
    dydxSURFs = double(squeeze(dydxSURFs)); 
    dydxPrev = double(dydxPrev); dydxNext = double(dydxNext);

    SURFscore = (max(dydxSURFs(3,:)) - abs(dydxSURFs(3,:)))/max(dydxSURFs(3,:));
    Ascore = zeros(1, length(SURFscore));
    Bscore = zeros(1, length(SURFscore));

    if ~isempty(dydxPrev)
        prevVel = repmat(dydxPrev, length(dydxSURFs), 1)';        
        A = atan2d(prevVel(1,:),prevVel(2,:)) - atan2d(dydxSURFs(1,:),dydxSURFs(2,:));
        A = A - 360*(A > 180) + 360*(A < -180); % Re-map angles > 180     
        Ascore = abs(A)/180;
    end
    
    if ~isempty(dydxNext)
        nextVel = repmat(dydxNext, length(dydxSURFs), 1)';
        B = atan2d(nextVel(1,:),nextVel(2,:)) - atan2d(dydxSURFs(1,:),dydxSURFs(2,:));
        B = B - 360*(B > 180) + 360*(B < -180); % Re-map angles > 180 
        Bscore = abs(B)/180;
    end

    [~, minIndex] = min(SURFscore + Ascore + Bscore);        
    dyGood = dydxSURFs(1,minIndex);
    dxGood = dydxSURFs(2,minIndex);     
end





