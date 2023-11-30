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
% demo2 - Non-Isometric Shape Matching
% SHREC20 Non-Isometric Camel - Dog
clear 
close all

addpath(genpath('./src'))
addpath(genpath('./external'))
addpath(genpath('./data'))

rootpath = pwd;
cd(rootpath);

%% settings
%--- solver related
params.nThreads = 8;
params.timeout = 0.003;
params.tolAbsRelaxInt = 1e-2;       % solver inner problem stopping criteria
params.relGap = 1e-2;               % solver stopping criteria

%--- model related
params.symForm = 1;                 % use sysmetric formulation
params.objDef = 'projected-lbo-speedup';
params.lambda_rec = 2e-1;

%--- orientation preservation related
params.useOrientPrev= 0;
params.lambda_ori = 5e-3;

%--- permutation pruning related
params.useCorrespondencePruning = 1;
params.numLaps = 11;                % #allow_matchings per kp (pruning)


%% main

load('camel-dog.mat', 'datapair');
% pre-processing if needed
% datapair = create_sigma_datapair(datapair.Xhighres, datapair.Yhighres, datapair.SxHighres, datapair.SyHighres);

[P, trace] = run_sigma(datapair, params);

plot_point_to_polygon(P, datapair.X, datapair.Y, datapair.Sx, datapair.Sy);