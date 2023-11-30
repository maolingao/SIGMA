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
function [P, trace] = run_sigma(datapair, params)
    
    % X is a subsampled version of Xhighres,
    % see create_sigma_datapair.m for an example to obtain it.
    X = normalise_shape(datapair.X);
    Y = normalise_shape(datapair.Y);
    Xhighres = datapair.Xhighres;
    Yhighres = datapair.Yhighres;

    Sx = datapair.Sx(~isnan(datapair.Sx));
    SxHighres = datapair.SxHighres(~isnan(datapair.SxHighres));
    Sy = datapair.Sy(~isnan(datapair.Sy));
    SyHighres = datapair.SyHighres(~isnan(datapair.SyHighres));
    

    % set additional params
    params.nVx = length(Sx);               % #kp of X
    params.nVy = length(Sy);               % #kp of Y

    t = tic;
    [P, trace] = sigma(X,Y,Sx,Sy,...
        Xhighres,Yhighres,SxHighres,SyHighres,params);
    runtime = toc(t);

    trace.params = params;
    trace.totalTime = runtime;
    trace.nkpts = length(Sx);
end