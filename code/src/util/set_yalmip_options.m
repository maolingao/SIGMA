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
function Ops = set_yalmip_options(params)

Ops = sdpsettings('solver','mosek','verbose',1, 'debug',1, 'savesolveroutput',1,...
   'savedebug', 1);
Ops.mosek.MSK_DPAR_MIO_MAX_TIME = params.timeout*3600;
Ops.mosek.MSK_DPAR_OPTIMIZER_MAX_TIME = params.timeout*3600;
Ops.mosek.MSK_DPAR_MIO_TOL_REL_GAP = params.relGap;
Ops.mosek.MSK_DPAR_MIO_TOL_ABS_RELAX_INT = params.tolAbsRelaxInt;
Ops.mosek.MSK_IPAR_NUM_THREADS = params.nThreads;

Ops.savesolveroutput = 1;
Ops.cachesolvers = 1; 
end