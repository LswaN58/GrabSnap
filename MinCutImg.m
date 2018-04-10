function [energy, cut] = MinCutImg(img, A, T, compAssignments, GMM_fg, GMM_bg)
    [height, width, depth] = size(img);
    square_diffs = 
    beta = 1/(2*(
    pixel_edges = GeneratePixelEdges(img, A, T, compAssignments, GMM_fg, GMM_bg);
    terminal_edges = GenerateTerminalEdges(img, A, T, compAssignments, GMM_fg, GMM_bg);
    energy = pixel_edges;
    cut = terminal_edges;
end

function edges = GeneratePixelEdges(img, A, T, compAssignments, GMM_fg, GMM_bg, beta)
% function to generate all edges of neighboring pixels in an image of given dimensions.
% dimensions should simply be [height, width] of the image.
% Uses neighborhoods of radius 1 (8-neighborhoods).
% for an MxN image, returns an MxNx10 matrix,
% where each entry is a cell, holding array [row, col, weight].
% There are 10 entries per pixel, including 8 neighbors & 2 terminals.
    lambda = 1;
    img_dim = size(img);
    m = img_dim(1);
    n = img_dim(2);
    edges = cell(m, n, 8);
    for row = 1:m
        for col = 1:n
            if row > 1
                edges{row, col, 1} = GenerateEdge(row, col, row-1, col, A, beta);
            end
            if col > 1
                edges{row, col, 2} = GenerateEdge(row, col, row, col-1, A, beta);
            end
            if col > 1 && row > 1
                edges{row, col, 3} = GenerateEdge(row, col, row-1, col-1, A, beta);
            end
            if row < m
                edges{row, col, 4} = GenerateEdge(row, col, row+1, col, A, beta);
            end
            if col < n
                edges{row, col, 5} = GenerateEdge(row, col, row, col+1, A, beta);
            end
            if row < m && col < n
                edges{row, col, 6} = GenerateEdge(row, col, row+1, col+1, A, beta);
            end
            if col < n && row > 1
                edges{row, col, 7} = GenerateEdge(row, col, row-1, col+1, A, beta);
            end
            if col > 1 && row < m
                edges{row, col, 8} = GenerateEdge(row, col, row+1, col-1, A, beta);
            end
            % source terminal edge:
            if T(row, col) == 0
                weight = 0;
            elseif T(row, col) == 1
                weight = lambda * Distance(A(row, col), compAssignments(row, col),...
                    GMM_fg, GMM_bg, img(row, col));
            else
                weight = inf;
            end
            edges{row, col, 9} = [0, 1, weight];
            % sink terminal edge:
            if T(row, col) == 0
                weight = inf;
            elseif T(row, col) == 1
                weight = lambda * Distance(A(row, col), compAssignments(row, col),...
                    GMM_fg, GMM_bg, img(row, col));
            else
                weight = 0;
            end
            edges{row, col, 10} = [1, 0, weight];
        end
    end
end

function edges = GenerateTerminalEdges(img, A, T, compAssignments, GMM_fg, GMM_bg, beta)
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

function edge = GenerateEdge(row1, col1, row2, col2, A, beta)
    edge_pix = [row1, col1; row2, col2];
    edge_a = [A(row1, col1); A(row2, col2)];
    edge = [row2, col2, EdgeSmoothness(edge_pix, edge_a, beta)];
end