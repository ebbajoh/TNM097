function interactivePaint(outline, palette_rgb, label_map)

if size(outline,3) == 1
    outline = repmat(outline,[1 1 3]);
end

[h,w,~] = size(outline);

extra_height = 120;
canvas = ones(h + extra_height, w, 3);
canvas(1:h,:,:) = outline;

num_colors = size(palette_rgb,1);

circle_radius = 25;
spacing = w/(num_colors+1);
y_center = h + extra_height/2;

paint_img = canvas;
current_color = 1;

figure
imshow(paint_img)
hold on

drawPalette()
drawNumbers()

title('Click palette to choose color, click image to paint')

while true

    [x,y,button] = ginput(1);

    if isempty(button)
        break
    end

    if y > h

        for i = 1:num_colors
            x_center = i*spacing;

            if (x-x_center)^2 + (y-y_center)^2 < circle_radius^2
                current_color = i;
                title(['Selected color: ' num2str(i)])
                break
            end
        end

    else

        x = round(x);
        y = round(y);

        region = label_map(y,x);

        mask = label_map == region;

        for c = 1:3
            channel = paint_img(1:h,:,c);
            channel(mask) = palette_rgb(current_color,c);
            paint_img(1:h,:,c) = channel;
        end

        imshow(paint_img)
        hold on

        drawPalette()
        drawNumbers()

    end

end


function drawNumbers()

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

end


function drawPalette()

for i = 1:num_colors

    x_center = i*spacing;

    rectangle('Position',[x_center-circle_radius ...
                          y_center-circle_radius ...
                          2*circle_radius ...
                          2*circle_radius], ...
              'Curvature',[1 1], ...
              'FaceColor',palette_rgb(i,:), ...
              'EdgeColor','k');

    text(x_center,y_center,num2str(i), ...
        'HorizontalAlignment','center', ...
        'VerticalAlignment','middle', ...
        'FontWeight','bold');
end

end

end