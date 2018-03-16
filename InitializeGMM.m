function [GMM_fg, GMM_bg] = InitializeGMM(GMM_data)
    warning('STUB! InitializeGMM just creates a hardcoded GMM.')
    GMM_fg = fitgmdist([1, 2, 3; 10, 20, 30; 101, 102, 103], [2]);
    GMM_bg = fitgmdist([1, 2, 3; 10, 20, 30; 101, 102, 103]+5, [2]);
end

