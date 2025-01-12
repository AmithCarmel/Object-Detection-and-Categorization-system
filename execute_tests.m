function execute_tests()
    test_cases = {
        create_test_params(5, 5, 3, [2, 0], 50, 10, 300),
        create_test_params(10, 5, 5, [2, 0], 50, 10, 300),
        create_test_params(5, 10, 5, [2, 0], 50, 10, 300),
        create_test_params(5, 5, 0, [1, 0], 30, 10, 200)
    };

    all_results = {};

    % tests
    for i = 1:length(test_cases)
        params = test_cases{i};
        fprintf('Running Test %d...\n', i);
        all_results{i} = simulate_autonomous_vehicle(params);
    end

    %performance metrics
    plot_test_performance(all_results);
end
