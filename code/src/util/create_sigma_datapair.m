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
function datapair = create_sigma_datapair(Xhighres, Yhighres, SxHighres, SyHighres, nFaceLowres)

if nargin < 5
    nFaceLowres = 500;
end

%     % downsampling option 1:
%     Xlowres = reducepatch(Xhighres, nFaceLowres);
%     Ylowres = reducepatch(Yhighres, nFaceLowres);

    % downsampling option 2:
    [Vx, Fx] = decimate_libigl(Xhighres.vertices, Xhighres.faces, nFaceLowres, 'Method', 'qslim');
    Xlowres.vertices = Vx;
    Xlowres.faces = Fx;
    [Vy, Fy] = decimate_libigl(Yhighres.vertices, Yhighres.faces, nFaceLowres, 'Method', 'qslim');
    Ylowres.vertices = Vy;
    Ylowres.faces = Fy;


    SxLowres = knnsearch(Xlowres.vertices, Xhighres.vertices(SxHighres, :));
    SyLowres = knnsearch(Ylowres.vertices, Yhighres.vertices(SyHighres, :));



    datapair.Xhighres = Xhighres;
    datapair.Yhighres = Yhighres;
    datapair.SxHighres = SxHighres;
    datapair.SyHighres = SyHighres;
    datapair.X = Xlowres;
    datapair.Y = Ylowres;
    datapair.Sx = SxLowres;
    datapair.Sy = SyLowres;

    plot_point_to_polygon(eye(length(SxLowres)), Xlowres, Ylowres, SxLowres, SyLowres)
end
