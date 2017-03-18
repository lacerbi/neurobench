function f = cliff(x)
    f = sum(x.*x);
    f = f + 1e4*sum(x < 0);
end