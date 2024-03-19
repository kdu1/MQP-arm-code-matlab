function J = ik3001(endPos) %end pos is array of x, y, z position of end effector
        %try
            x = endPos(1);
            y = endPos(2);
            z = endPos(3);
            %link lengths
            l1 = 40; %changed
            l2 = 100;
            l3 = 100;

            %theta1
            theta1 = atan2d(y,x);
    
            %theta3
            s = z - l1;
            r = sqrt((x^2)+(y^2));
            cbeta3 = -((l2^2)+(l3^2) - ((r^2) + (s^2)))/(2*l2*l3);
            sbeta3 = sqrt(1-cbeta3^2);
            theta3 = atan2d(sbeta3, cbeta3) - 90;
        
            %theta2
            gamma = atan2d(s,r);
            sigma= atan2d(l3*sbeta3, l2+l3*cbeta3);
            theta2 = 90 - gamma - sigma;

            J = [theta1;theta2;theta3]; %returns jacobian
        %catches exception for invalid joint positions
        %catch exception
        %    getReport(exception);
        %    error("out of workspace")
        %end
    end
