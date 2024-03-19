function pickAndPlace(xi, yi, zi)
        traj_planner = Traj_Planner(self);
        traj_time = 3.0;
        tj2 = 1.0;
        aset = traj_planner.cubic_traj(traj_time, [0,0,0], [0,0,0], [1,0,0], [xi,yi,(zi+30)])';
        D1 = self.run_trajectory(aset, traj_time, false);
        % aset = traj_planner.cubic_traj(traj_time, [0,0,0], [0,0,0], [xi,yi,zi+30], [xi+7,yi,zi])';
        % D1 = self.run_trajectory(aset, traj_time, false);            
        % self.closeGripper();
        % pause(1);
        % aset = traj_planner.cubic_traj(tj2, [0,0,0], [0,0,0], [xi,yi,zi], [100,0,195])';
        % D1 = self.run_trajectory(aset, tj2, false);
        % aset = traj_planner.cubic_traj(traj_time, [0,0,0], [0,0,0], [100,0,195], [10,150,30])';
        % D1 = self.run_trajectory(aset, traj_time, false);
end