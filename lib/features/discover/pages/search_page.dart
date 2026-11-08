import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/features/discover/models/saved_search.dart';
import 'package:vidsell/features/discover/models/search_suggestion.dart';
import 'package:vidsell/features/discover/repositories/search_repository.dart';
import 'package:vidsell/features/discover/repositories/engagement_repository.dart';
import 'package:vidsell/models/product/product.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vidsell/features/discover/widgets/product_card.dart';
import 'package:vidsell/features/auth/bloc/auth_bloc.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, this.repository, this.engagementRepository});

  final SearchRepository? repository;
  final EngagementRepository? engagementRepository;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<SavedSearch> _recentSearches = const [];
  bool _isLoadingRecentSearches = true;
  Object? _recentSearchError;

  List<SearchSuggestion> _filteredSuggestions = const [];
  List<Product> _results = const [];
  bool _isLoadingSuggestions = false;
  bool _isLoadingResults = false;
  bool _hasSearched = false;
  String? _suggestionError;
  String? _searchError;
  int _suggestionRequestId = 0;
  int _searchRequestId = 0;
  AuthBloc? _authBloc;
  StreamSubscription<AuthState>? _authSubscription;
  late final SearchRepository _repository;
  late final EngagementRepository _engagementRepository;
  bool get _isSearching => _searchController.text.trim().isNotEmpty;
  bool _suppressQueryListener = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? context.read<SearchRepository>();
    _engagementRepository =
        widget.engagementRepository ?? context.read<EngagementRepository>();
    _authBloc = context.read<AuthBloc?>();
    // Always attempt to load — skipping when status is 'unknown' caused a
    // blank history screen if auth resolved before the stream listener fired.
    _loadRecentSearches();
    _authSubscription = _authBloc?.stream.listen(_handleAuthState);
    // Autofocus as soon as the page opens, so the keyboard shows
    // immediately — matching the tap-to-search UX from Discover.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FocusScope.of(context).requestFocus(_focusNode);
      // If auth was still resolving during initState, retry loading history
      // now that we have a settled auth state.
      if (_recentSearches.isEmpty && !_isLoadingRecentSearches) {
        _loadRecentSearches();
      }
    });
    _searchController.addListener(_onQueryChanged);
  }

  void _handleAuthState(AuthState state) {
    if (!mounted) return;
    if (state.status == AuthStatus.authenticated) {
      _loadRecentSearches();
    } else {
      setState(() {
        _recentSearches = const [];
        _recentSearchError = null;
        _isLoadingRecentSearches = false;
      });
    }
  }

  Future<void> _loadRecentSearches() async {
    setState(() {
      _isLoadingRecentSearches = true;
      _recentSearchError = null;
    });
    try {
      final searches = await _engagementRepository.fetchSavedSearches();
      if (!mounted) return;
      setState(() {
        _recentSearches = searches;
        _isLoadingRecentSearches = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _recentSearchError = error;
        _isLoadingRecentSearches = false;
      });
    }
  }

  void _onQueryChanged() {
    if (_suppressQueryListener) return;
    // Debounce so recent searches don't vanish the instant a key is pressed.
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      final query = _searchController.text.trim().toLowerCase();
      if (query.isEmpty) {
        _suggestionRequestId++;
        _searchRequestId++;
        setState(() {
          _filteredSuggestions = const [];
          _results = const [];
          _isLoadingSuggestions = false;
          _isLoadingResults = false;
          _hasSearched = false;
          _suggestionError = null;
          _searchError = null;
        });
        return;
      }

      _searchRequestId++;
      setState(() {
        _filteredSuggestions = const [];
        _results = const [];
        _isLoadingResults = false;
        _hasSearched = false;
        _searchError = null;
      });
      _loadSuggestions(query);
    });
  }

  Future<void> _loadSuggestions(String query) async {
    final requestId = ++_suggestionRequestId;
    setState(() {
      _isLoadingSuggestions = true;
      _suggestionError = null;
    });

    try {
      final suggestions = await _repository.suggestions(query);
      if (!_isCurrentSuggestionRequest(requestId, query)) return;
      setState(() {
        _filteredSuggestions = suggestions;
        _isLoadingSuggestions = false;
      });
    } catch (_) {
      if (!_isCurrentSuggestionRequest(requestId, query)) return;
      setState(() {
        _suggestionError = context.l10n.searchSuggestionsLoadError;
        _isLoadingSuggestions = false;
      });
    }
  }

  Future<void> _runSearch(String query) async {
    final normalized = query.trim();
    if (normalized.isEmpty) return;

    final requestId = ++_searchRequestId;
    _suggestionRequestId++;
    setState(() {
      _hasSearched = true;
      _isLoadingResults = true;
      _isLoadingSuggestions = false;
      _filteredSuggestions = const [];
      _results = const [];
      _suggestionError = null;
      _searchError = null;
    });

    try {
      final results = await _repository.search(normalized);
      if (!_isCurrentSearchRequest(requestId, normalized)) return;
      setState(() {
        _results = results;
        _isLoadingResults = false;
      });

      try {
        await _engagementRepository.saveSearch(normalized);
        if (!_isCurrentSearchRequest(requestId, normalized)) return;
        final searches = await _engagementRepository.fetchSavedSearches();
        if (!_isCurrentSearchRequest(requestId, normalized)) return;
        setState(() => _recentSearches = searches);
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.genericError)));
      }
    } catch (_) {
      if (!_isCurrentSearchRequest(requestId, normalized)) return;
      setState(() {
        _searchError = context.l10n.searchResultsLoadError;
        _isLoadingResults = false;
      });
    }
  }

  bool _isCurrentSuggestionRequest(int requestId, String query) =>
      mounted &&
      requestId == _suggestionRequestId &&
      _searchController.text.trim().toLowerCase() == query;

  bool _isCurrentSearchRequest(int requestId, String query) =>
      mounted &&
      requestId == _searchRequestId &&
      _searchController.text.trim() == query;

  Future<void> _removeRecentSearch(String searchId) async {
    final previous = _recentSearches;
    setState(() {
      _recentSearches = _recentSearches.where((s) => s.id != searchId).toList();
    });
    try {
      await _engagementRepository.deleteSavedSearch(searchId);
    } catch (error) {
      if (!mounted) return;
      setState(() => _recentSearches = previous);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _clearAllRecentSearches() async {
    final previous = _recentSearches;
    setState(() => _recentSearches = const []);
    try {
      await _engagementRepository.clearSavedSearches();
    } catch (error) {
      if (!mounted) return;
      setState(() => _recentSearches = previous);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    unawaited(_authSubscription?.cancel());
    _searchController.removeListener(_onQueryChanged);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchHeader(),
            Expanded(
              child: _isSearching
                  ? _buildSuggestionsList()
                  : _buildRecentSearchesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(20.r),
            onTap: context.goBack,
            child: Padding(
              padding: EdgeInsets.all(6.w),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18.sp,
              ),
            ),
          ),
          10.width,
          Expanded(
            child: SizedBox(
              height: 40.h,
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                autofocus: true,
                style: AppTextStyle.primaryText.copyWith(
                  color: Colors.white,
                  fontSize: 14.sp,
                ),
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SvgPicture.asset(
                      'assets/icons/search.svg',
                      colorFilter: const ColorFilter.mode(
                        AppColor.tertiaryTextColor,
                        BlendMode.srcIn,
                      ),
                      width: 20.w,
                      height: 20.h,
                    ),
                  ),
                  suffixIcon: _isSearching
                      ? InkWell(
                          onTap: () => _searchController.clear(),
                          child: Icon(
                            Icons.close,
                            color: AppColor.tertiaryTextColor,
                            size: 18.sp,
                          ),
                        )
                      : null,
                  hintText: context.l10n.searchProduct,
                  hintStyle: AppTextStyle.primaryText.copyWith(
                    color: AppColor.tertiaryTextColor,
                    fontSize: 14.sp,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.r),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColor.bgSurfaceColor,
                ),
                onSubmitted: _runSearch,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearchesList() {
    if (_isLoadingRecentSearches) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_recentSearchError != null) {
      return _buildRetryState(
        _recentSearchError.toString(),
        _loadRecentSearches,
      );
    }
    if (_recentSearches.isEmpty) {
      return Center(
        child: Text(
          context.l10n.searchHistoryEmpty,
          style: AppTextStyle.primaryText.copyWith(
            color: AppColor.tertiaryTextColor,
            fontSize: 14.sp,
          ),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      children: [
        8.height,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.recentSearches,
              style: AppTextStyle.primaryText.copyWith(
                color: Colors.white,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            InkWell(
              onTap: _clearAllRecentSearches,
              child: Text(
                context.l10n.clear,
                style: AppTextStyle.primaryText.copyWith(
                  color: Colors.redAccent,
                  fontSize: 13.sp,
                ),
              ),
            ),
          ],
        ),
        8.height,
        ...List.generate(_recentSearches.length, (index) {
          final item = _recentSearches[index];
          return _buildRecentSearchTile(item);
        }),
      ],
    );
  }

  Widget _buildRecentSearchTile(SavedSearch item) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                // Suppress the query listener while we set the text
                // programmatically, so recent searches don't flash away
                // before _runSearch takes over the UI.
                _suppressQueryListener = true;
                _searchController.text = item.query;
                _suppressQueryListener = false;
                _runSearch(item.query);
              },
              child: Text(
                item.query,
                style: AppTextStyle.primaryText.copyWith(
                  color: Colors.white,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(16.r),
            onTap: () => _removeRecentSearch(item.id),
            child: Padding(
              padding: EdgeInsets.all(6.w),
              child: Icon(
                Icons.close,
                color: AppColor.tertiaryTextColor,
                size: 16.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsList() {
    if (_isLoadingResults) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_searchError != null) {
      return _buildRetryState(
        _searchError!,
        () => _runSearch(_searchController.text),
      );
    }
    if (_hasSearched && _results.isEmpty) {
      return _buildEmptyState(context.l10n.searchNoResults);
    }
    if (_hasSearched && _results.isNotEmpty) {
      return GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 0.62,
        ),
        itemCount: _results.length,
        itemBuilder: (context, index) {
          final item = _results[index];
          return ProductCard(product: item);
        },
      );
    }
    if (_isLoadingSuggestions) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_suggestionError != null) {
      return _buildRetryState(
        _suggestionError!,
        () => _loadSuggestions(_searchController.text.trim().toLowerCase()),
      );
    }
    if (_filteredSuggestions.isEmpty) {
      return _buildEmptyState(context.l10n.searchNoSuggestions);
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: _filteredSuggestions.length,
      itemBuilder: (context, index) {
        final suggestion = _filteredSuggestions[index];
        return InkWell(
          onTap: () {
            _searchController
              ..text = suggestion.title
              ..selection = TextSelection.collapsed(
                offset: suggestion.title.length,
              );
            _runSearch(suggestion.title);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        suggestion.title,
                        style: AppTextStyle.primaryText.copyWith(
                          color: Colors.white,
                          fontSize: 14.sp,
                        ),
                      ),
                      2.height,
                      Text(
                        suggestion.isAllCategories
                            ? context.l10n.allCategories
                            : suggestion.subtitle,
                        style: AppTextStyle.primaryText.copyWith(
                          color: AppColor.tertiaryTextColor,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColor.tertiaryTextColor,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRetryState(String message, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyle.primaryText.copyWith(
              color: AppColor.tertiaryTextColor,
              fontSize: 14.sp,
            ),
          ),
          12.height,
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(context.l10n.retryAgain),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: AppTextStyle.primaryText.copyWith(
          color: AppColor.tertiaryTextColor,
          fontSize: 14.sp,
        ),
      ),
    );
  }
}
