import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Danh sách async dùng chung cho các tab lịch sử:
/// loading / error + retry / empty / pull-to-refresh.
class HistoryListView<T> extends StatelessWidget {
  const HistoryListView({
    super.key,
    required this.value,
    required this.onRefresh,
    required this.onRetry,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.itemBuilder,
  });

  final AsyncValue<List<T>> value;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;
  final Widget Function(BuildContext context, T item) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _ErrorView(message: '$error', onRetry: onRetry),
      data: (items) => RefreshIndicator(
        onRefresh: onRefresh,
        color: Colors.green.shade700,
        child: items.isEmpty
            ? _buildScrollableEmptyState(context)
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) =>
                    itemBuilder(context, items[index]),
              ),
      ),
    );
  }

  // Empty state phải cuộn được thì RefreshIndicator mới kéo được.
  Widget _buildScrollableEmptyState(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: constraints.maxHeight,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(emptyIcon, size: 64, color: Colors.grey.shade400),
                ),
                const SizedBox(height: 24),
                Text(
                  emptyTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  emptySubtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            'Error loading data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
