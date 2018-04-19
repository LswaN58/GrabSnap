function [D] = Distance(k, theta, pixel)
term1 = -log(theta.ComponentProportion(1,k));
term2 = .5 * log(det(squeeze(theta.Sigma(:,:, k))));
%theta.mu(k, :) maybe should have k in the other position
%Diff = (double(pixel(:).') - theta.mu(k, :)).';
Diff = (double(pixel) - theta.mu(k, :)');
prod_right = inv((squeeze(theta.Sigma(:,:, k)))) * Diff;
% Below, use a brilliant trick from StackOverflow for computing only the
% diagonals of the matrix product.
term3 = 0.5.*sum(Diff' .* prod_right', 2);
D = term1 + term2 + term3;
end


