% This function is part of the SIGMA method as described in [1]. When you
% use this code, you are required to cite [1].
% 
% [1] SIGMA: Scale-Invariant Global Sparse Shape Matching
% Author: M. Gao, P. Roetzer, M. Eisenberger, Z. Lähner, M. Moeller, D. Cremers, F. Bernard.
% CVF/IEEE International Conference on Computer Vision 2023 (CVPR 2023)
%
% 
% Author & Copyright (C) 2023: Maolin Gao (maolin.gao[at]gmail[dot]com)
%
function X = normalise_shape(X)
% normalise shape to have coordinates in [0,1]

if isfield(X,'vertices')
    v = X.vertices;
    F = X.faces;
else
    v = X.VERT;
    F = X.TRIV;
end

v = v/sqrt(sum(doublearea(v,F)*0.5));
v = bsxfun(@minus, v, centroid(v,F));

if isfield(X,'vertices')
    X.vertices = v;
else
    X.VERT = v;
end
end
