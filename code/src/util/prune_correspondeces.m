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
function [forbiddenMatchings, Dx, Dy] = prune_correspondeces(X,Y,Sx,Sy,params)

try
    
    Dx = geodesicDistance(X);
    Dy = geodesicDistance(Y);
    
catch
    
    error('malfunction in computing geodesic distance matrices!')
    
end

params.Dx = Dx;
params.Dy = Dy;
[forbiddenMatchings] = ...
    sorted_geodesic_distance_constraints(X,Y,Sx,Sy,params);

end