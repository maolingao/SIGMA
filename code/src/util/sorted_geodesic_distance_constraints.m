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
function [forbiddenMatchings, Dx, Dy] = sorted_geodesic_distance_constraints(X,Y,Sx,Sy,params)  

    if ( ~exist('params', 'var') )
        params = [];
    end
    
    numLaps = getoptions(params, 'sortedGeodesicDistanceNumLaps', 11);
    meshRes = getoptions(params, 'sortedGeodesicDistanceMeshResolution', 'highres-control_points');
    Dx = getoptions(params, 'Dx', nan);
    Dy = getoptions(params, 'Dy', nan);
    
    if any(vec(isnan(Dx))) || any(vec(isnan(Dy)))
        
        Dx = geodesicDistance(X);
        Dy = geodesicDistance(Y);
    end


    % normalise separately to balance
    Xarea = sum(doublearea(X.vertices, X.faces))/2;
    shapeDiameterX = sqrt(Xarea);
    
    Yarea = sum(doublearea(Y.vertices, Y.faces))/2;
    shapeDiameterY = sqrt(Yarea);
    
    Dx = Dx./shapeDiameterX;
    Dy = Dy./shapeDiameterY;

    % normalise so that largest value is 1
    maxD = max([Dx(:); Dy(:)]);
    Dx = Dx./maxD;
    Dy = Dy./maxD;

    nPercentileBins = min([size(Dx,1); size(Dy,1)]);

    prctls = linspace(0,100,nPercentileBins);


    if ( strcmp('highres-control_points', meshRes) )
        dxFeat = prctile(Dx(Sx,Sx), prctls, 2);
        dyFeat = prctile(Dy(Sy,Sy), prctls, 2);
    else
        dxFeat = prctile(Dx(Sx,:), prctls, 2);
        dyFeat = prctile(Dy(Sy,:), prctls, 2);
    end

    % remove zero columns
    zeroCols = find( (sum(dxFeat,1)==0) | (sum(dyFeat,1)==0));

    dxFeat(:,zeroCols) = [];
    dyFeat(:,zeroCols) = [];
   
    diffs = pdist2(dxFeat, dyFeat, 'euclidean');
    
    
    % ensure feasibility
    forbiddenMatchings = ones(numel(Sx), numel(Sy));
    diffsTmp = diffs;
    
    for i=1:numLaps
        P = projectOntoPartialPermBlockwise(-1e4*diffsTmp);
        diffsTmp(P>0) = (numel(Sy)+1)*max(diffs(:));
        forbiddenMatchings(P>0) = 0;
    end
    
    
    forbiddenMatchings = logical(forbiddenMatchings);
    
end