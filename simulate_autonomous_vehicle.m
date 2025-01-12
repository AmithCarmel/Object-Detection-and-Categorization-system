function results = simulate_autonomous_vehicle(params)
    % Parameters
    sim_time = params.sim_time; % simulation time (frames)
    dt = params.dt; % Time step
    sensing_range = params.sensing_range; % Detection range
    safe_distance_threshold = params.safe_distance_threshold; % Safe distance threshold
    ego_velocity = params.ego_velocity; % Ego vehicle velocity
    ego_pos = params.ego_pos; % Initial position of the ego vehicle
    dynamic_objects = params.dynamic_objects; % Dynamic objects [x, y, vx, vy]
    static_objects = params.static_objects; % Static objects [x, y]
    mirrored_objects = params.mirrored_objects; % Mirrored objects (false positives)

    results.frames = struct('mirrored_count', [], ...
                            'safe_count', [], ...
                            'unsafe_count', [], ...
                            'duplicate_count', [], ...
                            'threshold_time', [], ...
                            'grouping_time', [], ...
                            'disappearance_time', []);
    results.performance_metrics = struct('mirrored_avg', 0, ...
                                         'safe_avg', 0, ...
                                         'unsafe_avg', 0, ...
                                         'duplicates_avg', 0, ...
                                         'threshold_avg', 0, ...
                                         'grouping_avg', 0, ...
                                         'disappearance_avg', 0, ...
                                         'total_time', 0);

    %time counters
    mirrored_disappearance_time = NaN * ones(size(mirrored_objects, 1), 1); % Store disappearance times
    threshold_times = zeros(size(dynamic_objects, 1), 1); % Threshold maintaining times
    start_grouping_time = zeros(1, sim_time); % Time taken for grouping objects each frame

    %visualization
    figure;
    hold on;
    grid on;
    axis([-100, 100, -100, 100]);
    title('Real-Time Object Detection');
    xlabel('X Position');
    ylabel('Y Position');

    % test time clock
    tic;

    % Simulation Loop
    for t = 1:sim_time
        % Update ego vehicle position
        ego_pos = ego_pos + ego_velocity * dt;

        % dynamic objects positions
        dynamic_objects(:, 1:2) = dynamic_objects(:, 1:2) + dynamic_objects(:, 3:4) * dt;

        %counts for this frame
        mirrored_count = 0;
        safe_count = 0;
        unsafe_count = 0;
        duplicate_count = 0;
        grouping_start_time = tic;

        % dynamic objects
        for i = 1:size(dynamic_objects, 1)
            dist = norm(ego_pos - dynamic_objects(i, 1:2));
            if dist <= sensing_range
                if dist >= safe_distance_threshold
                    safe_count = safe_count + 1;
                else
                    unsafe_count = unsafe_count + 1;
                end

                % Track threshold maintaining time (for dynamic objects)
                threshold_times(i) = threshold_times(i) + dt;
            end
        end

        % static objects
        for i = 1:size(static_objects, 1)
            dist = norm(ego_pos - static_objects(i, :));
            if dist <= sensing_range
                if dist >= safe_distance_threshold
                    safe_count = safe_count + 1;
                else
                    unsafe_count = unsafe_count + 1;
                end
            end
        end

        % mirrored objects (false positives)
        remaining_mirrored_objects = [];
        for i = 1:size(mirrored_objects, 1)
            dist = norm(ego_pos - mirrored_objects(i, :));
            if dist <= sensing_range
                mirrored_count = mirrored_count + 1;

                % disappearance time for mirrored objects
                if isnan(mirrored_disappearance_time(i))
                    mirrored_disappearance_time(i) = t * dt; % First detection time
                end

                for j = 1:size(static_objects, 1)
                    if norm(mirrored_objects(i, :) - static_objects(j, :)) < 5
                        duplicate_count = duplicate_count + 1;
                    end
                end

                % for keeping mirrored objects that are still in range
                remaining_mirrored_objects = [remaining_mirrored_objects; mirrored_objects(i, :)];
            end
        end

        %  mirrored objects list to remove those out of range updation
        mirrored_objects = remaining_mirrored_objects;

        % Visualization
        cla;
        hold on;
        grid on;

        % Plot ego vehicle
        plot(ego_pos(1), ego_pos(2), 'bo', 'MarkerSize', 10, 'LineWidth', 2);

        % dynamic objects
        plot(dynamic_objects(:, 1), dynamic_objects(:, 2), 'ro', 'MarkerSize', 8);
        text(dynamic_objects(:, 1), dynamic_objects(:, 2), 'D', 'Color', 'r');

        % static objects
        plot(static_objects(:, 1), static_objects(:, 2), 'gs', 'MarkerSize', 8);
        text(static_objects(:, 1), static_objects(:, 2), 'S', 'Color', 'g');

        %mirrored objects (false positives) only if not empty
        if ~isempty(mirrored_objects)
            plot(mirrored_objects(:, 1), mirrored_objects(:, 2), 'kx', 'MarkerSize', 8);
            text(mirrored_objects(:, 1), mirrored_objects(:, 2), 'M', 'Color', 'k');
        end

        % sensing range
        viscircles(ego_pos, sensing_range, 'Color', 'b', 'LineStyle', '--');

        % title with frame number updation
        title(['Real-Time Object Detection - Frame ', num2str(t)]);

        % Pausing to simulate frame rate (30 FPS)
        pause(dt);

        % Recording frame results
        results.frames(t).mirrored_count = mirrored_count;
        results.frames(t).safe_count = safe_count;
        results.frames(t).unsafe_count = unsafe_count;
        results.frames(t).duplicate_count = duplicate_count;
        results.frames(t).threshold_time = sum(threshold_times);
        results.frames(t).grouping_time = toc(grouping_start_time); % Time taken for grouping objects
        results.frames(t).disappearance_time = mirrored_disappearance_time;

    end

    % Total time taken for the simulation
    results.performance_metrics.total_time = toc;

    % Computing average metrics for performance
    mirrored_counts = [results.frames.mirrored_count];
    safe_counts = [results.frames.safe_count];
    unsafe_counts = [results.frames.unsafe_count];
    duplicate_counts = [results.frames.duplicate_count];
    threshold_times = [results.frames.threshold_time];
    grouping_times = [results.frames.grouping_time];
    disappearance_times = mirrored_disappearance_time(mirrored_disappearance_time ~= NaN);

    results.performance_metrics.mirrored_avg = mean(mirrored_counts);
    results.performance_metrics.safe_avg = mean(safe_counts);
    results.performance_metrics.unsafe_avg = mean(unsafe_counts);
    results.performance_metrics.duplicates_avg = mean(duplicate_counts);
    results.performance_metrics.threshold_avg = mean(threshold_times);
    results.performance_metrics.grouping_avg = mean(grouping_times);
    results.performance_metrics.disappearance_avg = mean(disappearance_times);

    % performance metrics in the command window
    disp('Performance Metrics:');
    disp(['Average Mirrored Objects: ', num2str(results.performance_metrics.mirrored_avg)]);
    disp(['Average Safe Distance Objects: ', num2str(results.performance_metrics.safe_avg)]);
    disp(['Average Unsafe Distance Objects: ', num2str(results.performance_metrics.unsafe_avg)]);
    disp(['Average Duplicate Objects (Mirrored): ', num2str(results.performance_metrics.duplicates_avg)]);
    disp(['Average Threshold Maintaining Time: ', num2str(results.performance_metrics.threshold_avg)]);
    disp(['Average Grouping Time: ', num2str(results.performance_metrics.grouping_avg)]);
    disp(['Average Disappearance Time for Mirrored Objects: ', num2str(results.performance_metrics.disappearance_avg)]);
    disp(['Total Simulation Time: ', num2str(results.performance_metrics.total_time)]);
end
