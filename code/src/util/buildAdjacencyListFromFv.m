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
function adjacencyList = buildAdjacencyListFromFv(fv)

    if ( size(fv.faces,2) == 4 )
        fv = quadrilateral2triangluar(fv);
    elseif ( size(fv.faces,2) > 4 )
        error('Only triangular and quadrilateral meshes are supported');
    end
    vertexFeatures = fv.vertices;
    faces = fv.faces;
    
    nFaces = size(faces,1);
    N = size(vertexFeatures,1);

    adjacencyList = cell(1,N);
    
    for f=1:nFaces
        neighs = faces(f,:);

        for n=1:numel(neighs)
            % add all vertices but neighs(n)
            adjacencyList{neighs(n)} = [adjacencyList{neighs(n)} neighs(neighs~=neighs(n))];
        end
    end
end