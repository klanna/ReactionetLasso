function FormatTime( t, varargin )
% Prints time in h m s format
% Optional: Msg
    Ftime.h = floor(t / 3600);
    t = t - Ftime.h * 3600;
    Ftime.m = floor(t / 60);
    Ftime.s = t - Ftime.m * 60;
    if ~isempty(varargin)
        fprintf('%s ', varargin{1});
    end
    if Ftime.h
        fprintf('%.0f h %.0f min %.0f sec...\n', Ftime.h, Ftime.m, Ftime.s);
    elseif Ftime.m
        fprintf('%.0f min %.0f sec...\n', Ftime.m, Ftime.s);
    else
        fprintf('%.0f sec...\n', Ftime.s);
    end
end

