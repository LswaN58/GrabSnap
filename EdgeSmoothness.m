function [ smooth_weight ] = EdgeSmoothness( edge_pix, edge_a, beta )
% function that takes the pixels and alphas associated with a given edge,
% and a parameter beta, then calculates the smoothness term for that edge.
% edge_pix should be 2x3, with one RGB pixel in each row,
% and edge_a should be 2x1, one alpha in each row.
    if edge_a(1) ~= edge_a(2)
        color_dist = (edge_pix(1,:) - edge_pix(2,:)).^2;
        smooth_weight = exp(-beta * sum(color_dist));
    else
        smooth_weight = 0;
    end
end

