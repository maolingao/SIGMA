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
function [Obj, Constraint] = setup_obj_sigma(Pvar, Vvar, meshinfo, suppinfo, params)

% determine supports
V_supp = suppinfo.V_supp;
V_supp_aligned = Pvar*V_supp;


suppinfo.V_supp_aligned = V_supp_aligned;
[Obj, Constraint] = setup_obj_interp(Vvar, meshinfo, suppinfo, params);


end