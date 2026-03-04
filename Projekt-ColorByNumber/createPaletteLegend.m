function createPaletteLegend(image_input, color_centers, label_map)

% Convert grayscale to RGB if necessary
if size(image_input,3) == 1
    image_input = repmat(image_input,[1 1 3]);
end

[h,w,~] = size(image_input);

% Convert palette colors
palette_rgb = lab2rgb(color_centers);
palette_rgb = max(min(palette_rgb,1),0);

extra_height = 120;
canvas = ones(h + extra_height, w, 3);
canvas(1:h,:,:) = image_input;

num_colors = size(palette_rgb,1);

circle_radius = 25;
spacing = w/(num_colors+1);
y_center = h + extra_height/2;

figure
imshow(canvas)
hold on

%% --- Draw numbers inside regions ---
for k = 1:num_colors

    mask = label_map == k;

    % find connected regions
    CC = bwconncomp(mask);

    for i = 1:CC.NumObjects

        pixels = CC.PixelIdxList{i};

        % convert linear indices to coordinates
        [y,x] = ind2sub(size(mask),pixels);

        % centroid
        cx = mean(x);
        cy = mean(y);

        text(cx,cy,num2str(k), ...
            'HorizontalAlignment','center', ...
            'VerticalAlignment','middle', ...
            'FontSize',10, ...
            'FontWeight','bold', ...
            'Color','k');
    end
end

%% --- Draw palette circles ---
for i = 1:num_colors

    x_center = i*spacing;

    rectangle('Position',[x_center-circle_radius ...
                          y_center-circle_radius ...
                          2*circle_radius ...
                          2*circle_radius], ...
              'Curvature',[1 1], ...
              'FaceColor',palette_rgb(i,:), ...
              'EdgeColor','k', ...
              'LineWidth',1.5);

    text(x_center,y_center,num2str(i), ...
        'HorizontalAlignment','center', ...
        'VerticalAlignment','middle', ...
        'FontWeight','bold', ...
        'FontSize',14);
end

title('Paint-by-Numbers Template')
hold off