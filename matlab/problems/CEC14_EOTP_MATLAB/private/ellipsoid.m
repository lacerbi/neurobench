function f = ellipsoid(x)
    f = sum(x .* x .* [1:numel(x)]');
end

