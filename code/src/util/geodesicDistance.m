% This function is part of the SIGMA method as described in [1]. When you
% use this code, you are required to cite [1].
% 
% [1] SIGMA: Scale-Invariant Global Sparse Shape Matching
% Author: M. Gao, P. Roetzer, M. Eisenberger, Z. Lähner, M. Moeller, D. Cremers, F. Bernard.
% CVF/IEEE International Conference on Computer Vision 2023 (CVPR 2023)
%
% 
% Author & Copyright (C) 2023: Maolin Gao (maolin.gao[at]gmail[dot]com)
%                              Florian Bernard (f.bernardpi[at]gmail[dot]com)
%
function [D, adjListX] = geodesicDistance(X, rowIdx, colIdx)
    if ( isfield(X, 'faces') && ~isempty(X.faces) )
        adjListX = buildAdjacencyListFromFv(X);
        adjX = buildGraphMatrixFromAdjacencyList(adjListX, X.vertices);
    else
        nn = 3;

        adjListX = {};
        nnIdx = knnsearch(X.vertices, X.vertices, 'k', nn+1);
        for i=1:size(X.vertices,1)
            adjListX{i} = setdiff(nnIdx(i,:),i);
        end
        adjX = vertexAdjacency([], X.vertices);
    end
    adjX = 0.5*(adjX+adjX');



    [rows,cols,vals] = find(adjX);
    G = graph(rows,cols,vals);
    if ( ~exist('rowIdx', 'var') && ~exist('colId', 'var') )
        % compute full geodesic distances
        D = distances(G);
    else
        % faster for large graphs and small rowIdx/colIdx
        D = distances(G, rowIdx, colIdx);
    end
end
