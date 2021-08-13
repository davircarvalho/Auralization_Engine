function circles(app, r)
    % plot retas 
    r2 = r(end);
    cor = [.2 .2 .2];
    line(app.UIAxes, [0,0], [-r2,r2], 'linewidth', .5, 'color', cor) % vertical 
    line(app.UIAxes,[-r2,r2], [0,0], 'linewidth', .5, 'color', cor) % horizontal
    [x,y,~] = sph2cart(deg2rad(45), 0, r2);
    line(app.UIAxes,[-x,x], [-y,y], 'linewidth', .5, 'color', cor) % diagonal 1
    line(app.UIAxes,[-x,x], [y,-y], 'linewidth', .5, 'color', cor) % diagonal 2

    % plot circulos
    x = 0;
    y = 0;        
    th = 0:pi/50:2*pi; 
    for k = 1:length(r)
        xunit = r(k) * cos(th) + x;
        yunit = r(k)* sin(th) + y;
        color = [.6 .6 .6];
        if k == 1
            color = [1 0 0];
        end
        plot(app.UIAxes, xunit, yunit,...
            'linewidth', 1.5, 'color', color);                
    end

    % distancias 
    for k =1:length(r)
        txt = [num2str(round(r(k),1)) 'm'];
        txt(txt == '0') = [];
        [x,y,~] = sph2cart(deg2rad(135), 0, r(k)+.15);
        text(app.UIAxes, x,y,txt ,...
           'VerticalAlignment','bottom','HorizontalAlignment','left',...
           'FontSize',9, 'Color', [.5 .5 .5])
    end

    % angulos
    angls = [0, 90, 180, 270];
    for k = 1:length(angls)
        if angls(k) == 90
            txt = '270°';
            aligntxt = 'right';
            offset = .4;
        elseif angls(k) == 270
            txt = '90°';    
            aligntxt = 'left';
            offset = .25;
        elseif angls(k) == 0
            txt = [num2str(angls(k)) '°'];
            aligntxt = 'center';
            offset = .1;
        else
            txt = [num2str(angls(k)) '°'];
            aligntxt = 'center';
            offset = .25;
        end
        [x,y,~] = sph2cart(deg2rad(angls(k)), 0, r2+offset);
        text(app.UIAxes,x,y,txt,...
           'VerticalAlignment','bottom',...
           'HorizontalAlignment',aligntxt,...
           'FontSize',9, 'Color', [.5 .5 .5])
    end
 end