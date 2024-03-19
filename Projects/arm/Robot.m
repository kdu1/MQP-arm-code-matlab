classdef Robot < handle
    
    properties
        myHIDSimplePacketComs;
        pol; 
        GRIPPER_ID = 1962;
        endpts = zeros(1,3,'single');
        timeCon = 0.01;
        
    end
    
    methods


        %The is a shutdown function to clear the HID hardware connection
        function  shutdown(self)
	    %Close the device
            self.myHIDSimplePacketComs.disconnect();
        end
        
        % Create a packet processor for an HID device with USB PID 0x007
        function self = Robot(dev)
             self.myHIDSimplePacketComs=dev; 
            self.pol = java.lang.Boolean(false);
        end
        
        %Perform a command cycle. This function will take in a command ID
        %and a list of 32 bit floating point numbers and pass them over the
        %HID interface to the device, it will take the response and parse
        %them back into a list of 32 bit floating point numbers as well
        function com = command(self, idOfCommand, values)
                com= zeros(15, 1, 'single');
                try
                    ds = javaArray('java.lang.Double',length(values));
                    for i=1:length(values)
                        ds(i)= java.lang.Double(values(i));
                    end
                    % Default packet size for HID
                    intid = java.lang.Integer(idOfCommand);
                    self.myHIDSimplePacketComs.writeFloats(intid,  ds);
                    ret = 	self.myHIDSimplePacketComs.readFloats(intid) ;
                    for i=1:length(com)
                       com(i)= ret(i).floatValue();
                    end
                catch exception
                    getReport(exception)
                    disp('Command error, reading too fast');
                end
        end
        
        function com = read(self, idOfCommand)
                com= zeros(15, 1, 'single');
                try

                    % Default packet size for HID
                    intid = java.lang.Integer(idOfCommand);
                    ret = 	self.myHIDSimplePacketComs.readFloats(intid) ;
                    for i=1:length(com)
                       com(i)= ret(i).floatValue();
                    end
                catch exception
                  getReport(exception)
                    disp('Command error, reading too fast');
                end
        end
        
        function  write(self, idOfCommand, values)
                try
                    ds = javaArray('java.lang.Double',length(values));
                    for i=1:length(values)
                        ds(i)= java.lang.Double(values(i));
                    end
                    % Default packet size for HID
                    intid = java.lang.Integer(idOfCommand);
              
                    self.myHIDSimplePacketComs.writeFloats(intid,  ds,self.pol); %id, array, boolean

                catch exception
                    getReport(exception)
                    disp('Command error, reading too fast');
                end
        end
        
        % Specifies a position to the gripper
        function writeGripper(self, value)
            try
                ds = javaArray('java.lang.Byte',length(1));
                ds(1)= java.lang.Byte(value);
                intid = java.lang.Integer(self.GRIPPER_ID);
                self.myHIDSimplePacketComs.writeBytes(intid, ds, self.pol);
            catch exception
                getReport(exception)
                disp('Command error, reading too fast');
            end
        end
        
        % Opens the gripper
        function openGripper(self)
            self.writeGripper(180);
        end
        
        % Closes the gripper
        function closeGripper(self)
            self.writeGripper(0);
        end

        % Returns the current setpoint for all three motors,with the next 
        % setpoint in the motion returned if interpolation is used.
        % The next setpoint is found by reading from the robot and
        % returning a 1x3 array holding the three values
        function setpointjs = setpoint_js(self)
            setpointjs = zeros(1,3,'single'); % creates a 1x3 array to store the values
            returnPacket = self.read(1910); % reads the position and setpoint values from the motors
            setpointjs(1) = returnPacket(2); % sets the first value in the return array to the setpoint of the first motor
            setpointjs(2) = returnPacket(4); % sets the second value in the return array to the setpoint of the second motor
            setpointjs(3) = returnPacket(6); % sets the third value in the return array to the setpoint of the third motor
        end
        
        % returns the position and/or velocity values of the motors in a
        % 2x3 array. takes two booleans to represent whether to return the
        % positions, velocity, or both
        function measuredjs = measured_js(self, GETPOS, GETVEL)
            returnArray = zeros(2,3, 'single'); % creates a 2x3 return array
            posPacket = self.read(1910); % reads the position data from each motor
            if GETPOS % if GETPOS is true
                pos1 = posPacket(3); % gets the position of the first motor
                pos2 = posPacket(5); % gets the position of the second motor
                pos3 = posPacket(7); % gets the position of the third motor
                returnArray(1,:) = [pos1, pos2, pos3]; % sets the top row of the return array to the position values
            end
            velPacket = self.read(1822); % reads the position data from each motor
            if GETVEL % if GETVEL is true
                vel1 = velPacket(3); % gets the velocity of the first motor
                vel2 = velPacket(6); % gets the velocity of the second motor
                vel3 = velPacket(9); % gets the velocity of the third motor
                returnArray(2,:) = [vel1, vel2, vel3]; % sets the bottom row of the return array to the velocity values
            end
            measuredjs = returnArray; % returns the array of position and velocity values
        end

        % moves the motors to the positions specified by the input array,
        % with interpolation specified by intTime
        function interpolate_jp(self, array, intTime)
            packet = zeros(15,1,'single'); % creates an empty 15x1 array to write to the robot
            packet(1) = intTime; % sets interpolation time to intTime
            packet(3) = array(1); % sets first motor's position value to the first value of array 
            packet(4) = array(2); % sets second motor's position value to the second value of array
            packet(5) = array(3); % sets third motor's position value to the third value of array
            self.write(1848, packet); % sends the desired motion command to the robot
            self.endpts = array; % sets the Robot's endpoint as the endpoint specified by the input array
        end

        % moves the motors to the positions specified by the input array,
        % without interpolation
        function servo_jp(self, array)
            packet = zeros(15, 1, 'single'); % creates an empty 15x1 array to write to the robot
            packet(1) = 0; % bypasses interpolation
            packet(3) = array(1); % sets first motor's position value to the first value of array 
            packet(4) = array(2); % sets second motor's position value to the second value of array
            packet(5) = array(3); % sets third motor's position value to the third value of array
            self.write(1848, packet); % sends the desired motion command to the robot
            self.endpts = array; % sets the Robot's endpoint as the endpoint specified by the input array
        end

        % returns the target setpoint of the current motion, regardless of
        % interpolation.
        function goaljs = goal_js(self)
            goaljs = self.endpts; % returns endpts, a property of the Robot class that holds the endpoint of the current motion
        end 

        % function to convert an input array representing one row of a DH
        % table to the corresponding transformation matrix
        function htm = dh2mat(~, array)
            htm = zeros(4,4,'sym'); % builds a 4x4 matrix of zeros to hold our final htm
            theta = array(1); % first value from input array is theta
            d = array(2); % second value from input array is d
            a = array(3); % third value from input array is a
            alpha = array(4); % fourth value from input array is alpha
            % uses standard Ai matrix to convert from DH parameters to Ai
            % values, then replaces placeholders in htm with correct values
            htm(1,1) = cosd(theta);
            htm(1,2) = -sind(theta)*cosd(alpha);
            htm(1,3) = sind(theta)*sind(alpha);
            htm(1,4) = a * cosd(theta);

            htm(2,1) = sind(theta);
            htm(2,2) = cosd(theta)*cosd(alpha);
            htm(2,3) = -cosd(theta)*sind(alpha);
            htm(2,4) = a * sind(theta);

            htm(3,2) = sind(alpha);
            htm(3,3) = cosd(alpha);
            htm(3,4) = d;

            htm(4,4) = 1;
        end

        %function to convert a dh table to its corresponding transformation
        %from the base frame to the end effector
        function T = dh2fk(self, dhtable)
            T = eye(4); %does row 1 to intalize value
            for i = 1:size(dhtable,1) % does any following rows starting at index 2
                T = T * self.dh2mat(dhtable(i, :))
            end
        end
        
        %function to take in joint variables 3x1 matrix and return the transformation
        %from the base frame to the end effector of the 3001 robot
        function T = fk3001(self, jointVars)
            %dh table for 3001 robot!
