% calculates 6x3 manipulator Jacobian from 3x1 array of joint
% angles
function J = jacob3001(ja)
    t1 = ja(1);
    t2 = ja(2);
    t3 = ja(3);
    % hardcoded Jacobian calculation
    J = [(5*pi*sin((pi*t1)/180)*sin((pi*(t2 - 90))/180)*sin((pi*(t3 + 90))/180))/9 - (5*pi*sin((pi*t1)/180)*cos((pi*(t2 - 90))/180)*cos((pi*(t3 + 90))/180))/9 - (5*pi*sin((pi*t1)/180)*cos((pi*(t2 - 90))/180))/9, - (5*pi*cos((pi*t1)/180)*sin((pi*(t2 - 90))/180))/9 - (5*pi*cos((pi*t1)/180)*cos((pi*(t2 - 90))/180)*sin((pi*(t3 + 90))/180))/9 - (5*pi*cos((pi*t1)/180)*cos((pi*(t3 + 90))/180)*sin((pi*(t2 - 90))/180))/9, - (5*pi*cos((pi*t1)/180)*cos((pi*(t2 - 90))/180)*sin((pi*(t3 + 90))/180))/9 - (5*pi*cos((pi*t1)/180)*cos((pi*(t3 + 90))/180)*sin((pi*(t2 - 90))/180))/9;
        (5*pi*cos((pi*t1)/180)*cos((pi*(t2 - 90))/180))/9 + (5*pi*cos((pi*t1)/180)*cos((pi*(t2 - 90))/180)*cos((pi*(t3 + 90))/180))/9 - (5*pi*cos((pi*t1)/180)*sin((pi*(t2 - 90))/180)*sin((pi*(t3 + 90))/180))/9, - (5*pi*sin((pi*t1)/180)*sin((pi*(t2 - 90))/180))/9 - (5*pi*sin((pi*t1)/180)*cos((pi*(t2 - 90))/180)*sin((pi*(t3 + 90))/180))/9 - (5*pi*sin((pi*t1)/180)*cos((pi*(t3 + 90))/180)*sin((pi*(t2 - 90))/180))/9, - (5*pi*sin((pi*t1)/180)*cos((pi*(t2 - 90))/180)*sin((pi*(t3 + 90))/180))/9 - (5*pi*sin((pi*t1)/180)*cos((pi*(t3 + 90))/180)*sin((pi*(t2 - 90))/180))/9;
        0, (5*pi*sin((pi*(t2 - 90))/180)*sin((pi*(t3 + 90))/180))/9 - (5*pi*cos((pi*(t2 - 90))/180)*cos((pi*(t3 + 90))/180))/9 - (5*pi*cos((pi*(t2 - 90))/180))/9, (5*pi*sin((pi*(t2 - 90))/180)*sin((pi*(t3 + 90))/180))/9 - (5*pi*cos((pi*(t2 - 90))/180)*cos((pi*(t3 + 90))/180))/9;
        0, -sin((pi*t1)/180), -sin((pi*t1)/180);
        0, cos((pi*t1)/180), cos((pi*t1)/180);
        1, 0, 0];
end