import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search students, communities, announcements...',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
            border: InputBorder.none,
            filled: false,
          ),
          style: const TextStyle(fontSize: 16),
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => setState(() {}),
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() {});
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _FilterChip('All', 'all'),
                  const SizedBox(width: 8),
                  _FilterChip('Students', 'students'),
                  const SizedBox(width: 8),
                  _FilterChip('Communities', 'communities'),
                  const SizedBox(width: 8),
                  _FilterChip('Announcements', 'announcements'),
                  const SizedBox(width: 8),
                  _FilterChip('Discussions', 'discussions'),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _searchController.text.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text(
                          'Search UNIFY',
                          style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[500]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Find students, communities, and more',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        'Results for "${_searchController.text}"',
                        style: theme.textTheme.titleSmall?.copyWith(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.search_off, size: 48, color: Colors.grey[300]),
                            const SizedBox(height: 8),
                            Text('Search results will appear here',
                                style: TextStyle(color: Colors.grey[500])),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _FilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0066FF) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
