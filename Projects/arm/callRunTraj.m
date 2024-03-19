function out = callRunTraj(tc, t, s)
obj = run_trajectory(tc, t, s);
obj.shutdown();
out = 0;
end