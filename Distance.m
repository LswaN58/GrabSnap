function [D] = Distance(k, theta, pixel)
term1 = -log(theta.ComponentProportion(1,k));
term2 = .5 * log(det(squeeze(theta.Sigma(:,:, k))));
%theta.mu(k, :) maybe should have k in the other position
Diff = (double(pixel(:).') - theta.mu(k, :)).';
term3 = Diff.' * inv((squeeze(theta.Sigma(:,:, k)))) * Diff .* .5;
D = term1 + term2 + term3;
end


