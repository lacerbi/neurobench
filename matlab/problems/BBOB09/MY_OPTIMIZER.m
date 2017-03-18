function MY_OPTIMIZER(FUN, DIM, ftarget, maxfunevals)
% MY_OPTIMIZER(FUN, DIM, ftarget, maxfunevals)
% samples new points uniformly randomly in [-5,5]^DIM
% and evaluates them on FUN until ftarget of maxfunevals
% is reached, or until 1e8 * DIM fevals are conducted. 
% Relies on FUN to keep track of the best point. 

  maxfunevals = min(1e8 * DIM, maxfunevals); 
  popsize = min(maxfunevals, 200); 
  for iter = 1:ceil(maxfunevals/popsize)
    feval(FUN, 10 * rand(DIM, popsize) - 5);
    if feval(FUN, 'fbest') < ftarget  % task achieved 
      break;  
    end
    % if useful, modify more options here for next start
  end 

  
