function trimap = GetUserEdit(img, trimap, mode)
    fig = figure;
    imshow(img);
    region = imfreehand(fig.CurrentAxes);
    pos = wait(region);
    mask = region.createMask();
    close(fig)
    if strcmp(mode, 'Foreground') == 1
        brush = 2;
        trimap = max(trimap, mask.*brush);
    else
        trimap = min(trimap, 2*(~mask));
    end
end