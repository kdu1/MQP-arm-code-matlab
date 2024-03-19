function out = callRobot(packetComs)
obj = Robot(packetComs);
obj.shutdown();
out = 0;
end