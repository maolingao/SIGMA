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
function [ Gf, Gv ] = vert_grads( surface , H)

% compute its gradient
Gf = face_grads(surface, H);

% normalize it so that it has unit norm
vn  = sqrt(sum(Gf'.^2))';
vn = vn + eps;
vn = repmat(vn,1,3);
Gf = Gf./vn;


nv = surface.nv;
Gv = nan(nv, 3);
for i = 1:nv
    idx = find(any(surface.faces==i, 2));
    Gv(i,:) = sum(Gf(idx,:),1) / length(idx);
end

vn  = sqrt(sum(Gv'.^2))';
vn = vn + eps;
vn = repmat(vn,1,3);
Gv = Gv./vn;



end