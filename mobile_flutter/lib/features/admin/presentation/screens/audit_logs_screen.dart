import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_widgets.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/guards/admin_guard.dart';
import '../../data/models/audit_log_model.dart';

class AuditLogsScreen extends ConsumerStatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  ConsumerState<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends ConsumerState<AuditLogsScreen> {
  static const _pageSize = 25;

  static const _actionOptions = [
    'approve_verification', 'reject_verification',
    'approved_community_request', 'rejected_community_request',
    'create_community',
    'approved_announcement_request', 'rejected_announcement_request',
    'approve_event', 'delete_event',
    'resolved_moderation', 'dismissed_moderation',
    'resolve_marketplace_report',
    'create_university', 'update_university', 'delete_university',
    'create_faculty', 'update_faculty', 'delete_faculty',
    'create_department', 'update_department', 'delete_department',
    'assign_ambassador', 'update_ambassador_status',
    'enable_feature_flag', 'disable_feature_flag',
    'assign_admin_role', 'update_admin_status', 'remove_admin',
  ];

  static const _entityOptions = [
    'verification', 'community', 'announcement', 'event',
    'moderation', 'marketplace_report',
    'university', 'faculty', 'department',
    'ambassador', 'feature_flag', 'admin',
  ];

  final _actorCtrl = TextEditingController();
  String? _actionFilter;
  String? _entityFilter;
  DateTimeRange? _dateRange;
  bool _filtersExpanded = false;