%             dhTable = [ jointVars(1,1), (55 + 40), 0, -90; 
%                         jointVars(2,1) - 90, 0, 100, 0;
%                         jointVars(3,1) + 90, 0, 100, 0;];
%             T = self.dh2fk(dhTable); %tranformation from base to end
               t1 = jointVars(1,1);
               t2 = jointVars(2,1);
               t3 = jointVars(3,1);

              T = [cos((pi*t1)/180)*cos((pi*(t2 - 90))/180)*cos((pi*(t3 + 90))/180) - cos((pi*t1)/180)*sin((pi*(t2 - 90))/180)*sin((pi*(t3 + 90))/180), - cos((pi*t1)/180)*cos((pi*(t2 - 90))/180)*sin((pi*(t3 + 90))/180) - cos((pi*t1)/180)*cos((pi*(t3 + 90))/180)*sin((pi*(t2 - 90))/180), -sin((pi*t1)/180), 100*cos((pi*t1)/180)*cos((pi*(t2 - 90))/180) + 100*cos((pi*t1)/180)*cos((pi*(t2 - 90))/180)*cos((pi*(t3 + 90))/180) - 100*cos((pi*t1)/180)*sin((pi*(t2 - 90))/180)*sin((pi*(t3 + 90))/180);
                  sin((pi*t1)/180)*cos((pi*(t2 - 90))/180)*cos((pi*(t3 + 90))/180) - sin((pi*t1)/180)*sin((pi*(t2 - 90))/180)*sin((pi*(t3 + 90))/180), - sin((pi*t1)/180)*cos((pi*(t2 - 90))/180)*sin((pi*(t3 + 90))/180) - sin((pi*t1)/180)*cos((pi*(t3 + 90))/180)*sin((pi*(t2 - 90))/180),  cos((pi*t1)/180), 100*sin((pi*t1)/180)*cos((pi*(t2 - 90))/180) + 100*sin((pi*t1)/180)*cos((pi*(t2 - 90))/180)*cos((pi*(t3 + 90))/180) - 100*sin((pi*t1)/180)*sin((pi*(t2 - 90))/180)*sin((pi*(t3 + 90))/180);
                  - cos((pi*(t2 - 90))/180)*sin((pi*(t3 + 90))/180) - cos((pi*(t3 + 90))/180)*sin((pi*(t2 - 90))/180),                                     sin((pi*(t2 - 90))/180)*sin((pi*(t3 + 90))/180) - cos((pi*(t2 - 90))/180)*cos((pi*(t3 + 90))/180),                 0,                                               95 - 100*cos((pi*(t2 - 90))/180)*sin((pi*(t3 + 90))/180) - 100*cos((pi*(t3 + 90))/180)*sin((pi*(t2 - 90))/180) - 100*sin((pi*(t2 - 90))/180);
                  0,  0,                 0,            1;];
        end

        % method to return the transformation matrix for the end effector with respect to the base, 
        % based on the current position of each joint
        function curT = measured_cp(self)
            curPos = self.measured_js(true, false); % get curPos of joints
            curPos = curPos(1,:).';
            curT = self.fk3001(curPos); % gets transformation matrix
        end

        % method to return the transformation matrix for the end effector with respect to the base, 
        % based on the current setpoint of each joint
        % if interpolated motion uses the next setpoint
        function setpoint_cp(self)
            curSP = self.setpoint_js().'; % gets current joint setpoints
            curT = self.fk3001(curSP); % gets transformation matrix
        end

        % method to return the transformation matrix for the end effector with respect to the base, 
        % based on the final setpoint of each joint
        % disregards interpolation
        function goal_cp(self)
            curGP = self.goal_js().'; % gets current joint setpoints
            curT = self.fk3001(curGP); % gets transformation matrix
        end

        % intakes a 3x1 array of end-effector positions relative to the
        % base frame and returns the corresponding 3x1 array of joint
        % positions, using geometrically-derived IK calculations, in
        % elbow-up configurations
        function J = ik3001(~, endPos)
            try
                x = endPos(1);
                y = endPos(2);
                z = endPos(3);
                l1 = 95;
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

                J = [theta1;theta2;theta3];
            %catches exception for invalid joint positions
            catch exception
                getReport(exception);
                error("out of workspace")
            end
        end

        %runs a trajectory using coefficients passed in as tc, and a total
        %runtime of t. if s is true, tc was calculated for joint space, if
        %false tc was calculated for task space. Can be run on cubic or
        %quintic trajectories. It also takes in a model to update the model
        %live as the robot moves through the trajectory.
