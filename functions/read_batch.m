function dates = read_batch(filename)

    dates = strings(0);
    
    fid = fopen(filename, "rt");
    
    if fid == -1
        error('Failed to open file: %s', filename);
    end
    
    while ~feof(fid)
        line = fgetl(fid);
        if ischar(line)
    
            dates(end+1) = line;
    
        end
    end
end