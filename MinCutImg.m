function [energy, cut] = MinCutImg(img, A, T, compAssignments, GMM_fg, GMM_bg)
    [height, width, depth] = size(img);
    edges = GenerateAllWeightedEdges(img, A, T, compAssignments, GMM_fg, GMM_bg);
    disp(['Edge count: ', num2str(length(edges))])
    disp('Starting creation of graph');
    tic
    G = graph(edges(1, :), edges(2, :), edges(3, :));
    toc
    [energy, ~, fg_pix, bg_pix] = maxflow(G, height*width+1, height*width+2);
    cut = zeros(height, width);
    for i = 1:length(fg_pix)
        if (fg_pix(i) ~= height*width+1)
            col = floor((fg_pix(i)-1) / height)+1;
            row = fg_pix(i) - (col-1)*height;
            %row = floor((fg_pix(i)-1) / width)+1;
            %col = fg_pix(i) - (row-1)*width;
            cut(row, col) = 1;
        end
    end
end

function weighted_edges = GenerateAllWeightedEdges(img, A, T, compAssignments, GMM_fg, GMM_bg)
    % Note, pixel_edges are edges connecting a pixel to a pixel;
    % terminal_edges connect a pixel with a terminal.
    disp('Starting generating normal edges');
    tic
    pixel_edges = GenerateUnweightedPixelEdges(img);
    beta = GenerateBeta(img, pixel_edges);
    pixel_edges = weightPixelEdges(pixel_edges, size(img), A, beta);
    non_zeros = find(pixel_edges(3, :) ~= 0);
    pixel_edges = pixel_edges(:, non_zeros);
    toc
    
    disp('Starting generating terminal edges');
    tic
    terminal_edges = GenerateTerminalEdges(img, A, T, compAssignments, GMM_fg, GMM_bg);
    toc
    weighted_edges = [pixel_edges, terminal_edges];
end

function edges = GenerateUnweightedPixelEdges(img)
% function to generate all edges of neighboring pixels in an image of given dimensions.
% dimensions should simply be [height, width] of the image.
% Uses neighborhoods of radius 1 (8-neighborhoods).
% The edges matrix has two rows, where each column contains endpoint
% indices of an edge. Indices are based on row-wise walk of input image.
% The indices are simply used to denote a vertex in graph.
% Edge weights must be added later.
    [height, width, ~] = size(img);
    num_interior_edges = 4*(height-2)*(width-2);
    num_boundary_edges = 5*(height-2) + 5*(width-2) + 6;
    expected_num_edges = num_interior_edges + num_boundary_edges;
    num_edges = 1;
    edge_origs = zeros(1, expected_num_edges);
    edge_dests = zeros(1, expected_num_edges);
    for row = 1:height-1
        % first, do horizontal edges
        for col = 1:width-1
            index = (col-1)*height + row;
            edge_origs(num_edges) = index;
            edge_dests(num_edges) = index+height;
            num_edges = num_edges + 1;
        end
        % next, do vertical edges
        for col = 1:width
            index = (col-1)*height + row;
            edge_origs(num_edges) = index;
            edge_dests(num_edges) = index+1;
            num_edges = num_edges + 1;
        end
        % next, diagonal edges to right
        for col = 1:width-1
            index = (col-1)*height + row;
            edge_origs(num_edges) = index;
            edge_dests(num_edges) = index+height+1;
            num_edges = num_edges + 1;
        end
        % then diagonal edges to left
        for col = 2:width
            index = (col-1)*height + row;
            edge_origs(num_edges) = index;
            edge_dests(num_edges) = index-height+1;
            num_edges = num_edges + 1;
        end
    end
    % finally, add last row of horizontal edges.
    row = height;
    for col = 1:width-1
        index = (col-1)*height + row;
        edge_origs(num_edges) = index;
        edge_dests(num_edges) = index+height;
        num_edges = num_edges + 1;
    end
    if num_edges-1 ~= expected_num_edges
        error('number of edges added doesn''t match expected number');
    end
    edges = [edge_origs; edge_dests];
end

function weighted_edges = weightPixelEdges(edges, im_size, A, beta)
% function to add weights to each edge in a set of pixel edges.
    height = im_size(1);
    [~, num_edge] = size(edges);
    weights = zeros(1, num_edge);
    for i = 1:num_edge
        col_s = floor((edges(1, i)-1) / height)+1;
        row_s = edges(1, i) - (col_s-1)*height;
        col_d = floor((edges(2, i)-1) / height)+1;
        row_d = edges(2, i) - (col_d-1)*height;
        weights(i) = GenerateEdgeWeight(row_s, col_s, row_d, col_d, A, beta);
    end
    weighted_edges = [edges; weights];
end

function edges = GenerateTerminalEdges(img, A, T, compAssignments, GMM_fg, GMM_bg)
% function to create a matrix of edges from the terminals to each pixel.
% for an MxN image, returns an MxNx2 matrix,
% where each entry is a cell, holding array [weight].
% first layer is source edges, second is sink edges.
    lambda = 100;
    % Get dimension info, initialize data.
    [m, n, ~] = size(img);
    source = m*n+1;
    sink = m*n+2;
    bg_pix = find(T == 0)';
    free_pix = find(T == 1)';
    fg_pix = find(T == 2)';
    src_edges = zeros(3, length(fg_pix) + length(free_pix));
    dest_edges = zeros(3, length(bg_pix) + length(free_pix));
    
    % Grab pixel vals for each channel (offset of m*n from each other) for
    % all free pixels.
    free_pixel_vals = cat(1, img(free_pix), img(free_pix+(m*n)), img(free_pix+(2*m*n)));
    % Find min distances for each free pixel.
    [free_pixel_fg_dists, ~] = MinimumDistance(GMM_fg, free_pixel_vals);
    free_pixel_fg_weights = lambda * 1./free_pixel_fg_dists;
    [free_pixel_bg_dists, ~] = MinimumDistance(GMM_bg, free_pixel_vals);
    free_pixel_bg_weights = lambda * 1./free_pixel_bg_dists;
    % create edges from source to fg and free pixels, concatenated
    % together.
    src_edges(:, :) = [...
        [source*ones(1, length(fg_pix)); fg_pix; inf*ones(1, length(fg_pix))], ...
        [source*ones(1, length(free_pix)); free_pix; free_pixel_fg_weights] ];
    dest_edges(:, :) = [...
        [sink*ones(1, length(bg_pix)); bg_pix; inf*ones(1, length(bg_pix))], ...
        [sink*ones(1, length(free_pix)); free_pix; free_pixel_bg_weights] ];
    edges = [src_edges, dest_edges];
end

function beta = GenerateBeta(img, edges)
    [~, num_edge] = size(edges);
    [height, width, ~] = size(img);
    sum_square_diffs = 0;
    count = 0;
    for i = 1:num_edge
        col_s = floor((edges(1, i)-1) / height)+1;
        row_s = edges(1, i) - (col_s-1)*height;
        col_d = floor((edges(2, i)-1) / height)+1;
        row_d = edges(2, i) - (col_d-1)*height;
        p1 = img(row_s, col_s, :);
        p2 = img(row_d, col_d, :);
        sum_square_diffs = sum_square_diffs + sum((p1-p2).^2);
        count = count + 1;
    end
    avg = sum_square_diffs / count;
    beta = 1./(2.*avg);
end

function edge_weight = GenerateEdgeWeight(row1, col1, row2, col2, A, beta)
    edge_pix = [row1, col1; row2, col2];
    edge_a = [A(row1, col1); A(row2, col2)];
    edge_weight = EdgeSmoothness(edge_pix, edge_a, beta);
end