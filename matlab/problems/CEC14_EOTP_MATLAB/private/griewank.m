function f = griewank( x )
    f = sum(x.^2) ./ 4000 - prod(cos(x ./ sqrt([1:numel(x)]'))) + 1;
end

