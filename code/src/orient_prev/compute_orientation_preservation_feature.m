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
function feat_ort = compute_orientation_preservation_feature(S)

numEvecs = 50;
numTimes = 100;

S = compute_LaplacianBasis(S, numEvecs);
B = S.evecs(:,1:numEvecs); Ev = S.evals(1:numEvecs);
wks = waveKernelSignature(B, Ev, S.A, numTimes);

% surface and vertex normals
S.normals_face = normals(S.vertices, S.faces);
S.normals_face = S.normals_face./sqrt(sum(S.normals_face.^2, 2));
S.normals_vertices = per_vertex_normals(S.vertices, S.faces);

% gradient of functions
[Gf_wks1, Gv_wks1] = vert_grads( S , wks(:,1));
[Gf_wks2, Gv_wks2] = vert_grads( S , wks(:,70));


feat_ort = sum(cross(Gv_wks1, Gv_wks2).*S.normals_vertices, 2);


% figure
% tsurf(S.faces, S.vertices, 'CData', feat_ort); axis equal; shading interp;


end