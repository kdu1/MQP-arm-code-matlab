 %intakes a trajectory time, starting and ending velocities, starting and ending accelerations, and
%starting and ending positions and returns a 6x1 array of
%trajectory coefficients for a quintic trajectory
function QT = quintic_traj(tf, vi, vf, ai, af, pi, pf)
    A = [1, 0, 0, 0, 0, 0;
        0, 1, 0, 0, 0, 0;
        0, 0, 2, 0, 0, 0;
        1, tf, tf^2, tf^3, tf^4, tf^5;
        0, 1, 2*tf, 3*tf^2, 4*tf^3, 5*tf^4;
        0, 0, 2, 6*tf, 12*tf^2, 20*tf^3];
    b = [pi; vi; ai; pf; vf; af];
    QT = A\b;
end