import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loading_widget.dart';
import '../providers/academic_provider.dart';
import '../widgets/resource_card.dart';
import '../../../../core/extensions/theme_extensions.dart';

class OfflineLibraryScreen extends ConsumerWidget {
  const OfflineLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(offlineResourcesProvider);
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        surfaceTintColor: Colors.white,
        elevation: 0.6,
        shadowColor: AppColors.border,
        title: const Text('Offline Library',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: async.when(
        loading: () => const AppLoadingWidget.list(),
        error: (e, _) => AppErrorWidget(e),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                        color: context.cardBg, shape: BoxShape.circle),
                    child: Icon(Icons.cloud_download_outlined,
                        size: 32, color: context.textDisabled),
                  ),
                  const SizedBox(height: 14),
                  const Text('No offline resources',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(
                      'Tap the cloud icon on any resource to save it here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: context.textSecondary)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: items.length,
            itemBuilder: (_, i) => ResourceCard(
              resource: items[i],
              onTap: () =>
                  context.push('/academic/resource/${items[i].id}'),
            ),
          );
        },
      ),
    );
  }
}