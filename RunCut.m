function alpha = RunCut(img, trimap)
% Function to run the iterative GrabCut algorithm.

% First, set alpha to 1 for trimap pixels that = 1 or 2.
alpha = min(1, trimap);
GMMData = ConvertImDataToGMMData(img);
[GMM_fg, GMM_bg] = InitializeGMM(GMMData, trimap);
converged = false;
prev_energy = 0;
iter = 1;
while converged == false
    disp(['Started iteration ', num2str(iter), '. Previous energy was ', num2str(prev_energy)]);
    disp('Starting GetPixelComponents');
    tic
    compAssignments = GetPixelComponents(GMMData, trimap, alpha, GMM_fg, GMM_bg); % step 1 of algo.
    toc
    [GMM_fg, GMM_bg] = LearnGMMParams(GMMData, alpha, compAssignments); % step 2 of algo
    [energy, alpha] = MinCutImg(img, alpha, trimap, GMM_fg, GMM_bg); % step 3 of algo
    epsilon = 0.01 * energy;
    converged = (abs(energy-prev_energy) < epsilon); % step 4 of algo, sorta.
    prev_energy = energy;
    imshow(alpha);
    iter = iter+1;
end
end

