/// ===================================================================
/// FILE LIST SCREEN - Main screen showing all uploaded files
/// ===================================================================
/// This is the home screen of the app. It displays all files with
/// search, filter, sync status, and navigation to other screens.
/// Uses a Stateful widget to manage local UI state (search bar toggle).
/// ===================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/file_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/file_card.dart';
import '../widgets/sync_status_bar.dart';
import 'file_upload_screen.dart';
import 'file_detail_screen.dart';
import 'shared_files_screen.dart';
import 'search_filter_screen.dart';
import 'login_screen.dart';

/// FileListScreen - Stateful because we toggle the search bar visibility
class FileListScreen extends StatefulWidget {
  const FileListScreen({super.key});

  @override
  State<FileListScreen> createState() => _FileListScreenState();
}

class _FileListScreenState extends State<FileListScreen>
    with SingleTickerProviderStateMixin {
  bool _isSearchVisible = false; // Controls search bar visibility
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    // Load files from local storage when screen initializes
    Future.microtask(() {
      Provider.of<FileProvider>(context, listen: false).loadFiles();
    });
    // Animation controller for fade-in effect
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Consumer listens to FileProvider changes and rebuilds UI
    return Consumer<FileProvider>(
      builder: (context, provider, _) {
        final files = provider.filteredFiles;

        return Scaffold(
          backgroundColor: AppColors.background,
          // ---- App Bar ----
          appBar: AppBar(
            title: const Text(
              'SmartShare',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 0.5,
              ),
            ),
            centerTitle: false,
            elevation: 0,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            actions: [
              // Search toggle button
              IconButton(
                icon: Icon(_isSearchVisible ? Icons.close : Icons.search),
                onPressed: () {
                  setState(() {
                    _isSearchVisible = !_isSearchVisible;
                    if (!_isSearchVisible) {
                      _searchController.clear();
                      provider.setSearchQuery('');
                    }
                  });
                },
                tooltip: 'Search files',
              ),
              // Navigate to Search & Filter screen
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SearchFilterScreen(),
                    ),
                  );
                },
                tooltip: 'Filter files',
              ),
              // Navigate to Shared Files screen
              IconButton(
                icon: const Icon(Icons.people),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SharedFilesScreen(),
                    ),
                  );
                },
                tooltip: 'Shared files',
              ),
              // Logout button
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Logout?'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Provider.of<AuthProvider>(context, listen: false).logout();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                              (_) => false,
                            );
                          },
                          child: const Text('Logout', style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  );
                },
                tooltip: 'Logout',
              ),
            ],
          ),
          // ---- Body ----
          body: FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              children: [
                // Sync status bar at the top
                const SyncStatusBar(),

                // Animated search bar
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _isSearchVisible ? 60 : 0,
                  child: _isSearchVisible
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) =>
                                provider.setSearchQuery(val),
                            decoration: InputDecoration(
                              hintText: 'Search files by name...',
                              prefixIcon: const Icon(Icons.search,
                                  color: AppColors.textSecondary),
                              filled: true,
                              fillColor: AppColors.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 0),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                // File count and status
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${files.length} file${files.length != 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // Show active filters indicator
                      if (provider.filterType != 'All' ||
                          provider.filterCategory != 'All')
                        GestureDetector(
                          onTap: () => provider.clearFilters(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.filter_alt,
                                    size: 14, color: AppColors.primary),
                                SizedBox(width: 4),
                                Text(
                                  'Clear Filters',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // File list or empty state
                Expanded(
                  child: files.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                          itemCount: files.length,
                          itemBuilder: (context, index) {
                            final file = files[index];
                            return FileCard(
                              file: file,
                              onTap: () {
                                // Navigate to file detail screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FileDetailScreen(
                                      fileId: file.id,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          // ---- FAB - Add new file ----
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FileUploadScreen(),
                ),
              );
            },
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Add File'),
          ),
        );
      },
    );
  }

  /// Build the empty state widget when no files exist
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 80,
            color: AppColors.textHint.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No files yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap "Add File" to upload your first file',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}
