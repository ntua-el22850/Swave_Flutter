import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/models.dart';
import '../services/mock_data_service.dart';
import '../routes/app_routes.dart';

class InlineSearchResults extends StatefulWidget {
  final String query;
  final SearchType searchType;
  final List<String> initialCategories;

  const InlineSearchResults({
    super.key,
    required this.query,
    this.searchType = SearchType.all,
    this.initialCategories = const [],
  });

  @override
  State<InlineSearchResults> createState() => _InlineSearchResultsState();
}

class _InlineSearchResultsState extends State<InlineSearchResults> {
  final MockDataService _dataService = MockDataService();
  List<String> _selectedCategories = [];
  List<dynamic> _searchResults = [];
  List<String> _availableCategories = [];

  @override
  void initState() {
    super.initState();
    _selectedCategories = List.from(widget.initialCategories);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _updateAvailableCategories();
    await _performSearch();
  }

  @override
  void didUpdateWidget(InlineSearchResults oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      _performSearch();
    }
  }

  Future<void> _updateAvailableCategories() async {
    List<String> categories;
    if (widget.searchType == SearchType.clubs) {
      categories = await _dataService.getAllClubCategories();
    } else if (widget.searchType == SearchType.events) {
      categories = await _dataService.getAllEventCategories();
    } else {
      categories = await _dataService.getAllCategories();
    }
    setState(() {
      _availableCategories = categories;
    });
  }

  Future<void> _performSearch() async {
    final results = await _dataService.searchClubsAndEvents(
      query: widget.query,
      searchType: widget.searchType,
      categories: _selectedCategories,
    );
    setState(() {
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.query.isEmpty && _selectedCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCategoryFilters(),
          if (_searchResults.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'No results found',
                style: TextStyle(color: Colors.white54),
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(8),
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final item = _searchResults[index];
                  if (item is Club) {
                    return _buildClubResultItem(item);
                  } else if (item is Event) {
                    return _buildEventResultItem(item);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: _availableCategories.length,
        itemBuilder: (context, index) {
          final category = _availableCategories[index];
          final isSelected = _selectedCategories.contains(category);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: FilterChip(
              label: Text(
                category,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.white : Colors.white70,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedCategories.add(category);
                  } else {
                    _selectedCategories.remove(category);
                  }
                  _performSearch();
                });
              },
              backgroundColor: Colors.white.withOpacity(0.05),
              selectedColor: Colors.purple.shade700,
              checkmarkColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          );
        },
      ),
    );
  }

  Widget _buildClubResultItem(Club club) {
    return ListTile(
      onTap: () => Get.toNamed(AppRoutes.clubDetailPath(club.id), arguments: club),
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: NetworkImage(club.imageUrl),
            fit: BoxFit.cover,
          ),
        ),
      ),
      title: Text(
        club.name,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '${club.category} \u2022 ${club.location}',
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 14),
          const SizedBox(width: 4),
          Text(
            club.rating.toString(),
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildEventResultItem(Event event) {
    return ListTile(
      onTap: () =>
          Get.toNamed(AppRoutes.eventDetailPath(event.id), arguments: event),
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: NetworkImage(event.imageUrl),
            fit: BoxFit.cover,
          ),
        ),
      ),
      title: Text(
        event.name,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: FutureBuilder<Club?>(
        future: _dataService.getClubById(event.clubId),
        builder: (context, snapshot) {
          final clubName = snapshot.data?.name ?? 'Loading...';
          return Text(
            '$clubName \u2022 ${event.date}',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          );
        },
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '\$${event.price.toInt()}',
          style: const TextStyle(color: Colors.purpleAccent, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
