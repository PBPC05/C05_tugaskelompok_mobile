import 'package:flutter/material.dart';
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
  final ForumsApiService _apiService = ForumsApiService();
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
    _loadForums();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadForums({int page = 1, bool reset = true}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _currentPage = page;
      });
    }

    try {
      final response = await _apiService.getForums(
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

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: Colors.grey[900],
      child: Column(
        children: [
          // Page info
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white),
                onPressed: _currentPage > 1
                    ? () => _onPageChanged(_currentPage - 1)
                    : null,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Page $_currentPage / $_totalPages',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white),
                onPressed: _currentPage < _totalPages
                    ? () => _onPageChanged(_currentPage + 1)
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Page numbers
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _totalPages,
                (index) {
                  final pageNumber = index + 1;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    child: ElevatedButton(
                      onPressed: () => _onPageChanged(pageNumber),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentPage == pageNumber
                            ? Colors.red[700]
                            : Colors.grey[800],
                        minimumSize: const Size(40, 40),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        '$pageNumber',
                        style: TextStyle(
                          color: _currentPage == pageNumber
                              ? Colors.white
                              : Colors.grey[300],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                              DropdownMenuItem(
                                value: 'hot',
                                child: Text('Hot'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ForumFormPage(),
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ForumDetailPage(forumId: forum.id),
              ),
            );
          },
        );
      },
    );
  }
}