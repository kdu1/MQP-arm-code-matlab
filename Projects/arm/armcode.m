%%
% RBE 3001 Lab 5 example code!
% adapted from
%%
clc;

clear;
clear java;
format short

%% Flags
DEBUG = false;
STICKMODEL = false;

%% Setup
vid = hex2dec('16c0');
pid = hex2dec('0486');

if DEBUG
    disp(vid);
    disp(pid);
end


javaaddpath ../lib/SimplePacketComsJavaFat-0.6.4.jar;
import edu.wpi.SimplePacketComs.*;
import edu.wpi.SimplePacketComs.device.*;
import edu.wpi.SimplePacketComs.phy.*;
import java.util.*;
import org.hid4java.*;
version -java;
myHIDSimplePacketComs=HIDfactory.get();
myHIDSimplePacketComs.setPid(pid);
myHIDSimplePacketComs.setVid(vid);
myHIDSimplePacketComs.connect();

robot = Robot(myHIDSimplePacketComs);
traj_planner = Traj_Planner(robot);
model = Model(robot);



try
    load("camParams.mat");
    disp("Loaded Camera Parameters from camParams.mat");
catch exception
    disp("Could not find camParams.mat, creating new Camera object");
    cam = Camera();
    save("camParams.mat","cam");
    disp("Saved Camera Parameters to camParams.mat");
end

%% Main Loop
try
    % Set up camera
   
    if cam.params == 0
        error("No camera parameters found!");
    end
    

%inits the total number of balls in the frame
I = cam.getImage();
[ct, rt, mt] = cam.createCircleMask(I, 1);

%loops while any number of balls in present
while size(ct,1) >= 1
%     cRed = zeros(3,3);
%     cOrange = zeros(3,3);
%     cYellow = zeros(3,3);
%     cGreen = zeros(3,3);
%     cPurp = zeros(3,3);
% 
    % %loops and get the centorids of each ball color and saves them
    % for i = 1:5
    %         I = cam.getImage();
    %         [c, r, m] = cam.createCircleMask(I, i+1);
    %     if i == 1 %red balls
    %         for j = 1:size(c, 1)
    %             [x, y, z] = cam.findCentroid(c(j,1), c(j,2));
    %             cRed(j,:) = [x,y,z];
    %         end
    %     end
    %     cRed=cRed(any(cRed,2),any(cRed,1)); %trims the extra zeros
    % 
    %     if i == 2 %orange balls
    %         for j = 1:size(c, 1)
    %             [x, y, z] = cam.findCentroid(c(j,1), c(j,2));
    %             cOrange(j,:) = [x,y,z];
    %         end
    %     end  
    %     cOrange=cOrange(any(cOrange,2),any(cOrange,1)); %trims the extra zeros
    %     if i == 3 %yellow balls
    %         for j = 1:size(c, 1)
    %             [x, y, z] = cam.findCentroid(c(j,1), c(j,2));
    %             cYellow(j,:) = [x,y,z];
    %         end
    %     end
    %     cYellow=cYellow(any(cYellow,2),any(cYellow,1));%trims extra zeros
    % 
    %     if i == 4 %green balls
    %         for j = 1:size(c, 1)
    %             [x, y, z] = cam.findCentroid(c(j,1), c(j,2));
    %             cGreen(j,:) = [x,y,z];
    %         end
    %      end
    %      cGreen=cGreen(any(cGreen,2),any(cGreen,1)); %trims the extra zeros
    % 
    %      if i == 5 %extra credit
    %         for j = 1:size(c, 1)
    %             [x, y, z] = cam.findCentroid(c(j,1), c(j,2));
    %             cGreen(j,:) = [x,y,z];
    %         end
    %      end
    %      cPurp=cPurp(any(cPurp,2),any(cPurp,1)); %trims the extra zeros
    % end


    % elseif size(cOrange) >= 1
        % desPos = cOrange(1,1:3);
        % x = desPos(1,1);
        % y = desPos(1,2);
        % z = desPos(1,3);
        % robot.servo_jp([0;0;0;]);
        % pause(1);
        % robot.openGripper();
        % pause(1);
        % robot.pickAndPlace(x, y, z, 2);
    % elseif size(cYellow) >= 1
    %     desPos = cYellow(1,1:3);
    %     x = desPos(1,1);
    %     y = desPos(1,2);
    %     z = desPos(1,3);
    %     robot.servo_jp([0;0;0;]);
    %     pause(1);
    %     robot.openGripper();
    %     pause(1);
    %     robot.pickAndPlace(x, y, z, 3);
    % elseif size(cGreen) >= 1
    %     desPos = cGreen(1,1:3);
    %     x = desPos(1,1);
    %     y = desPos(1,2);
    %     z = desPos(1,3);
    %     robot.servo_jp([0;0;0;]);
    %     pause(1);
    %     robot.openGripper();
    %     pause(1);
    %     robot.pickAndPlace(x, y, z, 4);
    % elseif size(cPurp) >= 1
    %     desPos = cPurp(1,1:3);
    %     x = desPos(1,1);
    %     y = desPos(1,2);
    %     z = desPos(1,3);
    %     robot.servo_jp([0;0;0;]);
    %     pause(1);
    %     robot.openGripper();
    %     pause(1);
    %     robot.pickAndPlace(x, y, z, 1);
    %end
    move(cRed);

    %checks if any balls are left
    I = cam.getImage();
    [ct, rt, mt] = cam.createCircleMask(I, 1);
end 
%yay!!!
fprintf('\n YOU DID IT!!! \n \n');
catch exception
    fprintf('\n ERROR!!! \n \n');
    disp(getReport(exception));
    disp('Exited on error, clean shutdown');
end

%% Shutdown Procedure
robot.shutdown()
cam.shutdown()

% Picking up and placing function
% if size(cRed) >= 1
function move = move(cRed)
    % Create publisher 
    pub = rospublisher("/arm","arm_msgs/ArmTrajectory");
    
    % Create a message 
    msg = rosmessage("arm_msgs/ArmTrajectory");
    %msg.JointNames{1} = 'Left';
    %msg.JointNames{2} = 'Right';
    %trajMsg = rosmessage("arm_msgs/JointTrajectoryPoint");

    desPos = cRed(1,1:3); %sets the first red ball as the target
    x = desPos(1,1);
    y = desPos(1,2);
    z = desPos(1,3);
    robot.servo_jp([0;0;0;]); %moves home if not there
    pause(1);
    robot.openGripper();
    pause(1);
    robot.pickAndPlace(x, y, z, 1); %picks and place operation'
    while(1)
        msg.Header.Stamp = rostime("now","DataFormat","struct");
        send(pub,msg);
    end
    move = 1; %successful move
end



