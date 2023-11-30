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
function ptCol = plotSparseCorrespondence(X, Sx, radius, ptCol, params)
    if ( ~exist('params', 'var') )
        params = [];
    end
    if ( ~exist('Sx', 'var') )
        Sx = [];
    end
    
    if ( ~exist('radius', 'var') || isempty(radius) )
        radius = 0.05;
    end
    
    defaultColorMap = @(x) lines(x);
    if ( ~isempty(Sx) && ( ~exist('ptCol', 'var') || isempty(ptCol) ))
        ptCol = defaultColorMap(size(Sx,1));
    end
    
    
    
    edgeColor = getoptions(params, 'edgeColor', 'none');
    facealpha = getoptions(params, 'facealpha', 1);
    facevertexcdata = getoptions(params, 'facevertexcdata', []);
    equalPointColours = getoptions(params, 'equalPointColours', []);
    
    for i=1:size(equalPointColours,2)
        idx = find(equalPointColours(:,i));
        ptCol(idx,:) = repmat(ptCol(idx(1),:), numel(idx), 1);
    end
    
    if ( ~isempty(X) && ~isempty(facevertexcdata) )
        X.FaceVertexCData = facevertexcdata;
        facecol = 'interp';
    else
        facecol = 0.6*ones(1,3);
    end
    
    %% vis
    
    if ( ~isempty(X) && isfield(X,'faces'))

        Xarea = sum(doublearea(X.vertices, X.faces))/2;
        shapeDiameter = sqrt(Xarea);
        
        if ~isempty(X.faces)
            patch('Faces',X.faces, 'Vertices', X.vertices, ... %'facecolor', 'interp', 'facealpha', facealpha,...%
                'edgecolor', edgeColor, ...
                'facecolor', facecol,...
                'facealpha', facealpha, ...
                'FaceLighting', 'gouraud', 'AmbientStrength',0.3, 'DiffuseStrength',0.8,...
                'SpecularStrength', 0, 'SpecularExponent', 10, 'SpecularColorReflectance', 1);
        else
            plot3(X.vertices(:,1),X.vertices(:,2), X.vertices(:,3), 'ro', 'MarkerSize', 0.5);
            shapeDiameter=1;
        end
    else

        yVals = X.vertices(:,2);
        yVals = (yVals-min(yVals))/(max(yVals)-min(yVals));
        yColIdx = round(yVals*(size(X.vertices,1)-1))+1;
        colsPc = copper(size(X.vertices,1));
        pcshow(X.vertices, colsPc(yColIdx,:),"BackgroundColor",[1 1 1], "MarkerSize", 200);
        shapeDiameter = 1;
    end
    pointRadius = radius*shapeDiameter;
    
    warning off;
    axis equal
    axis tight
    axis off
    warning on;    
    
    hold on
    
    try
        Xnormals = -patchnormals(X);
    catch 
        Xnormals = pointCloudNormals(X.vertices);
    end

    for i=1:size(Sx,1)
        if ( size(Sx,2) == 3 )
            Xpti = Sx(i,:);
        else
            Xpti = X.vertices(Sx(i),:);
        end

        load('sphereFv.mat');
        sphereFv.vertices = bsxfun(@plus, sphereFv.vertices.*pointRadius, Xpti);
        
        patch(sphereFv, 'linestyle', 'none', 'facecolor', ptCol(i,:), ...
            'FaceLighting', 'gouraud', 'AmbientStrength',0.3, 'DiffuseStrength',0.8,...
            'SpecularStrength', 0, 'SpecularExponent', 10, 'SpecularColorReflectance', 1);
        
        ptPlusNormal = Xpti + pointRadius.*Xnormals(Sx(i),:);
        text(ptPlusNormal(1), ptPlusNormal(2), ptPlusNormal(3), num2str(i), 'HorizontalAlignment', 'right', ...
            'VerticalAlignment', 'top', 'fontsize', 16);
    end
    
    cameratoolbar show
    cameratoolbar('SetMode','orbit')
    cameratoolbar('SetCoordSys','none')
    
    if ( ~isfield(params, 'nolight') )
        camlight right
        camlight left
    end
    material dull
    lighting gouraud;

    camlight right
    camlight left
    camlight(90,-70);
    camlight(180,0);
    
end