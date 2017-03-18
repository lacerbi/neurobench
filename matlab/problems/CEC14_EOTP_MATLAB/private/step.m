function f = step(x)
    x = floor(x+0.5);
    f = sum(x .* x);
end

