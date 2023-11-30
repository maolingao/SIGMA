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
function [P, trace] = sigma(X, Y, Sx, Sy,...
    Xhighres, Yhighres, SxHighres, SyHighres,...
    params)

if isempty(Xhighres) || isempty(Yhighres) || isempty(SxHighres) || isempty(SyHighres)
    Xhighres = X;
    Yhighres = Y;
    SxHighres = Sx;
    SyHighres = Sy;
end


symForm = getoptions(params, 'symForm', 1);
useCorrespondencePruning = getoptions(params, 'useCorrespondencePruning', 1);
useOrientPrev = getoptions(params, 'useOrientPrev', 0);
lambda_ori = getoptions(params, 'lambda_ori', 5e-3);
nVx = getoptions(params, 'nVx', nan);
nVy = getoptions(params, 'nVy', nan);

nx = size(X.vertices,1);
ny = size(Y.vertices,1);

Vx_supp = X.vertices(Sx,:);
Vy_supp = Y.vertices(Sy,:);

Axmat = adjacency(X);
Aymat = adjacency(Y);


%% setup
Obj = 0;
Constraints = [];
if (symForm)
    Vxvar = sdpvar(ny,size(Vy_supp,2));
end
Vyvar = sdpvar(nx,size(Vx_supp,2));

PxyVar = binvar(nVx, nVy,'full');
Constraints = [Constraints, PxyVar(:) >= 0];
Constraints = [Constraints,...
    ones(nVx,1)'*PxyVar == ones(nVy,1)', PxyVar*ones(nVy,1) == ones(nVx,1)]; % constraint permutation


%% 1. prune (incorrect) matches
if ( useCorrespondencePruning )
    paramsPruning.sortedGeodesicDistanceNumLaps = params.numLaps;
    
    [forbiddenMatchings, Dxhighres, Dyhighres] = ...
        prune_correspondeces(Xhighres,Yhighres,SxHighres,SyHighres,paramsPruning);
    
    if any(forbiddenMatchings, 'all')
        Constraints = [Constraints, PxyVar(forbiddenMatchings) == 0];
    end

else

    Dxhighres = geodesicDistance(Xhighres);
    Dyhighres = geodesicDistance(Yhighres);
end

Xhighres.Dxhighres = Dxhighres;
Yhighres.Dyhighres = Dyhighres;


%% loss - reconstruction & deformation terms

suppinfoX2Y.diameter = max(Dyhighres(:));
suppinfoX2Y.V_supp = Vy_supp;
meshinfoX2Y.Amat = Axmat;
meshinfoX2Y.X = X;
meshinfoX2Y.S = Sx;

[ObjX2Y, ConstraintX2Y] = setup_obj_sigma(PxyVar, Vyvar, meshinfoX2Y, suppinfoX2Y, params);
Obj = Obj+ObjX2Y;
Constraints = [Constraints, ConstraintX2Y];

if (symForm)
    
    suppinfoY2X.diameter = max(Dxhighres(:));
    suppinfoY2X.V_supp = Vx_supp;
    meshinfoY2X.Amat = Aymat;
    meshinfoY2X.X = Y;
    meshinfoY2X.S = Sy;
    
    [ObjY2X, ConstraintY2X] = setup_obj_sigma(PxyVar', Vxvar, meshinfoY2X, suppinfoY2X, params);
    Obj = Obj+ObjY2X;
    Constraints = [Constraints, ConstraintY2X];
end


%% loss - orientation preservation term
if (useOrientPrev)
    
    featOrtX = compute_orientation_preservation_feature(Xhighres);
    featOrtY = compute_orientation_preservation_feature(Yhighres);
    
    Obj = Obj + lambda_ori * norm(featOrtX(SxHighres) - PxyVar*featOrtY(SyHighres), 2) ./ max(nVx, nVy);
end


%% optimisation
try
    
    Ops = set_yalmip_options(params);

    yalmipOut = optimize(Constraints, Obj, Ops);
    
    trace.solvertime = yalmipOut.solvertime;
    trace.yalmiptime = yalmipOut.yalmiptime;
    trace.solverFinalObj = value(Obj);
    trace.resultStatus = yalmipOut.solveroutput.res.rcodestr;


    P  = round(value(PxyVar));

    trace.P = P;
    % reconstructed shapes
    fvRecY.vertices = value(Vyvar);
    fvRecY.faces = X.faces;
    trace.Yrec = fvRecY;
    
    
    if (symForm)
        fvRecX.vertices = value(Vxvar);
        fvRecX.faces = Y.faces;
        trace.Xrec = fvRecX;
    end
    
    trace.is_success = true;

catch
    % save the experiment trace and params for reproduce the issue
    save(strcat('log_failed.mat'), 'params', 'trace');
    trace.is_success = false;
    P = nan;
    return    

end


end
