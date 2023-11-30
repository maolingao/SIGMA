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
function G = buildGraphMatrixFromAdjacencyList(adjacencyList, vertexFeatures)
    N = numel(adjacencyList);
    
    G = sparse(N,N);
    for l=1:N
        neighs = setdiff(unique(adjacencyList{l}),l);
        
        for neighIdx=1:numel(neighs)
            currNeigh = neighs(neighIdx);
            
            % set lower triangle of G
            if ( currNeigh > l )
                rowIdx = currNeigh;
                colIdx = l;
            else
                rowIdx = l;
                colIdx = currNeigh;
            end
            
            if ( G(rowIdx,colIdx) == 0 )
                if ( exist('vertexFeatures', 'var')  )
                    G(rowIdx,colIdx) = norm(vertexFeatures(rowIdx,:)-vertexFeatures(colIdx,:));
                else
                    G(rowIdx,colIdx) = 1;
                end
            end
        end
    end
end