%         function D = run_trajectory(self, tc, t, s)
%             % s = true -> joint
%             % s = false -> task
%             %checks number of columns for tc
%             tt = size(tc, 2);
%             %creates empty array to store joint position data
%             D = zeros(8000, 4, 'single');
% %             tm = self.measured_cp();
% %             tm = tm(1:3,4)';
% %             tm(1,4) = 0;
% %             D(1, :) = tm;
%             jd = self.measured_js(true, true);
%             jp = jd(1,:);
%             jv = jd(2,:);
%             %model.plot_arm(jp, jv);
%             pause(0.01);
%             jp(1,4) = 0;
% 
%             D(1,1:4) = jp;
%             D(1,5:7) = jv;
%             i = 2;
%             tic
%             while toc < t
%                 % gets determinant of top 3x3 of jacobian
%                 detCheck = self.measured_js(true, false);
%                 detCheck = detCheck(1,:);
%                 jacobv = self.jacob3001(detCheck');
%                 jacobv = jacobv(1:3,:);
%                 DetJv = det(jacobv);
%                 % checks for when the arm is close to reaching singularity
%                 if DetJv < 1.1
%                     %model.addMessage("Approaching Singularity"); % msg to model
%                     %disp('Reached Singlularity');
%                     break
%                 end
%                 curT = toc;
%                 %check for cubic or quintic calculation
%                 switch tt
%                     case 4
%                         a1 = tc(1,1) + tc(1,2) * curT + tc(1,3) * curT^2 + tc(1,4) * curT^3;
%                         a2 = tc(2,1) + tc(2,2) * curT + tc(2,3) * curT^2 + tc(2,4) * curT^3;
%                         a3 = tc(3,1) + tc(3,2) * curT + tc(3,3) * curT^2 + tc(3,4) * curT^3;
%                     case 6
%                         a1 = tc(1,1) + tc(1,2) * curT + tc(1,3) * curT^2 + tc(1,4) * curT^3 + tc(1,5) * curT^4 + tc(1,6) * curT^5;
%                         a2 = tc(2,1) + tc(2,2) * curT + tc(2,3) * curT^2 + tc(2,4) * curT^3 + tc(2,5) * curT^4 + tc(2,6) * curT^5;
%                         a3 = tc(3,1) + tc(3,2) * curT + tc(3,3) * curT^2 + tc(3,4) * curT^3 + tc(3,5) * curT^4 + tc(3,6) * curT^5;
%                 end 
%                 %joint space
%                 if s == true
%                     self.servo_jp([a1, a2, a3]);
%                 %task space
%                 else
%                     A = self.ik3001([a1; a2; a3]);
%                     self.servo_jp(A');
%                 end
% %                 tm = self.measured_cp();
% %                 tm = tm(1:3,4)';
% %                 tm(1,4) = curT;
% %                 D(i, :) = tm;
%                 jd = self.measured_js(true, true);
%                 jp = jd(1,:);
%                 jv = jd(2,:);
%                 jp(1,4) = curT;
%                 %model.plot_arm(jp, jv); % updates model with the current motion step
%                 pause(0.01);
% 
%                 D(i,1:4) = jp;
%                 D(i,5:7) = jv;
%                 D(i, 8) = DetJv; % records determinate of top 3x3 of Jacobian
%                 i = i + 1;
%                 %pause to ensure better data gathering
%                 %pause(0.01);
%             end
%             %cuts D to size and returns it
%             D = D(1:i-1, :);
%         end

 function D = run_trajectory(self, tc, t, s)
            %checks number of columns for tc
            tt = size(tc, 2);%I don't get it I don't how can tc be 3x3 I dont
            %creates empty array to store joint position data
            D = zeros(8000, 4, 'single');
            jd = self.measured_js(true, true); %2 by 3
            jp = jd(1,:); %1 by 3
            jv = jd(2,:); %1 by 3
            pause(0.01);
            jp(1,4) = 0;

            D(1,1:4) = jp;% 0 to 3 (inclusive??) or does it just fill unfilled data with 0?
            % 0 1 2 3
            %there is no 3
            %there is no 3
            %there is no 3
            D(1,5:7) = jv;% 4 to 6
            % 4 5 6
            i = 2;
            tic
            while toc < t
                % gets determinant of top 3x3 of jacobian
                detCheck = self.measured_js(true, false);
                detCheck = detCheck(1,:);
                jacobv = self.jacob3001(detCheck');
                jacobv = jacobv(1:3,:);
                DetJv = det(jacobv);
                % checks for when the arm is close to reaching singularity
                if DetJv < 1.1
                    break
                end
                curT = toc;
                switch tt
                    case 4
                        a1 = tc(1,1) + tc(1,2) * curT + tc(1,3) * curT^2 + tc(1,4) * curT^3;
                        a2 = tc(2,1) + tc(2,2) * curT + tc(2,3) * curT^2 + tc(2,4) * curT^3;
                        a3 = tc(3,1) + tc(3,2) * curT + tc(3,3) * curT^2 + tc(3,4) * curT^3;
                    case 6
                        a1 = tc(1,1) + tc(1,2) * curT + tc(1,3) * curT^2 + tc(1,4) * curT^3 + tc(1,5) * curT^4 + tc(1,6) * curT^5;
                        a2 = tc(2,1) + tc(2,2) * curT + tc(2,3) * curT^2 + tc(2,4) * curT^3 + tc(2,5) * curT^4 + tc(2,6) * curT^5;
                        a3 = tc(3,1) + tc(3,2) * curT + tc(3,3) * curT^2 + tc(3,4) * curT^3 + tc(3,5) * curT^4 + tc(3,6) * curT^5;
                end 
                %joint space
                if s == true
                    self.servo_jp([a1, a2, a3]);
                %task space
                else
                    A = self.ik3001([a1; a2; a3]);%angles to get to desired position
                    self.servo_jp(A');
                end
                jd = self.measured_js(true, true);
                jp = jd(1,:);
                jv = jd(2,:);
                jp(1,4) = curT;
                pause(0.01);

                D(i,1:4) = jp;
                D(i,5:7) = jv;
                D(i, 8) = DetJv; % records determinate of top 3x3 of Jacobian
                i = i + 1;
                %pause to ensure better data gathering
                %pause(0.01);
            end
            %cuts D to size and returns it
            D = D(1:i-1, :);
        end


        % calculates 6x3 manipulator Jacobian from 3x1 array of joint
        % angles
        function J = jacob3001(~, ja)
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

        % calculates 6x1 forward velocity kinematics from joint config q
        % and joint velocities qdot
        function FDK = fdk3001(self, q, qdot)
            J = self.jacob3001(q); % jacobian at q
            FDK = J*qdot';
        end


        function pickAndPlace(self, xi, yi, zi, color)
            traj_planner = Traj_Planner(self);
            traj_time = 3.0;
            tj2 = 1.0;
            aset = traj_planner.cubic_traj(traj_time, [0,0,0], [0,0,0], [100,0,195], [xi,yi,(zi+30)])';
            D1 = self.run_trajectory(aset, traj_time, false);
            aset = traj_planner.cubic_traj(traj_time, [0,0,0], [0,0,0], [xi,yi,zi+30], [xi+7,yi,zi])';
            D1 = self.run_trajectory(aset, traj_time, false);            
            self.closeGripper();
            pause(1);
            aset = traj_planner.cubic_traj(tj2, [0,0,0], [0,0,0], [xi,yi,zi], [100,0,195])';
            D1 = self.run_trajectory(aset, tj2, false);
            %if color == 1
            % if red
            aset = traj_planner.cubic_traj(traj_time, [0,0,0], [0,0,0], [100,0,195], [10,150,30])';
            D1 = self.run_trajectory(aset, traj_time, false);
            %end
            % if color == 2
            % % if orange
            % aset = traj_planner.cubic_traj(traj_time, [0,0,0], [0,0,0], [100,0,195], [10,-150,30])';
            % D1 = self.run_trajectory(aset, traj_time, false);
            % end
            % if color == 3
            % % if yellow
            % aset = traj_planner.cubic_traj(traj_time, [0,0,0], [0,0,0], [100,0,195], [10,90,30])';
            % D1 = self.run_trajectory(aset, traj_time, false);
            % end
            % if color == 4
            % % if green
            % aset = traj_planner.cubic_traj(traj_time, [0,0,0], [0,0,0], [100,0,195], [10,-90,30])';
            % D1 = self.run_trajectory(aset, traj_time, false);
            % end
            % self.openGripper();
            % pause(0.5);
            % self.servo_jp([0;0;0;]);
            % pause(1);
        end
    end
end
