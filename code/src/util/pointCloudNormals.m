% This function is part of the SIGMA method as described in [1]. When you
% use this code, you are required to cite [1].
% 
% [1] SIGMA: Scale-Invariant Global Sparse Shape Matching
% Author: M. Gao, P. Roetzer, M. Eisenberger, Z. Lähner, M. Moeller, D. Cremers, F. Bernard.
% CVF/IEEE International Conference on Computer Vision 2023 (CVPR 2023)
%
% 
% Author & Copyright (C) 2023: Florian Bernard (f.bernardpi[at]gmail[dot]com)
%
function normals = pointCloudNormals(pts)
    
    ptCloud = pointCloud(pts);
    normals = pcnormals(ptCloud);
    
    % fix normal orientation
    idxQueue = 1;
    fixedIndices = 1;
    while ( ~isempty(idxQueue) )
        currIdx = idxQueue(1);
        idxQueue(1) = [];
        
        K = 3;
        [neighIndices,neighDists] = findNearestNeighbors(ptCloud,ptCloud.Location(currIdx,:),K);
        
        neighIndices = setdiff(neighIndices, fixedIndices);
        for jj=1:numel(neighIndices)
            if ( normals(neighIndices(jj),:)*normals(currIdx,:)' < 0 )
                normals(neighIndices(jj),:) = -normals(neighIndices(jj),:);
            end
            fixedIndices = union(fixedIndices, neighIndices(jj));
            idxQueue = [idxQueue, neighIndices(jj)];
        end
    end
    
end