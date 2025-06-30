import 'package:flutter/material.dart';
import 'package:newsapp/presentation/screens/news/category_news_list.dart';
import 'package:provider/provider.dart';
import 'package:newsapp/presentation/state/news_providers.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

final GlobalKey<_HomeScreenState> homeKey = GlobalKey<_HomeScreenState>();
late ScrollController _scrollController;

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final List<String> options = [
    'All',
    'Sports',
    'Technology',
    'Health',
    'Science',
    'Education',
  ];
  late FocusNode _searchFocusNode;
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool searchActive = false;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();
    _tabController = TabController(length: options.length, vsync: this);
    _scrollController = ScrollController();
    // Listener untuk mendeteksi perubahan fokus
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus && searchActive) {
        // Jika fokus hilang dan search masih aktif, tutup search
        Future.microtask(() {
          if (mounted) {
            setState(() {
              searchActive = false;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _searchFocusNode.unfocus();
    _searchFocusNode.removeListener(() {});
    _searchFocusNode.dispose();
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  @override
  void deactivate() {
    // Ketika widget deactivate, pastikan fokus hilang
    _searchFocusNode.unfocus();
    super.deactivate();
  }

  // Handle back button press
  Future<bool> _onWillPop() async {
    if (searchActive || _searchFocusNode.hasFocus) {
      // Jika search aktif atau field memiliki fokus, tutup search terlebih dahulu
      _closeSearch();
      return false; // Jangan keluar dari aplikasi
    }
    return true; // Izinkan keluar dari aplikasi
  }

  void _closeSearch() {
    if (mounted) {
      setState(() {
        searchActive = false;
        _searchController.clear();
        searchQuery = '';
      });
      // Pastikan fokus benar-benar hilang
      _searchFocusNode.unfocus();
      FocusScope.of(context).unfocus();
    }
  }

  void _onSearchTap() {
    if (!mounted) return;

    setState(() {
      if (searchActive) {
        _closeSearch();
      } else {
        searchActive = true;
        _tabController.animateTo(0);
        // Delay sedikit untuk memastikan field sudah ter-render
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted && searchActive) {
            _searchFocusNode.requestFocus();
          }
        });
      }
    });
  }

  void _onSearchSubmitted(String value) async {
    final query = value.trim();
    if (query.isEmpty) return;

    setState(() {
      searchQuery = query;
    });

    // Pindah ke tab "All" dan fetch data
    _tabController.animateTo(0);

    try {
      final provider = context.read<NewsProvider>();
      await provider.fetchNews('all');

      // Tutup keyboard dan search setelah submit
      _searchFocusNode.unfocus();
      FocusScope.of(context).unfocus();

      // Optional: Tampilkan snackbar untuk feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Searching for "$query"...'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      // Handle error jika ada
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to search news'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Widget> pages = [
      CategoryNewsList(
        category: 'all',
        searchQuery: searchQuery,
        scrollController: _scrollController,
      ),
      CategoryNewsList(category: 'sports', scrollController: _scrollController),
      CategoryNewsList(
        category: 'technology',
        scrollController: _scrollController,
      ),
      CategoryNewsList(category: 'health', scrollController: _scrollController),
      CategoryNewsList(
        category: 'science',
        scrollController: _scrollController,
      ),
      CategoryNewsList(
        category: 'education',
        scrollController: _scrollController,
      ),
    ];

    return PopScope(
      canPop: !searchActive && !_searchFocusNode.hasFocus,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _closeSearch();
        }
      },
      child: SafeArea(
        child: GestureDetector(
          onTap: () {
            if (_searchFocusNode.hasFocus) {
              _closeSearch();
            }
          },
          child: DefaultTabController(
            length: options.length - 1,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onTap: () {
                      if (!searchActive) {
                        setState(() {
                          searchActive = true;
                          _tabController.animateTo(0);
                        });
                      }
                    },
                    onSubmitted: _onSearchSubmitted,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: theme.colorScheme.onPrimary,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      hintText: 'Enter a Search News',
                      hintStyle: TextStyle(color: theme.colorScheme.onPrimary),
                      prefixIcon: Icon(
                        Icons.search,
                        color: theme.colorScheme.onPrimary,
                      ),
                      suffixIcon: searchActive
                          ? IconButton(
                              icon: Icon(
                                Icons.close,
                                color: theme.colorScheme.onPrimary,
                              ),
                              onPressed: _closeSearch,
                            )
                          : null,
                    ),
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      height: 1,
                      fontSize: 16,
                    ),
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  tabAlignment: TabAlignment.start,
                  unselectedLabelColor: theme.colorScheme.onPrimaryContainer,
                  tabs: options.map((label) => Tab(text: label)).toList(),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: pages,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Di HomeScreen
  Future<void> refreshCurrentCategory() async {
    final currentCategoryIndex = _tabController.index;
    final category = options[currentCategoryIndex].toLowerCase();

    // Scroll ke atas
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );

    setState(() {
      searchQuery = '';
      _searchController.clear();
    });

  }
}
