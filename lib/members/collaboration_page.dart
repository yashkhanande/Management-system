import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/admin/project_detail_page.dart';
import 'package:managementt/components/app_colors.dart';
import 'package:managementt/components/app_render_entrance.dart';
import 'package:managementt/components/add_collaboration.dart';
import 'package:managementt/controller/collaboration_controller.dart';
import 'package:managementt/controller/member_controller.dart';
import 'package:managementt/model/task.dart';
import 'package:managementt/service/member_service.dart';

class CollaborationPage extends StatefulWidget {
  final String? projectId;

  const CollaborationPage({super.key, this.projectId});

  @override
  State<CollaborationPage> createState() => _CollaborationPageState();
}

class _CollaborationPageState extends State<CollaborationPage> {
  late final CollaborationController _collaborationController;
  late final MemberController _memberController;
  final MemberService _memberService = MemberService();
  final Map<String, String> _ownerNameById = <String, String>{};
  bool _isResolvingOwnerNames = false;
  late final String _projectId;

  @override
  void initState() {
    super.initState();
    _collaborationController = Get.isRegistered<CollaborationController>()
        ? Get.find<CollaborationController>()
        : Get.put(CollaborationController());
    _memberController = Get.find<MemberController>();
    _projectId = (widget.projectId ?? Get.arguments ?? '').toString().trim();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_projectId.isEmpty) {
        Get.snackbar(
          'Invalid project',
          'Could not load collaboration details for this project.',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
        return;
      }

      await _refreshData();
    });
  }

  Future<void> _refreshData() async {
    if (_projectId.isEmpty) return;

    await Future.wait([
      _collaborationController.initializeForProject(_projectId),
      if (_memberController.members.isEmpty) _memberController.getMembers(),
    ]);
    await _resolveOwnerNames();
  }

  Future<void> _openAddCollaboration() async {
    if (_projectId.isEmpty) return;

    final added = await Get.to<bool>(
      () => AddCollaboration(projectId: _projectId),
    );
    if (added == true) {
      await _refreshData();
    }
  }

  Future<void> _resolveOwnerNames() async {
    if (_isResolvingOwnerNames) return;

    _isResolvingOwnerNames = true;
    try {
      final unresolvedOwnerIds = _collaborationController.collaborators
          .map((task) => task.ownerId.trim())
          .where((id) => id.isNotEmpty && _memberNameById(id) == id)
          .toSet();

      if (unresolvedOwnerIds.isEmpty) return;

      for (final ownerId in unresolvedOwnerIds) {
        if (_ownerNameById.containsKey(ownerId)) continue;
        try {
          final member = await _memberService.getMemberById(ownerId);
          final name = member.name.trim();
          if (name.isNotEmpty) {
            _ownerNameById[ownerId] = name;
          }
        } catch (_) {
          // Keep owner id as fallback label if lookup fails.
        }
      }

      if (mounted) {
        setState(() {});
      }
    } finally {
      _isResolvingOwnerNames = false;
    }
  }

  String _memberNameById(String ownerId) {
    final normalized = ownerId.trim();
    if (normalized.isEmpty) return '-';

    final cachedName = _ownerNameById[normalized]?.trim() ?? '';
    if (cachedName.isNotEmpty) return cachedName;

    final match = _memberController.members.firstWhereOrNull(
      (member) => (member.id ?? '').trim() == normalized,
    );
    final memberName = match?.name.trim() ?? '';
    if (memberName.isNotEmpty) {
      _ownerNameById[normalized] = memberName;
      return memberName;
    }

    return normalized;
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
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
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

  Widget _buildCollaboratorCard(Task collaborator, int index) {
    final accent =
        AppColors.avatarColors[index % AppColors.avatarColors.length];
    final status = (collaborator.status ?? 'UNKNOWN').replaceAll('_', ' ');

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Get.to(() => ProjectDetailPage(project: collaborator));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
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
                collaborator.title.isEmpty
                    ? '?'
                    : collaborator.title.substring(0, 1).toUpperCase(),
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
                    collaborator.title,
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
                    collaborator.description.isEmpty
                        ? 'No description provided.'
                        : collaborator.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _InfoPill(
                        icon: Icons.person_outline_rounded,
                        label: _memberNameById(collaborator.ownerId),
                      ),

                      _InfoPill(
                        icon: Icons.track_changes_outlined,
                        label: status,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.textSecondary,
            ),
          ],
        ),
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
          final collaborators = _collaborationController.collaborators;
          final isLoading =
              _collaborationController.isLoadingCollaborators.value ||
              _collaborationController.isLoadingProjects.value;
          final error = _collaborationController.lastError.value.trim();

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(16, topPad + 12, 16, 20),
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
                                'Manage Collaboration',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _openAddCollaboration,
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.16,
                                ),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: const Text(
                                'Add',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _HeaderChip(
                              icon: Icons.link_rounded,
                              label: '${collaborators.length} linked projects',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (isLoading && collaborators.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (error.isNotEmpty && collaborators.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildStateCard(
                      icon: Icons.cloud_off_rounded,
                      title: 'Could not load collaborations',
                      message: error,
                      actionText: 'Try Again',
                      onAction: _refreshData,
                    ),
                  )
                else if (collaborators.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildStateCard(
                      icon: Icons.people_alt_outlined,
                      title: 'No collaborations yet',
                      message:
                          'Link this project with another project to manage related work together.',
                      actionText: 'Add Collaboration',
                      onAction: _openAddCollaboration,
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                    sliver: SliverList.builder(
                      itemCount: collaborators.length,
                      itemBuilder: (context, index) {
                        final collaborator = collaborators[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == collaborators.length - 1 ? 0 : 10,
                          ),
                          child: _buildCollaboratorCard(collaborator, index),
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

class _HeaderChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeaderChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
