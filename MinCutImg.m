function [energy, cut] = MinCutImg(img, im_graph, beta, A, T, GMM_fg, GMM_bg)
    [height, width, ~] = size(img);
    im_graph.Edges.Weight = GenerateAllEdgeWeights(img, im_graph, beta, A, T, GMM_fg, GMM_bg)';
    disp('Finding max flow');
    tic
    [energy, ~, fg_pix, bg_pix] = maxflow(im_graph, height*width+1, height*width+2);
    toc
    cut = zeros(height, width);
    real_fg_pix = fg_pix(fg_pix ~= height*width+1);
    cut(real_fg_pix) = 1;
end


function weights = GenerateAllEdgeWeights(img, im_graph, beta, A, T, GMM_fg, GMM_bg)
    % Note, pixel_edges are edges connecting a pixel to a pixel;
    % terminal_edges connect a pixel with a terminal.
    [m, n, ~] = size(img);
    source = m*n+1;
    sink = m*n+2;
    % find indices of each of the types of edges.
    pixel_edge_indices = find(...
        (im_graph.Edges.EndNodes(:, 1) ~= source) & (im_graph.Edges.EndNodes(:, 1) ~= sink)...
      & (im_graph.Edges.EndNodes(:, 2) ~= source) & (im_graph.Edges.EndNodes(:, 2) ~= sink)...
     );
    terminal_edge_indices = find(...
        (im_graph.Edges.EndNodes(:, 1) == source) | (im_graph.Edges.EndNodes(:, 1) == sink)...
      | (im_graph.Edges.EndNodes(:, 2) == source) | (im_graph.Edges.EndNodes(:, 2) == sink)...
     );
    % retrieve actual edges of each type, so weights can be determined.
    pixel_edges = [im_graph.Edges.EndNodes(pixel_edge_indices, :)]';
    terminal_edges = [im_graph.Edges.EndNodes(terminal_edge_indices, :)]';
    % Generate the edge weights
    disp('Finding pixel edge weights');
    tic
    pixel_edge_weights = WeightPixelEdges(pixel_edges, size(img), A, beta);
    toc
    terminal_edge_weights = WeightTerminalEdges(terminal_edges, img, T, GMM_fg, GMM_bg);
    weights = zeros(1, size(pixel_edges, 1) + size(terminal_edges, 1));
    weights(1, pixel_edge_indices) = pixel_edge_weights;
    weights(1, terminal_edge_indices) = terminal_edge_weights;
end

function weights = WeightPixelEdges(edges, im_size, A, beta)
% function to add weights to each edge in a set of pixel edges.
    height = im_size(1);
    [~, num_edge] = size(edges);
    weights = zeros(1, num_edge);
    for i = 1:num_edge
        col_s = floor((edges(1, i)-1) / height)+1;
        row_s = edges(1, i) - (col_s-1)*height;
        col_d = floor((edges(2, i)-1) / height)+1;
        row_d = edges(2, i) - (col_d-1)*height;
        weights(i) = GenPixelEdgeWeight(row_s, col_s, row_d, col_d, A, beta);
    end
end

function weights = WeightTerminalEdges(term_edges, img, T, GMM_fg, GMM_bg)
% function to create a matrix of edges from the terminals to each pixel.
% for an MxN image, returns an MxNx2 matrix,
% where each entry is a cell, holding array [weight].
% first layer is source edges, second is sink edges.
    lambda = 100;
    % Get dimension info, initialize data.
    [m, n, ~] = size(T);
    source = m*n+1;
    sink = m*n+2;
    src_edge_ind = find( (term_edges(1, :) == source) | (term_edges(2, :) == source) );
    sink_edge_ind = find( (term_edges(1, :) == sink) | (term_edges(2, :) == sink) );
    % indices of pixels linked to source/sink nodes.
    src_pix_ind = min(term_edges(:, src_edge_ind));
    sink_pix_ind = min(term_edges(:, sink_edge_ind));
    % T-values of pixels linked to source/sink nodes.
    src_pix_T_vals = T(src_pix_ind);
    sink_pix_T_vals = T(sink_pix_ind);
    % indices of free, fg, and bg pixels,
    % within the previous src_ind or sink_ind lists.
    bg_src_ind_ind = find(src_pix_T_vals == 0);
    free_src_ind_ind = find(src_pix_T_vals == 1);
    fg_src_ind_ind = find(src_pix_T_vals == 2);
    bg_sink_ind_ind = find(sink_pix_T_vals == 0);
    free_sink_ind_ind = find(sink_pix_T_vals == 1);
    fg_sink_ind_ind = find(sink_pix_T_vals == 2);
    % pixel values for each grouping of free pixels above.
    free_src_pix_vals = cat(1, img(src_pix_ind(free_src_ind_ind)),...
                               img(src_pix_ind(free_src_ind_ind)+(m*n)),...
                               img(src_pix_ind(free_src_ind_ind)+(2*m*n)));
    free_sink_pix_vals = cat(1, img(sink_pix_ind(free_sink_ind_ind)),...
                                img(sink_pix_ind(free_sink_ind_ind)+(m*n)),...
                                img(sink_pix_ind(free_sink_ind_ind)+(2*m*n)));
    % edge weights for each grouping of pixels.
    bg_src_wts = zeros(1, length(bg_src_ind_ind));
    free_src_wts = lambda * 1./MinimumDistance(GMM_fg, free_src_pix_vals);
    fg_src_wts = inf*ones(1, length(fg_src_ind_ind));
    bg_sink_wts = inf*ones(1, length(bg_sink_ind_ind));
    free_sink_wts = lambda * 1./MinimumDistance(GMM_bg, free_sink_pix_vals);
    fg_sink_wts = zeros(1, length(fg_sink_ind_ind));
    
    weights(src_edge_ind(bg_src_ind_ind))     = bg_src_wts;
    weights(src_edge_ind(free_src_ind_ind))   = free_src_wts;
    weights(src_edge_ind(fg_src_ind_ind))     = fg_src_wts;
    weights(sink_edge_ind(bg_sink_ind_ind))   = bg_sink_wts;
    weights(sink_edge_ind(free_sink_ind_ind)) = free_sink_wts;
    weights(sink_edge_ind(fg_sink_ind_ind))   = fg_sink_wts;
end

function edge_weight = GenPixelEdgeWeight(row1, col1, row2, col2, A, beta)
    edge_pix = [row1, col1; row2, col2];
    edge_a = [A(row1, col1); A(row2, col2)];
    edge_weight = EdgeSmoothness(edge_pix, edge_a, beta);
end