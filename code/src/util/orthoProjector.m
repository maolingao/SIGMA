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
function [M, q, r] = orthoProjector(X)
    [n,m] = size(X);
%     if (m~=3)
%         error('Something went wrong')
%     end

    [q,r] = qr(X,0);
    M = eye(n)-q*q';
    
end


function test
%% 
points = randn(123,3);
[M,q,r] = orthoProjector(points);
sum((M*points).^2,'all')


sum((M*randn(123,1)*1e2).^2,'all')

end
