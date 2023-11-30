function [WV,WQ,WJ] = wireframe(V,Q,thickness,offset)
  %   offset  (not exactly the same as what Blender is doing)
  ss = size(Q,2);
  switch ss
  case 4
    E = [ ...
      Q(:,[2 3]); ...
      Q(:,[3 4]); ...
      Q(:,[4 1]); ...
      Q(:,[1 2])];
    % Normal for each corner
    N = [ ...
      cross(V(Q(:,2),:)-V(Q(:,1),:),V(Q(:,4),:)-V(Q(:,1),:),2); ...
      cross(V(Q(:,3),:)-V(Q(:,2),:),V(Q(:,1),:)-V(Q(:,2),:),2); ...
      cross(V(Q(:,4),:)-V(Q(:,3),:),V(Q(:,2),:)-V(Q(:,3),:),2); ...
      cross(V(Q(:,1),:)-V(Q(:,4),:),V(Q(:,3),:)-V(Q(:,4),:),2)];
    % Offset for each corner
    O = thickness/4*[ ...
      (V(Q(:,2),:)-V(Q(:,1),:))+(V(Q(:,4),:)-V(Q(:,1),:)); ...
      (V(Q(:,3),:)-V(Q(:,2),:))+(V(Q(:,1),:)-V(Q(:,2),:)); ...
      (V(Q(:,4),:)-V(Q(:,3),:))+(V(Q(:,2),:)-V(Q(:,3),:)); ...
      (V(Q(:,1),:)-V(Q(:,4),:))+(V(Q(:,3),:)-V(Q(:,4),:))];
  case 3
    E = [ ...
      Q(:,[2 3]); ...
      Q(:,[3 1]); ...
      Q(:,[1 2]); ...
      ];
    % face normals;
    N = normalizerow(normals(V,Q));
    % corner normals
    N= repmat(N,3,1);
    % corner offset
    O = thickness/4*[ ...
      (V(Q(:,2),:)-V(Q(:,1),:))+(V(Q(:,3),:)-V(Q(:,1),:)); ...
      (V(Q(:,3),:)-V(Q(:,2),:))+(V(Q(:,1),:)-V(Q(:,2),:)); ...
      (V(Q(:,1),:)-V(Q(:,3),:))+(V(Q(:,2),:)-V(Q(:,3),:))];
  end
  
  %WV = [V;
  
  % number of vertices
  n = size(V,1);
  % number of faces
  m = size(Q,1);
  % per-vertex normals
  VN = normalizerow(full(sparse(repmat(Q(:),1,3),repmat(1:3,numel(Q),1),N,n,3)));
  if offset ~= 0
    [WV,WQ,WJ] = wireframe(V+VN*offset*thickness/2,Q,thickness,0);
    return;
  end
  WV = [ ... 
    V+thickness/2*VN; ... +n
    V-thickness/2*VN; ... +n
    V(Q,:) + O;       ... +ss*m
    ];
  I = (1:m*ss)';
  WQO = [E 2*n+[I([2*m+1:end 1:2*m]) I([m+1:end 1:m])]];
  WQI = fliplr(WQO+[n n 0 0]);
  WQ = [WQO;WQI];
  WJ = repmat(1:size(Q,1),1,2*ss)';
end
