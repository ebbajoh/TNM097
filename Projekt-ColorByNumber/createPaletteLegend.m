function createPaletteLegend(image_input, color_centers, label_map)

if size(image_input,3) == 1
    image_input = repmat(image_input,[1 1 3]);
end

[h,w,~] = size(image_input);

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

for k = 1:num_colors

    mask = label_map == k;
    stats = regionprops(mask,'Centroid','Area');

    for i = 1:length(stats)

        if stats(i).Area < 50
            continue
        end

        cx = stats(i).Centroid(1);
        cy = stats(i).Centroid(2);

        text(cx,cy,num2str(k), ...
            'HorizontalAlignment','center', ...
            'VerticalAlignment','middle', ...
            'FontSize',10, ...
            'FontWeight','bold', ...
            'Color','k');
    end
end

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
end