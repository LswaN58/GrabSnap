function [D] = Distance(a, k, fg_GMM, bg_GMM, pixel)
if(a == 0)
    theta = bg_GMM;
else
    theta = fg_GMM;
end
term1 = -log(theta.ComponentProportion(1,k));
term2 = .5 * log(det(squeeze(theta.Sigma(:,:, k))));
%theta.mu(k, :) maybe should have k in the other position
Diff = (double(pixel(:).') - theta.mu(k, :)).';
term3 = Diff.' * inv((squeeze(theta.Sigma(:,:, k)))) * Diff .* .5;
D = term1 + term2 + term3;
end


