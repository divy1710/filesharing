
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/file_provider.dart';
import '../utils/constants.dart';
import '../widgets/file_card.dart';
import 'file_detail_screen.dart';

/// SearchFilterScreen - Stateful because of local search input state
class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({super.key});
  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize search field with current query
    final provider = Provider.of<FileProvider>(context, listen: false);
    _searchController.text = provider.searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FileProvider>(builder: (context, provider, _) {
      final files = provider.filteredFiles;
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Search & Filter', style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0, backgroundColor: AppColors.primary, foregroundColor: Colors.white,
          actions: [
            // Clear all filters
            TextButton(
              onPressed: () {
                provider.clearFilters();
                _searchController.clear();
              },
              child: const Text('Clear All', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        body: Column(children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => provider.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Search files by name...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                        _searchController.clear();
                        provider.setSearchQuery('');
                      })
                    : null,
                filled: true, fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          // Filter chips row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('File Type', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              // File type filter chips
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: provider.availableFileTypes.map((type) {
                    final isSelected = provider.filterType == type;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(type),
                        selected: isSelected,
                        onSelected: (_) => provider.setFilterType(type),
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w500, fontSize: 13,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Category', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              // Category filter chips
              Row(children: ['All', 'Personal', 'Shared'].map((cat) {
                final isSelected = provider.filterCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(cat == 'Shared' ? Icons.people : cat == 'Personal' ? Icons.person : Icons.all_inclusive,
                          size: 16, color: isSelected ? Colors.white : AppColors.textPrimary),
                      const SizedBox(width: 4),
                      Text(cat),
                    ]),
                    selected: isSelected,
                    onSelected: (_) => provider.setFilterCategory(cat),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w500, fontSize: 13,
                    ),
                  ),
                );
              }).toList()),
            ]),
          ),
          const Divider(height: 24),
          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('${files.length} result${files.length != 1 ? 's' : ''} found',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
            ),
          ),
          const SizedBox(height: 8),
          // Results list
          Expanded(
            child: files.isEmpty
                ? const Center(child: Text('No files match your criteria', style: TextStyle(color: AppColors.textHint)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: files.length,
                    itemBuilder: (_, i) {
                      final file = files[i];
                      return FileCard(
                        file: file,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FileDetailScreen(fileId: file.id))),
                      );
                    },
                  ),
          ),
        ]),
      );
    });
  }
}
