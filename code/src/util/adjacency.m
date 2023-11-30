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
function [ A ] = adjacency( M )
%ADJACENCY Buld adjacency matrix A from mesh M
%   M is a struct containing the m-by-3 matrix M.tri
%   Returns n-by-n adjacency matrix A, where n is the number of vertices.
%   A(i,j)==1 iff vertex i is adjacent to vertex j.
if ~isfield(M,'TRIV')
    M.TRIV = M.faces;
end

tic;
fprintf('Computing the adjacency matrix...');
numberOfFaces = size(M.TRIV,1);
numberOfVertices = max(max(M.TRIV));

A = zeros(numberOfVertices);
for i=1:numberOfFaces
    
    v1 = M.TRIV(i,1);
    v2 = M.TRIV(i,2);
    v3 = M.TRIV(i,3);
    
    A(v1,v2) = 1;
    A(v2,v3) = 1;
    A(v3,v1) = 1;
   
    A(v1,v3) = 1;
    A(v2,v1) = 1;
    A(v3,v2) = 1; 

end

A = sparse(A);

fprintf('done, took %f .\n', toc);

end

