import 'package:flutter/material.dart';
import 'package:humble/provider/user_providers.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class ReadyToWorkCalendarScreen extends StatefulWidget {
  const ReadyToWorkCalendarScreen({Key? key}) : super(key: key);

  @override
  _ReadyToWorkCalendarScreenState createState() =>
      _ReadyToWorkCalendarScreenState();
}

class _ReadyToWorkCalendarScreenState extends State<ReadyToWorkCalendarScreen> {
  late final ValueNotifier<Set<DateTime>> _selectedDates;
  late final ValueNotifier<Set<DateTime>> _originalDates;
  DateTime _focusedMonth = DateTime.now();
  bool _isLoading = false;
  bool _hasChanges = false;
  final DateTime _today = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedDates = ValueNotifier<Set<DateTime>>({});
    _originalDates = ValueNotifier<Set<DateTime>>({});

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchReadyToWorkDates();
    });
  }

  void _resetChanges() {
    setState(() {
      _selectedDates.value = Set.from(_originalDates.value);
      _hasChanges = false;
    });
    _showSnackBar('Changes reset');
  }

  Future<void> _fetchReadyToWorkDates() async {
    if (!mounted) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final provider = Provider.of<UserProvider>(context, listen: false);
      await provider.fetchReadyToWorkData();

      if (provider.readyToWorkDates.isNotEmpty) {
        final dates = <DateTime>{};

        for (var dateStr in provider.readyToWorkDates) {
          try {
            final date = DateFormat('yyyy-MM-dd').parse(dateStr);
            // Normalize to midnight to ensure proper comparison
            final normalized = DateTime(date.year, date.month, date.day);

            // Only add dates that are today or in the future
            final normalizedToday =
                DateTime(_today.year, _today.month, _today.day);
            if (!normalized.isBefore(normalizedToday)) {
              dates.add(normalized);
            }
          } catch (e) {
            debugPrint('Error parsing date: $dateStr - $e');
          }
        }

        setState(() {
          _selectedDates.value = dates;
          _originalDates.value = Set.from(dates);
          _hasChanges = false;
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to fetch availability dates: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool isPastDay(DateTime date) {
    final normalizedToday = DateTime(_today.year, _today.month, _today.day);
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return normalizedDate.isBefore(normalizedToday);
  }

  void _checkForChanges() {
    final originalSet = Set.from(_originalDates.value);
    final selectedSet = Set.from(_selectedDates.value);
    final hasChanges = !originalSet.containsAll(selectedSet) ||
        !selectedSet.containsAll(originalSet);
    setState(() {
      _hasChanges = hasChanges;
    });
  }

  void _toggleDate(DateTime date) {
    // Don't allow toggling past dates
    if (isPastDay(date)) return;

    final normalizedDate = DateTime(date.year, date.month, date.day);
    final newSelectedDates = Set<DateTime>.from(_selectedDates.value);

    if (newSelectedDates.any((d) => isSameDay(d, normalizedDate))) {
      newSelectedDates.removeWhere((d) => isSameDay(d, normalizedDate));
    } else {
      newSelectedDates.add(normalizedDate);
    }

    _selectedDates.value = newSelectedDates;
    _checkForChanges();
  }

  void _selectMonth(DateTime month, bool selectAll) {
    final lastDay = DateTime(month.year, month.month + 1, 0).day;
    final newSelectedDates = Set<DateTime>.from(_selectedDates.value);
    final normalizedToday = DateTime(_today.year, _today.month, _today.day);

    // First remove all days from this month
    newSelectedDates.removeWhere(
        (date) => date.year == month.year && date.month == month.month);

    // Then add all days if selectAll is true (only future days)
    if (selectAll) {
      for (int day = 1; day <= lastDay; day++) {
        final date = DateTime(month.year, month.month, day);
        if (!date.isBefore(normalizedToday)) {
          newSelectedDates.add(date);
        }
      }
    }

    _selectedDates.value = newSelectedDates;
    _checkForChanges();
  }

  void _goToCurrentMonth() {
    setState(() {
      _focusedMonth = DateTime.now();
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.montserrat(),
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _selectedDates.dispose();
    _originalDates.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: userProvider.isLoading && _selectedDates.value.isEmpty
            ? Center(child: CircularProgressIndicator(color: Colors.blue))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: Text(
                      'Ready to Work Calendar',
                      style: GoogleFonts.montserrat(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  // Location Center Container
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_month_sharp,
                                color: const Color(0xFF2196F3),
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Select your available dates',
                                style: GoogleFonts.montserrat(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tap on the dates to select or deselect them.',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildMonthNavigator(),
                  Expanded(
                    child: _buildCalendar(),
                  ),
                  _buildActionButtons(userProvider), // Use the new method here
                ],
              ),
      ),
    );
  }

  Widget _buildMonthNavigator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _focusedMonth =
                    DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
              });
            },
          ),
          Column(
            children: [
              Text(
                DateFormat('MMMM yyyy').format(_focusedMonth),
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: _goToCurrentMonth,
                child: Text(
                  'Go to Current Month',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _focusedMonth =
                    DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                .map((day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          // Calendar grid
          Expanded(
            child: ValueListenableBuilder<Set<DateTime>>(
              valueListenable: _selectedDates,
              builder: (context, selectedDates, _) {
                return _buildCalendarGrid(_focusedMonth, selectedDates);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(DateTime month, Set<DateTime> selectedDates) {
    // First day of month
    final firstDay = DateTime(month.year, month.month, 1);

    // Calculate first day to display (previous month days to complete the week)
    final firstDisplayDay =
        firstDay.subtract(Duration(days: (firstDay.weekday - 1) % 7));

    // Last day of month
    final lastDay = DateTime(month.year, month.month + 1, 0);

    // Calculate number of weeks to display
    final daysToShow = firstDay.weekday - 1 + lastDay.day;
    final weeksToShow = (daysToShow / 7).ceil();

    // Today normalized to midnight for comparison
    final normalizedToday = DateTime(_today.year, _today.month, _today.day);

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
      ),
      itemCount: weeksToShow * 7,
      itemBuilder: (context, index) {
        final date = firstDisplayDay.add(Duration(days: index));
        final isCurrentMonth = date.month == month.month;
        final isSelected = selectedDates.any((d) => isSameDay(d, date));
        final isToday = isSameDay(date, _today);
        final isPast = date.isBefore(normalizedToday);

        // Check for adjacent selected dates to create pill effect
        final prevDate = date.subtract(const Duration(days: 1));
        final nextDate = date.add(const Duration(days: 1));
        final isPrevSelected = selectedDates.any((d) => isSameDay(d, prevDate));
        final isNextSelected = selectedDates.any((d) => isSameDay(d, nextDate));

        // Only consider connections within the same week and month
        final isConnectedToPrev = isPrevSelected &&
            prevDate.weekday < date.weekday &&
            isCurrentMonth &&
            prevDate.month == date.month;
        final isConnectedToNext = isNextSelected &&
            nextDate.weekday > date.weekday &&
            isCurrentMonth &&
            nextDate.month == date.month;

        // Determine border radius based on connections
        BorderRadius borderRadius = BorderRadius.circular(isSelected ? 0 : 8);
        if (isSelected) {
          if (isConnectedToPrev && isConnectedToNext) {
            borderRadius = BorderRadius.zero;
          } else if (isConnectedToPrev) {
            borderRadius = const BorderRadius.only(
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            );
          } else if (isConnectedToNext) {
            borderRadius = const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            );
          } else {
            borderRadius =
                BorderRadius.circular(12); // Pill shape when standalone
          }
        }

        return GestureDetector(
          onTap: (isCurrentMonth && !isPast) ? () => _toggleDate(date) : null,
          child: Container(
            margin: EdgeInsets.all(isSelected ? 0 : 2),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blue
                  : isToday
                      ? Colors.blue.withOpacity(0.1)
                      : null,
              borderRadius: borderRadius,
              border: isToday && !isSelected
                  ? Border.all(color: Colors.blue)
                  : null,
            ),
            child: Center(
              child: Text(
                date.day.toString(),
                style: GoogleFonts.montserrat(
                  color: !isCurrentMonth
                      ? Colors.grey.withOpacity(0.3)
                      : isPast
                          ? Colors.grey.withOpacity(0.5)
                          : isSelected
                              ? Colors.white
                              : null,
                  fontWeight: isSelected || isToday ? FontWeight.bold : null,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(UserProvider userProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Clear button - only show when changes exist
          if (_hasChanges)
            Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            child: TextButton(
              onPressed: (_isLoading || userProvider.isLoading)
                  ? null
                  : _resetChanges,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                foregroundColor: Colors.blue,
              ),
              child: Text(
                'Clear changes',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          // Save button
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (!_hasChanges || _isLoading || userProvider.isLoading)
                  ? null
                  : _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: _isLoading || userProvider.isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : Text(
                      _hasChanges ? 'Save changes' : 'No changes to save',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<UserProvider>(context, listen: false);

      // Convert selected dates to string format
      final selectedDatesStr = _selectedDates.value
          .map((date) => DateFormat('yyyy-MM-dd').format(date))
          .toList();

      // Get existing dates from provider
      final existingDatesStr = provider.readyToWorkDates;

      // Calculate dates to add and remove
      final datesToRemove = existingDatesStr
          .where((dateStr) => !selectedDatesStr.contains(dateStr))
          .toList();

      final datesToAdd = selectedDatesStr
          .where((dateStr) => !existingDatesStr.contains(dateStr))
          .toList();

      // Apply changes
      bool hasChangesApplied = false;

      if (datesToRemove.isNotEmpty) {
        await provider.editReadyToWorkDates(datesToRemove);
        hasChangesApplied = true;
      }

      if (datesToAdd.isNotEmpty) {
        await provider.readyToWorkProvider(datesToAdd);
        hasChangesApplied = true;
      }

      if (hasChangesApplied) {
        // Refresh data
        await provider.fetchReadyToWorkData();

        // Update local state
        _originalDates.value = Set.from(_selectedDates.value);
        setState(() {
          _hasChanges = false;
        });

        _showSnackBar('Availability updated successfully!');
      }
    } catch (e) {
      _showSnackBar('Failed to update: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
