function fig = TestPlot( FName, x0, y0, x, y, xx, dy, t, y_hat, tt, dy_hat )
    fig = figure('Name', FName);
    subplot(1, 2, 1)
    plot(x0, y0, '-r')
    hold on
    plot(x, y, 'xr')
    hold on
    plot(t, y_hat, '-b')
    title('f')

    subplot(1, 2, 2)
    plot(xx, dy, '-r')
    hold on
    plot(tt, dy_hat, 'xb')
    title('df')
    legend({'original', 'splines'})
end

