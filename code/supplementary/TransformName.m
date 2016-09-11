function [ Name, p ] = TransformName( ModelName )
    Name = ModelName(1:regexp(ModelName, '[0-9]')-1);
    p = str2num(ModelName(regexp(ModelName, '[0-9]*bn'): regexp(ModelName, 'bn')-1))/100;
end

