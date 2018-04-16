function [energy, cut] = MinCutImg(img, A, T, compAssignments, GMM_fg, GMM_bg)
    [height, width, depth] = size(img);
    edges = GenerateAllWeightedEdges(img, A, T, compAssignments, GMM_fg, GMM_bg);
    G = graph(edges(1, :), edges(2, :), edges(3, :));
    [energy, ~, fg_pix, bg_pix] = maxflow(G, height*width+1, height*width+2);
    cut = zeros(height, width);
    for i = 1:length(fg_pix)
        if (fg_pix(i) ~= height*width+1)
            row = floor((fg_pix(i)-1) / width)+1;
            col = fg_pix(i) - (row-1)*width;
            cut(row, col) = 1;
        end
    end
end

function weighted_edges = GenerateAllWeightedEdges(img, A, T, compAssignments, GMM_fg, GMM_bg)
    % Note, pixel_edges are edges connecting a pixel to a pixel;
    % terminal_edges connect a pixel with a terminal.
    pixel_edges = GenerateUnweightedPixelEdges(img);
    beta = GenerateBeta(img, pixel_edges);
    pixel_edges = weightPixelEdges(pixel_edges, size(img), A, beta);
    terminal_edges = GenerateTerminalEdges(img, A, T, compAssignments, GMM_fg, GMM_bg);
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
    img_dim = size(img);
    m = img_dim(1);
    n = img_dim(2);
    num_interior_edges = 4*(m-2)*(n-2);
    num_boundary_edges = 5*(m-2) + 5*(n-2) + 6;
    expected_num_edges = num_interior_edges + num_boundary_edges;
    num_edges = 1;
    edge_origs = zeros(1, expected_num_edges);
    edge_dests = zeros(1, expected_num_edges);
    for row = 1:m-1
        % first, do horizontal edges
        for col = 1:n-1
            index = (row-1)*n + col;
            edge_origs(num_edges) = index;
            edge_dests(num_edges) = index+1;
            num_edges = num_edges + 1;
        end
        % next, do vertical edges
        for col = 1:n
            index = (row-1)*n + col;
            edge_origs(num_edges) = index;
            edge_dests(num_edges) = index+n;
            num_edges = num_edges + 1;
        end
        % next, diagonal edges to right
        for col = 1:n-1
            index = (row-1)*n + col;
            edge_origs(num_edges) = index;
            edge_dests(num_edges) = index+n+1;
            num_edges = num_edges + 1;
        end
        % then diagonal edges to left
        for col = 2:n
            index = (row-1)*n + col;
            edge_origs(num_edges) = index;
            edge_dests(num_edges) = index+n-1;
            num_edges = num_edges + 1;
        end
    end
    % finally, add last row of horizontal edges.
    row = m;
    for col = 1:n-1
        index = (row-1)*n + col;
        edge_origs(num_edges) = index;
        edge_dests(num_edges) = index+1;
        num_edges = num_edges + 1;
    end
    if num_edges-1 ~= expected_num_edges
        error('number of edges added doesn''t match expected number');
    end
    edges = [edge_origs; edge_dests];
end

function weighted_edges = weightPixelEdges(edges, im_size, A, beta)
% function to add weights to each edge in a set of pixel edges.
    width = im_size(2);
    [~, num_edge] = size(edges);
    weights = zeros(1, num_edge);
    for i = 1:num_edge
        row_s = floor((edges(1, i)-1) / width)+1;
        col_s = edges(1, i) - (row_s-1)*width;
        row_d = floor((edges(2, i)-1) / width)+1;
        col_d = edges(2, i) - (row_d-1)*width;
        weights(i) = GenerateEdgeWeight(row_s, col_s, row_d, col_d, A, beta);
    end
    weighted_edges = [edges; weights];
end

function edges = GenerateTerminalEdges(img, A, T, compAssignments, GMM_fg, GMM_bg)
% function to create a matrix of edges from the terminals to each pixel.
% for an MxN image, returns an MxNx2 matrix,
% where each entry is a cell, holding array [weight].
% first layer is source edges, second is sink edges.
    lambda = 1;
    img_dim = size(img);
    m = img_dim(1);
    n = img_dim(2);
    edges = zeros(3, 2*m*n);
    num_edges = 1;
    source = m*n+1;
    sink = m*n+2;
    for row = 1:m
        for col = 1:n
            index = (row-1)*n + col;
            % source terminal edge:
            if T(row, col) == 0
                weight = 0;
            elseif T(row, col) == 1
                weight = lambda * Distance(compAssignments(row, col),...
                    GMM_fg, img(row, col));
            else
                weight = inf;
            end
            edges(:, num_edges) = [source; index; weight];
            num_edges = num_edges+1;
            % sink terminal edge:
            if T(row, col) == 0
                weight = inf;
            elseif T(row, col) == 1
                weight = lambda * Distance(compAssignments(row, col),...
                    GMM_bg, img(row, col));
            else
                weight = 0;
            end
            edges(:, num_edges) = [sink; index; weight];
            num_edges = num_edges+1;
        end
    end
end

function beta = GenerateBeta(img, edges)
    [~, num_edge] = size(edges);
    [height, width, ~] = size(img);
    sum_square_diffs = 0;
    count = 0;
    for i = 1:num_edge
        row_s = floor((edges(1, i)-1) / width)+1;
        col_s = edges(1, i) - (row_s-1)*width;
        row_d = floor((edges(2, i)-1) / width)+1;
        col_d = edges(2, i) - (row_d-1)*width;
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