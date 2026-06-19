import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../providers/reputation_provider.dart';

class SkillsManagementScreen extends ConsumerWidget {
  final String? targetUserId;

  const SkillsManagementScreen({super.key, this.targetUserId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = targetUserId ?? ref.watch(currentUserIdProvider2) ?? '';
    final skillsAsync = ref.watch(userSkillsProvider(userId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Skills'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add skill',
            onPressed: () => _showAddSkillDialog(context, ref),
          ),
        ],
      ),
      body: skillsAsync.when(
        data: (skills) {
          if (skills.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.handyman_outlined, size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.4)),
                  const SizedBox(height: 12),
                  Text('No skills yet', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('Tap + to add your first skill', style: theme.textTheme.bodySmall),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: skills.length,
            itemBuilder: (_, i) {
              final skill = skills[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                    child: Icon(Icons.code_rounded, color: theme.colorScheme.primary, size: 20),
                  ),
                  title: Text(skill.skillName, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  subtitle: Row(
                    children: [
                      _ProficiencyChip(level: skill.proficiencyLabel),
                      if (skill.endorsementCount > 0) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.thumb_up_rounded, size: 12, color: theme.colorScheme.primary),
                        const SizedBox(width: 2),
                        Text('${skill.endorsementCount}', style: theme.textTheme.bodySmall),
                      ],
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Proficiency', style: theme.textTheme.bodySmall),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 4,
                            children: ['beginner', 'intermediate', 'advanced', 'expert'].map((l) => ChoiceChip(
                              label: Text(l[0].toUpperCase() + l.substring(1), style: theme.textTheme.bodySmall),
                              selected: skill.proficiencyLevel == l,
                              onSelected: (selected) {
                                if (selected) {
                                  ref.read(reputationNotifierProvider.notifier).updateProficiency(skill.id, l);
                                }
                              },
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            )).toList(),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              OutlinedButton.icon(
                                icon: const Icon(Icons.thumb_up_outlined, size: 16),
                                label: const Text('Endorse'),
                                onPressed: () {
                                  ref.read(reputationNotifierProvider.notifier).endorseSkill(skill.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Skill endorsed!')),
                                  );
                                },
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 20),
                                color: theme.colorScheme.error,
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (c) => AlertDialog(
                                      title: const Text('Remove skill'),
                                      content: Text('Are you sure you want to remove "${skill.skillName}"?'),
                                      actions: [
                                        TextButton(onPressed: () => context.pop(), child: Text('Cancel')),
                                        TextButton(
                                          onPressed: () {
                                            ref.read(reputationNotifierProvider.notifier).removeSkill(skill.id);
                                            context.pop();
                                          },
                                          child: const Text('Remove', style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => AppErrorWidget(err),
      ),
    );
  }

  void _showAddSkillDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Add Skill'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. Python, Public Speaking',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => context.pop(), child: Text('Cancel')),
          FilledButton(
            onPressed: () {
              final skill = controller.text.trim();
              if (skill.isNotEmpty) {
                ref.read(reputationNotifierProvider.notifier).addSkill(skill);
                context.pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _ProficiencyChip extends StatelessWidget {
  final String level;
  const _ProficiencyChip({required this.level});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color color;
    switch (level.toLowerCase()) {
      case 'beginner':
        color = Colors.grey;
      case 'intermediate':
        color = Colors.blue;
      case 'advanced':
        color = Colors.orange;
      case 'expert':
        color = Colors.green;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(level, style: theme.textTheme.bodySmall?.copyWith(color: color, fontSize: 10)),
    );
  }
}
