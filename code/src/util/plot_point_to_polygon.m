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
function [Y_transformed, Tshift, Tglobal, Rglobal] = plot_point_to_polygon(P,X,Y,Sx,Sy)

is_binary = all(P == 1 | P==0, 'all');
assert(is_binary, 'expecting binary permutation matrix!')

matches = P2matches(P, Sx, Sy);

figure('color', 'w','units','normalized','outerposition',[0.3 0.4 0.4 0.5]);
hold on

%% align shapes
[~,~,transform] = procrustes(X.vertices(matches(:,1),:), Y.vertices(matches(:,2),:), 'reflection',0,'scaling',0);
Rglobal = transform.T;
Tglobal = transform.c(1,:);

Dx = geodesicDistance(X);
if sum(Dx==Inf,'all')~=0
    warning('mesh has disjoint components!');
    Dx(Dx==Inf) = 0;
end
Tshift = [1*max(Dx,[],'all'),0,0];

Y_transformed = Y;
Y_transformed.vertices = Y_transformed.vertices*Rglobal + Tglobal + Tshift;

%%
%
pointRadius = .02;
facealpha = 0.6;

subplot(121)
% show X
ptCol = plotSparseCorrespondence(X, Sx, pointRadius, [], ...
    struct('nolight',1,'facealpha', facealpha, 'equalPointColours', P(:,sum(P,1)>1)));
view(-20,0);


% show Y_transformed
subplot(122)
plotSparseCorrespondence(Y_transformed, [], 0.015, [], ...
    struct('nolight',1,'facealpha', facealpha));
view(-20,0)
%%
if ( isfield(Y_transformed, 'faces') && ~isempty(Y_transformed.faces) )

    Ynormals = -patchnormals(Y_transformed);
else

    Ynormals = pointCloudNormals(Y_transformed.vertices);
end
    
[r,c] = find(round(P));
for i=1:numel(c)

    colIdx = r(i);
    currVerts = Y_transformed.vertices(matches(i,2),:);
    
    ptPlusNormal = mean(currVerts,1) + pointRadius.*Ynormals(matches(i,2),:);
    ptPlusNormal = ptPlusNormal + (rand(size(ptPlusNormal)) - 0.5) * 0.5e-1;
    text(ptPlusNormal(1), ptPlusNormal(2), ptPlusNormal(3), num2str(r(i)), 'HorizontalAlignment', 'right', ...
        'VerticalAlignment', 'top', 'fontsize', 16);

    x = currVerts(:,1);
    y = currVerts(:,2);
    z = currVerts(:,3);
    scatter3(x, y, z, 80, ptCol(colIdx,:), 'markerfacecolor', ptCol(colIdx,:));
    
end


drawnow

end