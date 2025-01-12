function params = create_test_params(num_dynamic, num_static, num_mirrored, ego_velocity, sensing_range, safe_distance_threshold, sim_time)
    dynamic_objects = rand(num_dynamic, 4) * 100 - 50; % [x, y, vx, vy]
    static_objects = rand(num_static, 2) * 100 - 50;   % [x, y]
    mirrored_objects = static_objects(1:num_mirrored, :) + randn(num_mirrored, 2) * 5; % Mirrored objects

    params = struct('sim_time', sim_time, 'dt', 1 / 30, 'sensing_range', sensing_range, ...
                    'safe_distance_threshold', safe_distance_threshold, 'ego_velocity', ego_velocity, ...
                    'ego_pos', [0, 0], 'dynamic_objects', dynamic_objects, ...
                    'static_objects', static_objects, 'mirrored_objects', mirrored_objects);
end
