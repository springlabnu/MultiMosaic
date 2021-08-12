function [refinedMatches1,refinedMatches2] = refineMatches(matches1,matches2,dyGood,dxGood,tolerance)
%refineMatches Returns matches1, matches2 that are within tolerance
%of dyGood and dxGood location. 
xerror = matches1.Location(:,1) - matches2.Location(:,1) - single(dxGood);
yerror = matches1.Location(:,2) - matches2.Location(:,2) - single(dyGood);
matches_NCCv = intersect(find(abs(yerror)<tolerance),  find(abs(xerror)<tolerance));
refinedMatches1 = matches1(matches_NCCv);
refinedMatches2 = matches2(matches_NCCv);
end

