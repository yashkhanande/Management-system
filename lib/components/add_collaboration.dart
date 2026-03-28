import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/components/app_colors.dart';
import 'package:managementt/components/app_render_entrance.dart';
import 'package:managementt/controller/collaboration_controller.dart';
import 'package:managementt/model/task.dart';

class AddCollaboration extends StatefulWidget {
  final String? projectId;

  const AddCollaboration({super.key, this.projectId});

  @override
  State<AddCollaboration> createState() => _AddCollaborationState();
}

class _AddCollaborationState extends State<AddCollaboration> {
  late final CollaborationController _collaborationController;
  late final String _projectId;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _collaborationController = Get.isRegistered<CollaborationController>()
        ? Get.find<CollaborationController>()
        : Get.put(CollaborationController());
    _projectId = (widget.projectId ?? Get.arguments ?? '').toString().trim();

    _searchController.addListener(() {
      if (!mounted) return;
      setState(() {
        _searchQuery = _searchController.text;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_projectId.isEmpty) {
        Get.snackbar(
          'Invalid project',
          'Could not resolve project id for collaboration.',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
        return;
      }

      await Future.wait([
        _collaborationController.fetchAllProjects(),
        _collaborationController.getCollaboratedProjects(_projectId),
      ]);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    if (_projectId.isEmpty) return;

    await Future.wait([
      _collaborationController.fetchAllProjects(),
      _collaborationController.getCollaboratedProjects(_projectId),
    ]);
  }

  Future<void> _addCollaborator(Task project) async {
    final collaboratorId = (project.id ?? '').trim();
    if (collaboratorId.isEmpty) return;

    final ok = await _collaborationController.addCollaborator(
      taskId: _projectId,
      collaboratorProjectId: collaboratorId,
    );

    if (!mounted) return;

    if (!ok) {
      final message = _collaborationController.lastError.value.trim();
      Get.snackbar(
        'Could not add collaboration',
        message.isEmpty ? 'Please try again.' : message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    Get.snackbar(
      'Collaboration added',
      '"${project.title}" linked successfully.',
      backgroundColor: AppColors.success,
      colorText: Colors.white,
    );
    Get.back(result: true);
  }

  String _shortDate(DateTime? date) {
    if (date == null) return 'No deadline';
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildStateCard({
    required IconData icon,
    required String title,
    required String message,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: AppColors.primary, size: 26),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              if (actionText != null && onAction != null) ...[
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(
                    actionText,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectCard(Task project, int index) {
    final accent =
        AppColors.avatarColors[index % AppColors.avatarColors.length];
    final isSubmitting = _collaborationController.isSubmitting.value;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              project.title.isEmpty
                  ? '?'
                  : project.title.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  project.description.isEmpty
                      ? 'No description provided.'
                      : project.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: isSubmitting ? null : () => _addCollaborator(project),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Add',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: AppRenderEntrance(
        child: Obx(() {
          final available = _collaborationController.availableProjectsFor(
            _projectId,
            searchQuery: _searchQuery,
          );
          final isLoading =
              _collaborationController.isLoadingProjects.value ||
              _collaborationController.isLoadingCollaborators.value;
          final error = _collaborationController.lastError.value.trim();

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(16, topPad + 12, 16, 18),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF3B5BEE)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(26),
                        bottomRight: Radius.circular(26),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: Get.back,
                              splashRadius: 21,
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Expanded(
                              child: Text(
                                'Add Collaboration',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Select another project to collaborate with this project.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 44,
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText:
                                  'Search projects, owner, description...',
                              hintStyle: TextStyle(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: 13,
                              ),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.14),
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: Colors.white70,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isLoading && available.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (error.isNotEmpty && available.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildStateCard(
                      icon: Icons.cloud_off_rounded,
                      title: 'Could not load projects',
                      message: error,
                      actionText: 'Try Again',
                      onAction: _refreshData,
                    ),
                  )
                else if (available.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildStateCard(
                      icon: Icons.playlist_add_check_circle_outlined,
                      title: 'No eligible projects',
                      message:
                          'The current project and already-linked projects are hidden from this list.',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                    sliver: SliverList.builder(
                      itemCount: available.length,
                      itemBuilder: (context, index) {
                        final project = available[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == available.length - 1 ? 0 : 10,
                          ),
                          child: _buildProjectCard(project, index),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
