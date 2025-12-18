import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:pittalk_mobile/features/forums/data/forums_api.dart';
import 'package:pittalk_mobile/features/forums/data/forums_model.dart';
import 'package:pittalk_mobile/features/forums/presentation/screens/forums_detail.dart';
import 'package:pittalk_mobile/features/forums/presentation/screens/forums_form.dart';
import 'package:pittalk_mobile/features/forums/presentation/widget/forums_card.dart';

class ForumListPage extends StatefulWidget {
  const ForumListPage({Key? key}) : super(key: key);

  @override
  _ForumListPageState createState() => _ForumListPageState();
}

class _ForumListPageState extends State<ForumListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _filter = 'latest';
  String _searchQuery = '';
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  List<Forum> _forums = [];
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // Load forums will be triggered when we have access to CookieRequest
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadForums({int page = 1, bool reset = true}) async {
    final request = Provider.of<CookieRequest>(context, listen: false);
    final apiService = ForumsApiService();

    if (reset) {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _currentPage = page;
      });
    }

    try {
      final response = await apiService.getForums(
        request: request,
        page: page,
        search: _searchQuery,
        filter: _filter,
      );

      setState(() {
        if (reset) {
          _forums = response.results;
        } else {
          _forums.addAll(response.results);
        }
        _totalPages = response.numPages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      _showErrorSnackbar('Failed to load forums: ${e.toString()}');
    }
  }

  List<int?> _generatePageWindow({
    required int currentPage,
    required int totalPages,
    int windowSize = 5,
  }) {
    if (totalPages <= 1) return [1];

    List<int?> pages = [];

    pages.add(1); // always show first page

    int start = currentPage - (windowSize ~/ 2);
    int end = currentPage + (windowSize ~/ 2);

    if (start < 2) {
      end += (2 - start);
      start = 2;
    }

    if (end > totalPages - 1) {
      start -= (end - (totalPages - 1));
      end = totalPages - 1;
    }

    start = start.clamp(2, totalPages - 1);
    end = end.clamp(2, totalPages - 1);

    if (start > 2) pages.add(null);

    for (int i = start; i <= end; i++) {
      pages.add(i);
    }

    if (end < totalPages - 1) pages.add(null);

    pages.add(totalPages);

    return pages;
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _onSearch() {
    setState(() {
      _searchQuery = _searchController.text.trim();
    });
    _loadForums();
  }

  void _onFilterChanged(String? value) {
    if (value != null && value != _filter) {
      setState(() {
        _filter = value;
      });
      _loadForums();
    }
  }

  void _onPageChanged(int page) {
    if (page != _currentPage) {
      _loadForums(page: page);
      
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildPaginationControls() {
    if (_totalPages <= 1) return const SizedBox();

    final pages = _generatePageWindow(
      currentPage: _currentPage,
      totalPages: _totalPages,
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(color: Colors.grey.shade800),
        ),
      ),
      child: Column(
        children: [
          // === PAGE INFO + CHEVRONS ===
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _navButton(
                icon: Icons.chevron_left,
                enabled: _currentPage > 1,
                onTap: () => _onPageChanged(_currentPage - 1),
              ),
              const SizedBox(width: 8),
              Text(
                "Page $_currentPage / $_totalPages",
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(width: 8),
              _navButton(
                icon: Icons.chevron_right,
                enabled: _currentPage < _totalPages,
                onTap: () => _onPageChanged(_currentPage + 1),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // === PAGE NUMBERS (MODERN STYLE) ===
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                for (final page in pages)
                  page == null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            "...",
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : _pageBubble(page),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: enabled ? Colors.grey[850] : Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.shade700,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: enabled ? Colors.white : Colors.grey[700],
          size: 18,
        ),
      ),
    );
  }

  Widget _pageBubble(int page) {
    final bool active = page == _currentPage;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _onPageChanged(page),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: active ? Colors.red[700] : Colors.grey[850],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active ? Colors.red.shade300 : Colors.grey.shade700,
              width: active ? 1.2 : 1,
            ),
          ),
          child: Text(
            "$page",
            style: TextStyle(
              color: active ? Colors.white : Colors.grey[300],
              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Load forums when widget is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_forums.isEmpty && !_isLoading && !_hasError) {
        _loadForums();
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('PitTalk Forums'),
        backgroundColor: Colors.grey[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadForums(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter
          Container(
            color: Colors.grey[900],
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Search Bar
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: const InputDecoration(
                                  hintText: 'Find discussion...',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(
                                    left: 16,
                                    right: 8,
                                    bottom: 12,
                                  ),
                                ),
                                style: const TextStyle(color: Colors.white),
                                onSubmitted: (_) => _onSearch(),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.search, color: Colors.grey),
                              onPressed: _onSearch,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Filter
                Row(
                  children: [
                    const Text(
                      'Filter by:',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _filter,
                            dropdownColor: Colors.grey[900],
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            onChanged: _onFilterChanged,
                            items: const [
                              DropdownMenuItem(
                                value: 'latest',
                                child: Text('Latest'),
                              ),
                              DropdownMenuItem(
                                value: 'oldest',
                                child: Text('Oldest'),
                              ),
                              DropdownMenuItem(
                                value: 'popular',
                                child: Text('Popular'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Loading/Error/Content
          Expanded(
            child: _buildContent(),
          ),

          // Pagination Controls
          _buildPaginationControls(),
        ],
      ),
      floatingActionButton: Consumer<CookieRequest>(
        builder: (context, request, child) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12, right: 12),
            child: FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ForumFormPage(request: request),
                  ),
                );
                if (result == true) {
                  _loadForums();
                }
              },
              backgroundColor: Colors.red[700],
              child: const Icon(Icons.add, color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading && _forums.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_hasError && _forums.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Failed to load forums.',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _loadForums(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
              ),
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }

    if (_forums.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.forum_outlined, color: Colors.grey, size: 64),
            const SizedBox(height: 16),
            const Text(
              'No discussions yet.',
              style: TextStyle(color: Colors.grey, fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'Be the first to post a discussion!',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      itemCount: _forums.length,
      itemBuilder: (context, index) {
        final forum = _forums[index];
        return ForumCard(
          forum: forum,
          onTap: () {
            final request = Provider.of<CookieRequest>(context, listen: false);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ForumDetailPage(
                  forumId: forum.id,
                  request: request,
                ),
              ),
            );
          },
        );
      },
    );
  }
}