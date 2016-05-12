function [ v ] = VertVect( t )
    if max(size(t)) > 1
        v = permute(t, [find(size(t) == max(size(t))), find(size(t) == min(size(t)))]);
    else
        v = t;
    end
end

