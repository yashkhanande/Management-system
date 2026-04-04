import 'package:get/get.dart';
import 'package:managementt/controller/pagination_controller.dart';
import 'package:managementt/model/filter_enums.dart';
import 'package:managementt/model/pagination_models.dart';
import 'package:managementt/model/task.dart';
import 'package:managementt/service/task_pagination_service.dart';

/// Pagination controller for tasks dashboard.
/// Extends PaginationController to handle infinite scrolling for task lists.
class TaskPaginationController extends PaginationController<Task> {
  final TaskPaginationService _taskService = TaskPaginationService();
  var searchQuery = ''.obs;
  var statusFilter = TaskStatusFilter.all.obs;
  var priorityFilter = PriorityFilter.all.obs;

  @override
  Future<PaginatedResponse<Task>> fetchPage(int page, int size) {
    return _taskService.getTasksPaginated(page, size);
  }

  /// Update search query and filter items locally.
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// Update status filter
  void updateStatusFilter(TaskStatusFilter filter) {
    statusFilter.value = filter;
  }

  /// Update priority filter
  void updatePriorityFilter(PriorityFilter filter) {
    priorityFilter.value = filter;
  }

  /// Get filtered list based on search query, status filter, and priority filter.
  List<Task> getFilteredItems(String Function(String ownerId)? getOwnerName) {
    var filtered = items.toList();

    // Apply status filter
    if (statusFilter.value != TaskStatusFilter.all) {
      filtered = filtered.where((task) {
        final status = (task.status ?? '').toUpperCase();
        switch (statusFilter.value) {
          case TaskStatusFilter.todo:
            return status == 'IN_PROGRESS' ||
                status == 'NOT_STARTED' ||
                status == 'TODO';
          case TaskStatusFilter.inProgress:
            return status == 'IN_PROGRESS';
          case TaskStatusFilter.underReview:
            return status == 'REVIEW';
          case TaskStatusFilter.done:
            return status == 'DONE' || status == 'COMPLETED';
          case TaskStatusFilter.overdue:
            return status == 'OVERDUE';
          default:
            return true;
        }
      }).toList();
    }

    // Apply priority filter
    if (priorityFilter.value != PriorityFilter.all) {
      filtered = filtered.where((task) {
        final priority = task.priority.toLowerCase();
        switch (priorityFilter.value) {
          case PriorityFilter.high:
            return priority == 'high';
          case PriorityFilter.medium:
            return priority == 'medium';
          case PriorityFilter.low:
            return priority == 'low';
          default:
            return true;
        }
      }).toList();
    }

    // Apply search query
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((task) {
        final titleMatch = task.title.toLowerCase().contains(query);
        if (getOwnerName != null) {
          final ownerName = getOwnerName(task.ownerId).toLowerCase();
          final ownerMatch = ownerName.contains(query);
          return titleMatch || ownerMatch;
        }
        return titleMatch;
      }).toList();
    }

    return filtered;
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
