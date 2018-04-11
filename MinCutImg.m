function [energy, cut] = MinCutImg(img, A, T, compAssignments, GMM_fg, GMM_bg)
    [height, width, depth] = size(img);
    pixel_edges = GenerateUnweightedPixelEdges(img);
    beta = GenerateBeta(img, pixel_edges)
    % Note, pixel_edges are edges leaving a pixel;
    % terminal_edges are leaving a terminal.
    pixel_edges = weightPixelEdges(pixel_edges, A, T, compAssignments, GMM_fg, GMM_bg, beta);
    terminal_edges = GenerateTerminalEdges(img, A, T, compAssignments, GMM_fg, GMM_bg);
    energy = pixel_edges;
    cut = terminal_edges;
end

function edges = GenerateUnweightedPixelEdges(img)
% function to generate all edges of neighboring pixels in an image of given dimensions.
% dimensions should simply be [height, width] of the image.
% Uses neighborhoods of radius 1 (8-neighborhoods).
% for an MxN image, returns an MxNx10 matrix,
% where each entry is a cell, holding array [row, col].
% There are 10 entries per pixel, including 8 neighbors & 2 terminals.
% From 1 to 10, order of neighbors is: upper, left, upper-left, lower,
%    right, lower-right, upper-right, lower-left, source, sink.
% If a pixel does not have a corresponding neighbor for one of the entries,
% the array has row = col = -1.
% Edge weights must be added later.
    lambda = 1;
    img_dim = size(img);
    m = img_dim(1);
    n = img_dim(2);
    edges = cell(m, n, 10);
    for row = 1:m
        for col = 1:n
            if row > 1
                edges{row, col, 1} = [row-1, col];
            else
                edges{row, col, 1} = [-1, -1];
            end
            if col > 1
                edges{row, col, 2} = [row, col-1];
            else
                edges{row, col, 2} = [-1, -1];
            end
            if col > 1 && row > 1
                edges{row, col, 3} = [row-1, col-1];
            else
                edges{row, col, 3} = [-1, -1];
            end
            if row < m
                edges{row, col, 4} = [row+1, col];
            else
                edges{row, col, 4} = [-1, -1];
            end
            if col < n
                edges{row, col, 5} = [row, col+1];
            else
                edges{row, col, 5} = [-1, -1];
            end
            if row < m && col < n
                edges{row, col, 6} = [row+1, col+1];
            else
                edges{row, col, 6} = [-1, -1];
            end
            if col < n && row > 1
                edges{row, col, 7} = [row-1, col+1];
            else
                edges{row, col, 7} = [-1, -1];
            end
            if col > 1 && row < m
                edges{row, col, 8} = [row+1, col-1];
            else
                edges{row, col, 8} = [-1, -1];
            end
            edges{row, col, 9} = [0, 1];
            edges{row, col, 10} = [1, 0];
        end
    end
end

function weighted_edges = weightPixelEdges(edges, A, T, compAssignments, GMM_fg, GMM_bg, beta)
% function to add weights to each edge in a set of pixel edges.
    lambda = 1;
    edges_dim = size(edges);
    m = edges_dim(1);
    n = edges_dim(2);
    weighted_edges = cell(m, n, 10);
    for row = 1:m
        for col = 1:n
            % generate neighbor weights
            for neighbor = 1:8
                % check that neighbor exists.
                n_cell = edges{row, col, neighbor};
                if n_cell(1, 1:2) == [-1, -1]
                    continue;
                else
                    n_cell(3) = GenerateEdgeWeight(row, col, n_cell(1), n_cell(2), A, beta);
                end
            end
            % generate terminal weights.
            % source terminal edge:
            if T(row, col) == 0
                weight = 0;
            elseif T(row, col) == 1
                weight = lambda * Distance(A(row, col), compAssignments(row, col),...
                    GMM_fg, GMM_bg, img(row, col));
            else
                weight = inf;
            end
            edges{row, col, 9}(3) = weight;
            % sink terminal edge:
            if T(row, col) == 0
                weight = inf;
            elseif T(row, col) == 1
                weight = lambda * Distance(A(row, col), compAssignments(row, col),...
                    GMM_fg, GMM_bg, img(row, col));
            else
                weight = 0;
            end
            edges{row, col, 10}(3) = weight;
        end
    end
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
    for row = 1:m
        for col = 1:n
            % source terminal edge:
            if T(row, col) == 0
                weight = 0;
            elseif T(row, col) == 1
                weight = lambda * Distance(A(row, col), compAssignments(row, col),...
                    GMM_fg, GMM_bg, img(row, col));
            else
                weight = inf;
            end
            edges{row, col, 1} = [weight];
            % sink terminal edge:
            if T(row, col) == 0
                weight = inf;
            elseif T(row, col) == 1
                weight = lambda * Distance(A(row, col), compAssignments(row, col),...
                    GMM_fg, GMM_bg, img(row, col));
            else
                weight = 0;
            end
            edges{row, col, 2} = [weight];
        end
    end
end

function beta = GenerateBeta(img, edges)
    img_dim = size(img);
    sum_square_diffs = 0;
    count = 0;
    for row = 1:img_dim(1)
        for col = 1:img_dim(2)
            for neighbor = 1:8
                % check that neighbor exists.
                n_cell = edges{row, col, neighbor};
                if n_cell(1, 1:2) == [-1, -1]
                    continue;
                else
                    p1 = img(row, col, :);
                    x = n_cell(1);
                    y = n_cell(2);
                    p2 = img(x, y, :);
                    sum_square_diffs = sum_square_diffs + sum((p1-p2).^2);
                    count = count + 1;
                end
            end
        end
    end
    avg = sum_square_diffs / count;
    beta = 1./(2.*avg);
end

function edge_weight = GenerateEdgeWeight(row1, col1, row2, col2, A, beta)
    edge_pix = [row1, col1; row2, col2];
    edge_a = [A(row1, col1); A(row2, col2)];
    edge_weight = EdgeSmoothness(edge_pix, edge_a, beta);
end