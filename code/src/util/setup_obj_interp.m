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
%                              Marvin Eisenberger (marvin.eisenberger[at]in[dot]tum[dot]de)
%
function [Obj, Constraint] = setup_obj_interp(Vvar, meshinfo, suppinfo, params)

normType = getoptions(params, 'normType', 'fro');
lambda_rec = getoptions(params, 'lambda_rec', 0.2);
objDef = getoptions(params, 'objDef', 'projected-lbo-speedup');

% meshinfo: all from the same mesh
X = meshinfo.X;
S = meshinfo.S;
V_supp_aligned = suppinfo.V_supp_aligned;
diameter = suppinfo.diameter;

if isa(Vvar,'sdpvar') && ~isempty(suppinfo)
    Constraint = [];
else
    % we just want to evaluate the objective
    Constraint = nan;

    % switch to the objective evaluation mode
    if strcmp(objDef, 'projected-lbo-speedup')
        objDef = 'projected-lbo';
    end
end

%% deformation loss
switch objDef
    case 'lbo'
        
        Lcot = cotmatrix(X.vertices, X.faces);
        Laplacian = Lcot;
        
        % || L x ||_2
        Obj = norm(Laplacian*Vvar,normType) / (diameter * numel(Vvar));


    case 'projected-lbo' % for objective evaluation

%         pi = eye(nv) - xProj*xProj';
%         plbo = pi'*Lcot*pi;

        Lcot = cotmatrix(X.vertices, X.faces);
        [~, xProj] = orthoProjector([X.vertices, ones(size(X.vertices, 1), 1)]);
        vProj = Vvar - xProj * (xProj' * Vvar);
        vLap = Lcot * vProj;
        
        Obj = norm(vLap - xProj * (xProj' * vLap), normType) / (diameter * numel(Vvar));

		
        
    case 'projected-lbo-speedup' 
        % https://yalmip.github.io/tutorial/quadraticprogramming/
        % it can't be used for objective evaluation

        Lcot = cotmatrix(X.vertices, X.faces);
        [xProj, ~] = qr([X.vertices, ones(size(X.vertices, 1), 1)],0);

        s = sdpvar(4, size(Vvar, 2));
        t = sdpvar(4, size(Vvar, 2));
        vProj = Vvar - xProj * s;
        vLap = Lcot * vProj;

        Obj = norm(vLap - xProj * t, normType) / (diameter * numel(Vvar));

        Constraint = [Constraint; s == xProj' * Vvar; t == xProj' * vLap];

    otherwise
        error('unknown objDef mode!')
end


%% reconstruction loss
if ( lambda_rec > 0 )
    Obj = Obj + (lambda_rec/diameter) *norm(Vvar(S,:) - V_supp_aligned ,normType)/numel(V_supp_aligned);
    
end

end

