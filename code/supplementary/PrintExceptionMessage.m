function PrintExceptionMessage( Mexc )
    fprintf('%s\n', Mexc.message)
    for i = 1:length(Mexc.stack)
        fprintf('%u\t%s\n', Mexc.stack(i).line, Mexc.stack(i).name);
    end
end

