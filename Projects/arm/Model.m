classdef Model < handle
    
    properties
        robot; % stores robot object to allow for function usage
        Frames; % stores frame information for updating
        Links; % stores link information for updating
        Velo; % stores velocity information for updating
        qm = 40; % multiplier for quivers so that arrows are visible

    end

    methods

        % constructor to build initial model of the robot (in Zero
        % configuration)
        function self = Model(robot)
             self.robot = robot;
             % tranformation matrix for base frame (literally just 4x4
             % identity matrix)
             T00 = [1 0 0 0;
                    0 1 0 0;
                    0 0 1 0;
                    0 0 0 1];
             % transformation matrix for joint 1
             T01 = [1 0 0 0;
                    0 0 1 0;
                    0 -1 0 95;
                    0 0 0 1];
             % transformation matrix for joint 2
             T02 = [0 1 0 0;
                    0 0 1 0;
                    1 0 0 195;
                    0 0 0 1];
             % transformation matrix for joint 3
             T03 = [1 0 0 100;
                    0 0 1 0;
                    0 -1 0 195;
                    0 0 0 1];

             
             
             grid on;
             hold on;
             % plots the three moving links and saves them to self.Links
             self.Links = plot3([T01(1,4) T02(1,4) T03(1,4)], [T01(2,4) T02(2,4) T03(2,4)], [T01(3,4) T02(3,4) T03(3,4)], 'k-o', 'LineWidth', 2, 'MarkerSize', 6, 'MarkerFaceColor',[0.5, 0.5, 0.5]);
             % plots first link, as it is a stationary line
             plot3([0 0 0], [0 0 0], [0 0 95], 'k-o', 'LineWidth', 2, 'MarkerSize', 6, 'MarkerFaceColor',[0.5, 0.5, 0.5]);
             % plots frame for base joint
             self.plot_joint(T00, 1);
             % plots frame for joint 1
             self.plot_joint(T01, 1);
             % plots frame for joint 2
             self.plot_joint(T02, 2);
             % plots frame for joint 3
             self.plot_joint(T03, 3);
             % plots velocity for joint 3
             self.plot_velo([0;0;0], [100;0;195]);
             % sets up axis labels
             xlabel('X Axis (mm)');
             ylabel('Y Axis (mm)');
             zlabel('Z Axis (mm)');
             % sets axis bounds
             axis([-200 300 -300 300 0 300]);
             % sets aspect ratio
             daspect([1 1 1]);
             % sets base view orientation
             view([-250, -400, 150]);
             hold off;
             view(3);
        end
    
        % updates overall plot of arm based on input array containing
        % current joint positions
        function plot_arm(self, jp, jv)
            % stores value of three joints from the input array
            j1 = jp(1,1);
            j2 = jp(1,2);
            j3 = jp(1,3);

            % transformation matrix for joint1 (j1), generated with syms and
            % dh2mat
            joint1 = [cos((pi*j1)/180),  0, -sin((pi*j1)/180),  0;
                      sin((pi*j1)/180),  0,  cos((pi*j1)/180),  0;
                      0, -1,                 0, 95;
                      0,  0,                 0,  1;];
            % transformation matrix for joint2 (j2), generated with syms and
            % dh2mat
            truejoint2 = [cos((pi*j1)/180)*cos((pi*(j2 - 90))/180), -cos((pi*j1)/180)*sin((pi*(j2 - 90))/180), -sin((pi*j1)/180), 100*cos((pi*j1)/180)*cos((pi*(j2 - 90))/180);
                          sin((pi*j1)/180)*cos((pi*(j2 - 90))/180), -sin((pi*j1)/180)*sin((pi*(j2 - 90))/180),  cos((pi*j1)/180), 100*sin((pi*j1)/180)*cos((pi*(j2 - 90))/180);
                         -sin((pi*(j2 - 90))/180),                  -cos((pi*(j2 - 90))/180),                 0,             95 - 100*sin((pi*(j2 - 90))/180);
                          0,               0,                 0,                         1];

            % transformation matrix for end effector (j3), generated with syms and
            % dh2mat
            tm = [cos((pi*j1)/180)*cos((pi*(j2 - 90))/180)*cos((pi*(j3 + 90))/180) - cos((pi*j1)/180)*sin((pi*(j2 - 90))/180)*sin((pi*(j3 + 90))/180), - cos((pi*j1)/180)*cos((pi*(j2 - 90))/180)*sin((pi*(j3 + 90))/180) - cos((pi*j1)/180)*cos((pi*(j3 + 90))/180)*sin((pi*(j2 - 90))/180), -sin((pi*j1)/180), 100*cos((pi*j1)/180)*cos((pi*(j2 - 90))/180) + 100*cos((pi*j1)/180)*cos((pi*(j2 - 90))/180)*cos((pi*(j3 + 90))/180) - 100*cos((pi*j1)/180)*sin((pi*(j2 - 90))/180)*sin((pi*(j3 + 90))/180);
                  sin((pi*j1)/180)*cos((pi*(j2 - 90))/180)*cos((pi*(j3 + 90))/180) - sin((pi*j1)/180)*sin((pi*(j2 - 90))/180)*sin((pi*(j3 + 90))/180), - sin((pi*j1)/180)*cos((pi*(j2 - 90))/180)*sin((pi*(j3 + 90))/180) - sin((pi*j1)/180)*cos((pi*(j3 + 90))/180)*sin((pi*(j2 - 90))/180),  cos((pi*j1)/180), 100*sin((pi*j1)/180)*cos((pi*(j2 - 90))/180) + 100*sin((pi*j1)/180)*cos((pi*(j2 - 90))/180)*cos((pi*(j3 + 90))/180) - 100*sin((pi*j1)/180)*sin((pi*(j2 - 90))/180)*sin((pi*(j3 + 90))/180); 
                 - cos((pi*(j2 - 90))/180)*sin((pi*(j3 + 90))/180) - cos((pi*(j3 + 90))/180)*sin((pi*(j2 - 90))/180),                                     sin((pi*(j2 - 90))/180)*sin((pi*(j3 + 90))/180) - cos((pi*(j2 - 90))/180)*cos((pi*(j3 + 90))/180),                 0,                                               95 - 100*cos((pi*(j2 - 90))/180)*sin((pi*(j3 + 90))/180) - 100*cos((pi*(j3 + 90))/180)*sin((pi*(j2 - 90))/180) - 100*sin((pi*(j2 - 90))/180);
                   0,            0,                 0,                                   1;];
            % calculates 3x1 array of linear joint velocities
            vm = self.robot.fdk3001(jp, jv);
            vm = vm(1:3);
            hold on;
              % uses set to update position of links from data stored in
              % self.Links
              set(self.Links(), 'xdata', [joint1(1,4) truejoint2(1,4) tm(1,4)], 'ydata', [joint1(2,4) truejoint2(2,4) tm(2,4)], 'zdata', [joint1(3,4) truejoint2(3,4) tm(3,4)]);
              % uses update_joint to update frame of each joint
              self.update_joint(joint1, 1);
              self.update_joint(truejoint2, 2);
              self.update_joint(tm, 3);
              % updates update_velo to update velocity arrow
              self.update_velo(vm, tm(1:3, 4));
              hold off;
        end
            
        % plots the frame of a specified joint using the transformation
        % matrix from the base frame to that joint
        function plot_joint(self, tm, joint)
            % uses quiver3 to plot arrows in x, y, and z to show the
            % orientation frame at the specified joint
            fx = quiver3(tm(1,4), tm(2,4), tm(3,4), self.qm*tm(1,1), self.qm*tm(2,1), self.qm*tm(3,1), "r", 'filled', 'LineWidth', 2, 'MaxHeadSize',1);
            fy = quiver3(tm(1,4), tm(2,4), tm(3,4), self.qm*tm(1,2), self.qm*tm(2,2), self.qm*tm(3,2), "b", 'filled', 'LineWidth', 2, 'MaxHeadSize',1);
            fz = quiver3(tm(1,4), tm(2,4), tm(3,4), self.qm*tm(1,3), self.qm*tm(2,3), self.qm*tm(3,3), "g", 'filled', 'LineWidth', 2, 'MaxHeadSize',1);
            % stores frame information from quiver method in self.Frames
            % in the row corresponding to the specified frame
            self.Frames(joint, :) = [fx, fy, fz];
        end

        % plots the frame of a specified joint using the transformation
        % matrix from the base frame to that joint
        function update_joint(self, tm, joint)
            % uses set and the values stored in self.Frames to update the
            % x, y, and z arrows for the frame at the given point
            set(self.Frames(joint, 1), 'xdata', tm(1,4), 'ydata', tm(2,4), 'zdata', tm(3,4), 'udata', self.qm*tm(1,1), 'vdata', self.qm*tm(2,1), 'wdata', self.qm*tm(3,1));
            set(self.Frames(joint, 2), 'xdata', tm(1,4), 'ydata', tm(2,4), 'zdata', tm(3,4), 'udata', self.qm*tm(1,2), 'vdata', self.qm*tm(2,2), 'wdata', self.qm*tm(3,2));
            set(self.Frames(joint, 3), 'xdata', tm(1,4), 'ydata', tm(2,4), 'zdata', tm(3,4), 'udata', self.qm*tm(1,3), 'vdata', self.qm*tm(2,3), 'wdata', self.qm*tm(3,3));
        end

        % plots the linear velocity arrow at a given joint using quiver3,
        % and stores it to Velo
        function plot_velo(self, vm, ee)
            ve = quiver3(ee(1), ee(2), ee(3), self.qm*vm(1), self.qm*vm(2), self.qm*vm(3), "r", 'filled', 'LineWidth', 2, 'MaxHeadSize',1);
            self.Velo = ve;
        end

        % updates the velocity arrow at a given joint, with built-in
        % scaling based on the magnitude of the velocity
        function update_velo(self, vm, ee)
            r = sqrt((vm(1)^2)+(vm(2)^2)+(vm(3)^3));
            vs = 3;
            if r > 1
                vs = 3 * (log(r) + 1);
            elseif r  < -1
                vs = -3 * (log(abs(r)) - 1);
            else
                vs = 3;
            end
            % sets Velo to the new values
            set(self.Velo, 'xdata', ee(1), 'ydata', ee(2), 'zdata', ee(3), 'udata', vs*vm(1), 'vdata', vs*vm(2), 'wdata', vs*vm(3));
        end

        % prints a message to the model figure using text, at a set
        % position
        function addMessage(~, message)
            %text(message);
            text(-20,-50,0, message);
        end
    end
end