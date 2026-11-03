import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../models/habit.dart';
import '../../providers/habit_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/habit_card.dart';
import 'add_habit_screen.dart';
import 'habit_detail_screen.dart';

class HabitsScreen extends StatefulWidget {
  final HabitProvider habitProvider;

  const HabitsScreen({super.key, required this.habitProvider});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Habit> _filterHabits(List<Habit> source) {
    return source.where((h) {
      final matchesCat =
          _selectedCategory == 'All' || h.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          h.name.toLowerCase().contains(_searchQuery) ||
          h.description.toLowerCase().contains(_searchQuery);
      return matchesCat && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final todayStr = DateUtilsCustom.toDateString(DateTime.now());
    final activeList = _filterHabits(widget.habitProvider.activeHabits);
    final archivedList = _filterHabits(widget.habitProvider.archivedHabits);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Manage Habits'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: AppTheme.primaryColor,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          tabs: [
            Tab(text: 'Active (${widget.habitProvider.activeHabits.length})'),
            Tab(text: 'Archived (${widget.habitProvider.archivedHabits.length})'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Habit', style: TextStyle(fontWeight: FontWeight.w700)),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddEditHabitScreen(
                habitProvider: widget.habitProvider,
              ),
            ),
          );
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar & Category Filter
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search habits...',
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                ),
              ),
            ),

            // Horizontal Category Filter Pills
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildCategoryChip('All'),
                  ...AppConstants.categories.map((c) => _buildCategoryChip(c)),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Tab Views for Active and Archived
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Active habits
                  _buildHabitList(activeList, todayStr, isArchivedView: false),
                  // Archived habits
                  _buildHabitList(archivedList, todayStr, isArchivedView: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(category),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = category;
          });
        },
        selectedColor: AppTheme.primaryLight,
        checkmarkColor: AppTheme.primaryColor,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryColor : const Color(0xFF475569),
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 13,
        ),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryColor : const Color(0xFFE2E8F0),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildHabitList(List<Habit> habits, String todayStr,
      {required bool isArchivedView}) {
    if (habits.isEmpty) {
      return EmptyStateWidget(
        icon: isArchivedView
            ? Icons.archive_outlined
            : Icons.playlist_add_check_circle_outlined,
        title: isArchivedView ? 'No Archived Habits' : 'No Habits Found',
        subtitle: isArchivedView
            ? 'Completed habits you choose to archive will appear here.'
            : 'Start small and build momentum by creating your first daily routine.',
        actionLabel: isArchivedView ? null : 'Create Habit',
        onAction: isArchivedView
            ? null
            : () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddEditHabitScreen(
                      habitProvider: widget.habitProvider,
                    ),
                  ),
                );
              },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: habits.length,
      itemBuilder: (context, index) {
        final habit = habits[index];
        final isCompleted =
            widget.habitProvider.isHabitCompleted(habit.id, todayStr);
        final streak =
            widget.habitProvider.calculateCurrentStreak(habit.id);

        return HabitCard(
          habit: habit,
          isCompleted: isCompleted,
          currentStreak: streak,
          onToggle: () async {
            final scaffoldMessenger = ScaffoldMessenger.of(context);
            final nowComplete =
                await widget.habitProvider.toggleCompletion(habit.id);
            if (!mounted) return;
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text(
                  nowComplete
                      ? 'Marked "${habit.name}" as completed! 🔥'
                      : 'Unmarked "${habit.name}".',
                ),
                duration: const Duration(seconds: 1),
                backgroundColor:
                    nowComplete ? AppTheme.accentColor : const Color(0xFF64748B),
              ),
            );
          },
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => HabitDetailScreen(
                  habit: habit,
                  habitProvider: widget.habitProvider,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
