function compAssignments = GetPixelComponents(GMM_data, Trimap, Amap,  GMM_fg, GMM_bg)
    num_comp = GMM_fg.NumComponents;
    [height, width, data_dim] = size(GMM_data);
    % Reshape data so each row is a dim (RGB, XY), and each col is a pixel.
    reshaped_data = reshape(GMM_data, height*width, data_dim)';
    % --- first, find components of things in "free" region. ---
    free_fg_dists = zeros(height, width, num_comp);
    free_bg_dists = zeros(height, width, num_comp);
    % Get linear list of 1's & 0's
    free_fg_mask = double((Trimap & Amap) == 1);
    free_bg_mask = double((Trimap & ~Amap) == 1);
    % for each pixel, calc distance to each component.
    for i = 1:num_comp
        free_fg_dists(:, :, i) = free_fg_mask.*reshape(Distance(i, GMM_fg, reshaped_data), height, width);
        free_bg_dists(:, :, i) = free_bg_mask.*reshape(Distance(i, GMM_bg, reshaped_data), height, width);
    end
    % take component index for least distant to each pixel.
    [~, free_fg_maxes] = min(free_fg_dists, [], 3);
    [~, free_bg_maxes] = min(free_bg_dists, [], 3);
    % finally, assign components.
    %compAssignments = free_fg_mask.*free_fg_maxes + free_bg_mask.*free_bg_maxes;
    
    % --- Next, assign for things that are set in the background.
    bg_dists = zeros(height, width, num_comp);
    % Get linear list of 1's & 0's
    bg_mask = double(Trimap == 0);
    % for each pixel, calc distance to each component.
    for i = 1:num_comp
        bg_dists(:, :, i) = bg_mask.*reshape(Distance(i, GMM_bg, reshaped_data), height, width);
    end
    % take component index for least distant to each pixel.
    [~, bg_maxes] = min(bg_dists, [], 3);
    % finally, assign components.
    compAssignments = free_fg_mask.*free_fg_maxes + ...
        free_bg_mask.*free_bg_maxes + bg_mask.*bg_maxes;
    
    
%     dists_mat = zeros(height, width, 3);
%     [free_Y, free_X] = find((Trimap) == 1);
%     [num_free, ~] = size(free_Y);
%     disp('In pix comps, started assignment loop')
%     tic
%     for i = 1:num_free
%         best_comp = -1;
%         min_dist = inf;
%         X = free_X(i);
%         Y = free_Y(i);
%         if(Amap(Y,X) == 0)
%             theta = GMM_bg;
%         else
%             theta = GMM_fg;
%         end
%         for comp = 1:theta.NumComponents
%             [D] = Distance(comp, theta, squeeze(GMM_data(Y,X, :)));
%             dists_mat(Y, X, comp) = D;
%             if(D <= min_dist)
%                 best_comp = comp;
%                 min_dist = D;
%             end
%         end
%         compAssignments(Y, X) = best_comp;
%     end
%     toc
    %not sure if the following code is needed, this labels all the points
    %that are not trimap 1 incase it is still important later, remove all
    %following to follow the paper more closely
%     [compYb, compXb] = find(Trimap ~= 1);
%     [lengthb, ~] = size(compYb);
%     disp('In pix comps, started loop that isn''t known if it''s needed or not.')
%     tic
%     for i = 1:lengthb
%         best_comp = -1;
%         min_dist = inf;
%         X = compXb(i);
%         Y = compYb(i);
%         if(Amap(Y,X) == 0)
%             theta = GMM_bg;
%         else
%             theta = GMM_fg;
%         end
%         for comp = 1:theta.NumComponents
%             [D] = Distance(comp, theta, squeeze(GMM_data(Y,X, :)));
%             if(D < min_dist)
%                 best_comp = comp;
%                 min_dist = D;
%             end
%         end
%         compAssignments(Y, X) = best_comp;
%     end
%     toc
end

