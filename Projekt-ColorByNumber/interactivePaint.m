function interactivePaint(outline, palette_rgb, label_map)

% Om outline-bilden är gråskala (1 kanal), gör om den till RGB (3 kanaler)
if size(outline,3) == 1
    outline = repmat(outline,[1 1 3]);
end

% Hämta bildens höjd och bredd
[h,w,~] = size(outline);

% Lägg till extra utrymme under bilden för färgpaletten
extra_height = 120;
canvas = ones(h + extra_height, w, 3);

% Placera outline-bilden överst i canvas
canvas(1:h,:,:) = outline;

% Antal färger i paletten
num_colors = size(palette_rgb,1);

% Parametrar för palettcirklar
circle_radius = 25;
spacing = w/(num_colors+1);
y_center = h + extra_height/2;

% Bilden som faktiskt kommer att målas på
paint_img = canvas;

% Startfärg (första färgen i paletten)
current_color = 1;

% Skapa figur och visa bilden
fig = figure;
imshow(paint_img)

% Aktivera zoom och panorering
zoom(fig,'on')
pan(fig,'on')
hold on

% Rita färgpaletten och siffrorna i regionerna
drawPalette()
drawNumbers()

title('Click palette to choose color, click image to paint')

% Huvudloop för interaktiv målning
while true

    % Vänta på ett musklick
    [x,y,button] = ginput(1);

    % Om inget klick registreras avslutas loopen
    if isempty(button)
        break
    end

    % Om klicket sker under bilden (i palettområdet)
    if y > h

        % Kontrollera vilken palettcirkel som klickades
        for i = 1:num_colors
            x_center = i*spacing;

            % Kontrollera om klicket ligger inom cirkelns radie
            if (x-x_center)^2 + (y-y_center)^2 < circle_radius^2
                current_color = i;
                title(['Selected color: ' num2str(i)])
                break
            end
        end

    else

        % Om klicket sker på bilden
        x = round(x);
        y = round(y);

        % Hitta vilken region (kluster) pixeln tillhör
        region = label_map(y,x);

        % Skapa en mask för hela regionen
        mask = label_map == region;

        % Färglägg hela regionen med vald färg
        for c = 1:3
            channel = paint_img(1:h,:,c);
            channel(mask) = palette_rgb(current_color,c);
            paint_img(1:h,:,c) = channel;
        end

        % Uppdatera bilden
        imshow(paint_img)
        hold on

        % Rita paletten och siffrorna igen
        drawPalette()
        drawNumbers()

    end

end


% Funktion som ritar siffror i varje region
function drawNumbers()

for k = 1:num_colors

    % Skapa mask för region k
    mask = label_map == k;

    % Beräkna regioners centroid och area
    stats = regionprops(mask,'Centroid','Area');

    for i = 1:length(stats)

        % Hoppa över mycket små regioner
        if stats(i).Area < 50
            continue
        end

        % Hämta centroid-koordinater
        cx = stats(i).Centroid(1);
        cy = stats(i).Centroid(2);

        % Rita siffran i mitten av regionen
        text(cx,cy,num2str(k), ...
            'HorizontalAlignment','center', ...
            'VerticalAlignment','middle', ...
            'FontSize',10, ...
            'FontWeight','bold', ...
            'Color','k');
    end
end

end


% Funktion som ritar färgpaletten under bilden
function drawPalette()

for i = 1:num_colors

    % Beräkna cirkelns position
    x_center = i*spacing;

    % Rita en cirkel för färgen
    rectangle('Position',[x_center-circle_radius ...
                          y_center-circle_radius ...
                          2*circle_radius ...
                          2*circle_radius], ...
              'Curvature',[1 1], ...
              'FaceColor',palette_rgb(i,:), ...
              'EdgeColor','k');

    % Lägg till färgens nummer i cirkeln
    text(x_center,y_center,num2str(i), ...
        'HorizontalAlignment','center', ...
        'VerticalAlignment','middle', ...
        'FontWeight','bold');
end

end

end