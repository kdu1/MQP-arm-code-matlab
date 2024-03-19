
function CT = cubic_traj(tf, vi, vf, pi, pf)
    A = [1, 0, 0, 0;
        0, 1, 0, 0;
        1, tf, tf^2, tf^3;
        0, 1, 2*tf, 3*(tf^2)];
    b = [pi; vi; pf; vf]; %Correction this is 4 by 3
    CT = A\b; %4x3 ?????
    %ok????ok and??? ok???? ok??
end