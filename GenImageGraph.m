function [im_graph, beta] = GenImageGraph(img)
    % Note, this returns beta. Kinda a hack, but it's easiest to get beta
    % figured out when generating edges.
    [height, width, depth] = size(img);
%     disp('Starting edge generation');
%     tic
    [edges, beta] = GenerateAllUnweightedEdges(img);
%     toc
    im_graph = graph(edges(1, :), edges(2, :));
end

function [unweighted_edges, beta] = GenerateAllUnweightedEdges(img)
    % Note, pixel_edges are edges connecting a pixel to a pixel;
    % terminal_edges connect a pixel with a terminal.
    % Note, this returns beta. Kinda a hack, but this is most convenient
    % place to get beta figured out.
    pixel_edges = GenerateUnweightedPixelEdges(img);
    disp('Generating beta');
    tic
    beta = GenerateBeta(img, pixel_edges);
    toc
    terminal_edges = GenerateUnweightedTerminalEdges(img);
    unweighted_edges = [pixel_edges, terminal_edges];
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

function edges = GenerateUnweightedTerminalEdges(img)
% function to create a matrix of edges from the terminals to each pixel.
% first row is edge origin, second row is edge dest.
    % Get dimension info, initialize data.
    [m, n, ~] = size(img);
    source = m*n+1;
    sink = m*n+2;
    % create edges from source to fg and free pixels, concatenated
    % together.
    src_edges(:, :) = [1:(m*n); source*ones(1, m*n)];
    dest_edges(:, :) = [1:(m*n); sink*ones(1, m*n)];
    edges = [src_edges, dest_edges];
end