  final List<AuditLogModel> _logs = [];
  bool _loading = false;
  bool _hasMore = true;
  int _offset = 0;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _actorCtrl.dispose();
    super.dispose();
  }

  Future<void> _load({bool reset = false}) async {
    if (_loading) return;
    if (reset) {
      _logs.clear();
      _offset = 0;
      _hasMore = true;
      _error = null;
    }
    setState(() => _loading = true);
    try {
      final repo = ref.read(adminRepositoryProvider);
      final newLogs = await repo.getAuditLogs(
        actionFilter: _actionFilter,
        entityType: _entityFilter,
        startDate: _dateRange?.start,
        endDate: _dateRange?.end,
        limit: _pageSize,
        offset: _offset,
      );
      final actor = _actorCtrl.text.trim().toLowerCase();
      final filtered = actor.isEmpty
          ? newLogs
          : newLogs.where((l) => (l.actorName ?? '').toLowerCase().contains(actor)).toList();
      setState(() {
        _logs.addAll(filtered);
        _offset += _pageSize;
        _hasMore = newLogs.length == _pageSize;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  bool get _hasActiveFilters =>
      _actionFilter != null ||
      _entityFilter != null ||
      _dateRange != null ||
      _actorCtrl.text.trim().isNotEmpty;

  void _resetFilters() {
    setState(() {
      _actionFilter = null;
      _entityFilter = null;
      _dateRange = null;
      _actorCtrl.clear();
    });
    _load(reset: true);
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: now,
      initialDateRange: _dateRange,
    );
    if (picked != null && mounted) {
      setState(() => _dateRange = picked);
      _load(reset: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminGuard(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Audit Logs'),
          actions: [
            if (_hasActiveFilters)
              TextButton(
                onPressed: _resetFilters,
                child: Text('Clear', style: TextStyle(color: context.primary)),
              ),
            IconButton(
              icon: Badge(
                isLabelVisible: _hasActiveFilters,
                child: const Icon(Icons.filter_list_rounded),
              ),
              tooltip: 'Filters',
              onPressed: () => setState(() => _filtersExpanded = !_filtersExpanded),
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => _load(reset: true),
            ),
          ],
        ),
        body: Column(
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: _filtersExpanded ? _FilterPanel(
                actionFilter: _actionFilter,
                entityFilter: _entityFilter,
                dateRange: _dateRange,
                actorCtrl: _actorCtrl,
                actionOptions: _actionOptions,
                entityOptions: _entityOptions,
                onActionChanged: (v) { setState(() => _actionFilter = v); _load(reset: true); },
                onEntityChanged: (v) { setState(() => _entityFilter = v); _load(reset: true); },
                onDateRangeTap: _pickDateRange,
                onActorSearch: () => _load(reset: true),
              ) : const SizedBox.shrink(),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_error != null && _logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: context.error),
            const SizedBox(height: 12),
            Text('Failed to load audit logs', style: TextStyle(color: context.textSecondary)),
            const SizedBox(height: 12),
            FilledButton(onPressed: () => _load(reset: true), child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_loading && _logs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_rounded, size: 48, color: context.borderCol),
            const SizedBox(height: 12),
            Text(
              _hasActiveFilters ? 'No logs match your filters' : 'No audit logs yet',
              style: TextStyle(fontSize: 16, color: context.textSecondary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _load(reset: true),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: _logs.length + (_hasMore ? 1 : 0),
        itemBuilder: (_, i) {
          if (i == _logs.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: _loading
                    ? const CircularProgressIndicator()
                    : FilledButton.tonal(
                        onPressed: _load,
                        child: const Text('Load more'),
                      ),
              ),
            );
          }
          return _AuditLogCard(log: _logs[i]);
        },
      ),
    );
  }
}

// ── Filter panel ──────────────────────────────────────────────────────────────

class _FilterPanel extends StatelessWidget {
  final String? actionFilter;
  final String? entityFilter;
  final DateTimeRange? dateRange;
  final TextEditingController actorCtrl;
  final List<String> actionOptions;
  final List<String> entityOptions;
  final ValueChanged<String?> onActionChanged;
  final ValueChanged<String?> onEntityChanged;
  final VoidCallback onDateRangeTap;
  final VoidCallback onActorSearch;

  const _FilterPanel({
    required this.actionFilter,
    required this.entityFilter,
    required this.dateRange,
    required this.actorCtrl,
    required this.actionOptions,
    required this.entityOptions,
    required this.onActionChanged,
    required this.onEntityChanged,
    required this.onDateRangeTap,
    required this.onActorSearch,
  });

  @override
  Widget build(BuildContext context) {
    final dateLabel = dateRange == null
        ? 'Date range'
        : '${_fmt(dateRange!.start)} – ${_fmt(dateRange!.end)}';

    return Container(
      color: context.surfaceCard,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _DropdownChip<String>(
                  label: 'Action',
                  value: actionFilter,
                  items: actionOptions,
                  onChanged: onActionChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DropdownChip<String>(
                  label: 'Entity',
                  value: entityFilter,
                  items: entityOptions,
                  onChanged: onEntityChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDateRangeTap,
                  icon: const Icon(Icons.date_range_rounded, size: 16),
                  label: Text(dateLabel, overflow: TextOverflow.ellipsis),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: actorCtrl,
                  decoration: InputDecoration(
                    hintText: 'Actor name',
                    prefixIcon: const Icon(Icons.person_search_rounded, size: 18),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => onActorSearch(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';
}

class _DropdownChip<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  const _DropdownChip({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      style: TextStyle(fontSize: 12, color: context.textPrimary),
      items: [
        DropdownMenuItem<T>(value: null, child: Text('All', style: TextStyle(color: context.textSecondary))),
        ...items.map((i) => DropdownMenuItem<T>(
          value: i,
          child: Text(i.toString().replaceAll('_', ' '), overflow: TextOverflow.ellipsis),
        )),
      ],
      onChanged: onChanged,
    );
  }
}

// ── Log card ──────────────────────────────────────────────────────────────────

class _AuditLogCard extends StatelessWidget {
  final AuditLogModel log;
  const _AuditLogCard({required this.log});

  IconData get _entityIcon {
    switch (log.entityType) {
      case 'university': return Icons.account_balance_rounded;
      case 'faculty': return Icons.school_rounded;
      case 'department': return Icons.account_tree_rounded;
      case 'verification': return Icons.verified_user_rounded;
      case 'badge': return Icons.workspace_premium_rounded;
      case 'community': return Icons.groups_rounded;
      case 'admin': return Icons.admin_panel_settings_rounded;
      case 'announcement': return Icons.campaign_rounded;
      case 'event': return Icons.event_rounded;
      case 'moderation': return Icons.gavel_rounded;
      case 'marketplace_report': return Icons.storefront_rounded;
      case 'ambassador': return Icons.emoji_people_rounded;
      case 'feature_flag': return Icons.toggle_on_rounded;
      default: return Icons.history_rounded;
    }
  }

  Color _actionColor(BuildContext context) {
    final a = log.action;
    if (a.startsWith('approve') || a.startsWith('enable') || a.startsWith('create') || a == 'assign_ambassador' || a == 'assign_admin_role') {
      return Colors.green;
    }
    if (a.startsWith('reject') || a.startsWith('delete') || a.startsWith('remove') || a.startsWith('disable')) {
      return context.error;
    }
    if (a.startsWith('update')) return Colors.orange;
    return context.primary;
  }

  @override
  Widget build(BuildContext context) {
    final color = _actionColor(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderCol),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_entityIcon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.action.replaceAll('_', ' '),
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.textPrimary),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.person_outline_rounded, size: 12, color: context.textSecondary),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        log.actorName ?? 'Unknown',
                        style: TextStyle(fontSize: 11, color: context.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: context.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        log.entityType.replaceAll('_', ' '),
                        style: TextStyle(fontSize: 10, color: context.primary, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                if (log.details.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _formatDetails(log.details),
                    style: TextStyle(fontSize: 10, color: context.textDisabled),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  timeAgo(log.createdAt),
                  style: TextStyle(fontSize: 10, color: context.textDisabled),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDetails(Map<String, dynamic> details) {
    return details.entries.map((e) => '${e.key}: ${e.value}').join(' · ');
  }
}
