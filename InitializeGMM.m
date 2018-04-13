function [GMM_fg, GMM_bg] = InitializeGMM(GMM_data, trimap)
    [y_bg, x_bg] = find(trimap == 0);
    [y_fg, x_fg] = find(trimap == 1);
    %length = size(GMMy)
    [length_bg, ~] = size(y_bg);
    [length_fg, ~] = size(y_fg);
    bgArea = zeros(length_bg,5);
    fgArea = zeros(length_fg,5);
    %questionArea = GMM_data(GMMx(1), GMMy(1), :);
    for i = 1:length_bg
        bgArea(i, :) = GMM_data(y_bg(i), x_bg(i), :);
    end
    for i = 1:length_fg
        fgArea(i, :) = GMM_data(y_fg(i), x_fg(i), :);
    end
    GMM_bg= fitgmdist(bgArea, 5);
    GMM_fg= fitgmdist(fgArea, 5);
end

