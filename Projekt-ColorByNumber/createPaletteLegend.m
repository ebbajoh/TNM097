function createPaletteLegend(image_input, color_centers, label_map)

% Om bilden är i gråskala (1 kanal), gör om den till RGB (3 kanaler)
if size(image_input,3) == 1
    image_input = repmat(image_input,[1 1 3]);
end

% Hämta bildens höjd och bredd
[h,w,~] = size(image_input);

% Konvertera färgcentra från Lab till RGB
palette_rgb = lab2rgb(color_centers);

% Säkerställ att RGB-värden ligger mellan 0 och 1
palette_rgb = max(min(palette_rgb,1),0);

% Lägg till extra utrymme under bilden där färgpaletten ska ritas
extra_height = 120;
canvas = ones(h + extra_height, w, 3);

% Placera outline-bilden överst i canvas
canvas(1:h,:,:) = image_input;

% Antal färger (kluster)
num_colors = size(palette_rgb,1);

% Parametrar för palettcirklar
circle_radius = 25;
spacing = w/(num_colors+1);     % avstånd mellan cirklar
y_center = h + extra_height/2;  % vertikal position för paletten

% Visa canvasen i en figur
figure
imshow(canvas)
hold on

% Rita siffror i varje region (paint-by-numbers områden)
for k = 1:num_colors

    % Skapa en mask för region k
    mask = label_map == k;

    % Hitta sammanhängande områden i masken
    CC = bwconncomp(mask);

    for i = 1:CC.NumObjects

        % Hämta alla pixlar som tillhör regionen
        pixels = CC.PixelIdxList{i};

        % Konvertera linjära index till x- och y-koordinater
        [y,x] = ind2sub(size(mask),pixels);

        % Beräkna regionens centroid (medelposition)
        cx = mean(x);
        cy = mean(y);

        % Rita regionens nummer i mitten av området
        text(cx,cy,num2str(k), ...
            'HorizontalAlignment','center', ...
            'VerticalAlignment','middle', ...
            'FontSize',10, ...
            'FontWeight','bold', ...
            'Color','k');
    end
end

% Rita färgpaletten under bilden
for i = 1:num_colors

    % Beräkna cirkelns x-position
    x_center = i*spacing;

    % Rita en cirkel som representerar färgen
    rectangle('Position',[x_center-circle_radius ...
                          y_center-circle_radius ...
                          2*circle_radius ...
                          2*circle_radius], ...
              'Curvature',[1 1], ...
              'FaceColor',palette_rgb(i,:), ...
              'EdgeColor','k', ...
              'LineWidth',1.5);

    % Skriv färgens nummer i cirkeln
    text(x_center,y_center,num2str(i), ...
        'HorizontalAlignment','center', ...
        'VerticalAlignment','middle', ...
        'FontWeight','bold', ...
        'FontSize',14);
end

% Titel på figuren
title('Paint-by-Numbers Template')

% Sluta rita i figuren
hold off