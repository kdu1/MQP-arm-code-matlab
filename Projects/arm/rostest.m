
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


javaaddpath ../SimplePacketComsJavaFat-0.6.4.jar;
import edu.wpi.SimplePacketComs.*;
import edu.wpi.SimplePacketComs.device.*;
import edu.wpi.SimplePacketComs.phy.*;
import java.util.*;
import org.hid4java.*;
version -java;
myHIDSimplePacketComs=HIDfactory.get(); %makes new myHIDSimplePacketComs object
myHIDSimplePacketComs.setPid(pid); %these two are used for the hidapi
myHIDSimplePacketComs.setVid(vid);
myHIDSimplePacketComs.connect(); %here is where it calls the actual hid_read, with the readFloats and writeFloats just doing packet stuff

robot = Robot(myHIDSimplePacketComs);
traj_planner = Traj_Planner(robot);

setenv('ROS_MASTER_URI','http://10.0.2.15:11311');
setenv('ROS_IP','10.0.2.15');

%master = ros.Core;
%rosinit('127.0.0.1')
Node = ros.Node('Test','http://10.0.2.15:11311');

armNode = ros.Node('/arm_code');
pub = Node.addPublisher(armNode,'/arm_code','std_msgs/String');
%personalityNode = ros.Node('/shown_personality');
sub = Node.addSubscriber('/shown_personality','std_msgs/String',10);

pub = Node.addPublisher(armNode,'/arm_code','std_msgs/String')
%sub = ros.Subscriber(personalityNode, '/shown_personality','std_msgs/String');

rostopic list

emotion = rosmessage('std_msgs/String');
emotion = sub.LatestMessage
emotion.Data

if strcmp(emotion.Data, "smirk") == 1
    
    fprintf("smirk");
    msg = rosmessage('std_msgs/String');
    msg = "In progress"
    send(pub,msg) % Sent on /arm_code
    pause(1)
    robot.servo_jp([0,0,1]);
    pause(3)
    msg = rosmessage('std_msgs/String');
    msg = "Finished"
    pause(1)
elseif strcmp(emotion.Data, "smile") == 1
    fprintf("smile");
    msg = rosmessage('std_msgs/String');
    msg = "In progress"
    send(pub,msg) % Sent on /arm_code
    pause(1)
    robot.servo_jp([0,0,1]);
    pause(3)
    msg = rosmessage('std_msgs/String');
    msg = "Finished"
    pause(1)
else
    fprintf("invalid message recieved");
end


%msg = rosmessage('std_msgs/String');
%msg.Data = 'In progress';

%send(pub,msg) % Sent from node 1
%pause(1) % Wait for message to update
%sub.LatestMessage

%shutdown procedure
robot.shutdown()
clear('pub','sub','armNode','personalityNode')
clear('master')