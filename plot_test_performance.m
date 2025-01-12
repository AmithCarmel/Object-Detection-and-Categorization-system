function plot_test_performance(all_results)
    mirrored_avg = cellfun(@(r) r.performance_metrics.mirrored_avg, all_results);
    safe_avg = cellfun(@(r) r.performance_metrics.safe_avg, all_results);
    unsafe_avg = cellfun(@(r) r.performance_metrics.unsafe_avg, all_results);
    duplicates_avg = cellfun(@(r) r.performance_metrics.duplicates_avg, all_results);
    threshold_avg = cellfun(@(r) r.performance_metrics.threshold_avg, all_results);
    grouping_avg = cellfun(@(r) r.performance_metrics.grouping_avg, all_results);
    disappearance_avg = cellfun(@(r) r.performance_metrics.disappearance_avg, all_results);

    figure;
    hold on;
    plot(mirrored_avg, 'o-', 'DisplayName', 'Mirrored Objects');
    plot(safe_avg, 's-', 'DisplayName', 'Safe Distance Objects');
    plot(unsafe_avg, '^-', 'DisplayName', 'Unsafe Distance Objects');
    plot(duplicates_avg, 'x-', 'DisplayName', 'Duplicate Objects');
    plot(threshold_avg, 'd-', 'DisplayName', 'Threshold Maintaining Time');
    plot(grouping_avg, 'p-', 'DisplayName', 'Grouping Time');
    plot(disappearance_avg, 'h-', 'DisplayName', 'Mirrored Disappearance Time');
    xlabel('Test Number');
    ylabel('Average Count / Time (seconds)');
    title('Performance Metrics Across Tests');
    legend;
end
