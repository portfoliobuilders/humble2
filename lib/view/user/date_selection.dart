import 'package:flutter/material.dart';
import 'package:humble/provider/user_providers.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ReadyToWorkCalendarScreen extends StatefulWidget {
  const ReadyToWorkCalendarScreen({Key? key}) : super(key: key);

  @override
  _ReadyToWorkCalendarScreenState createState() =>
      _ReadyToWorkCalendarScreenState();
}

class _ReadyToWorkCalendarScreenState extends State<ReadyToWorkCalendarScreen> {
  late final ValueNotifier<List<DateTime>> _selectedDates;
  late final ValueNotifier<List<DateTime>> _originalDates;
  DateTime _focusedDay = DateTime.now();
  bool _isLoading = false;
  bool _hasChanges = false;
  final List<DateTime> _months = [];
  late ScrollController _scrollController;
  late int _initialScrollIndex;
  final GlobalKey _currentMonthKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _selectedDates = ValueNotifier<List<DateTime>>([]);
    _originalDates = ValueNotifier<List<DateTime>>([]);
    _scrollController = ScrollController();

    final now = DateTime.now();
    for (int i = -12; i <= 24; i++) {
      _months.add(DateTime(now.year, now.month + i, 1));
    }

    _initialScrollIndex = _months.indexWhere(
        (month) => month.year == now.year && month.month == now.month);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchReadyToWorkDates();
      // Delay scrolling to ensure the ListView is properly rendered
      Future.delayed(const Duration(milliseconds: 200), _scrollToCurrentMonth);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This will help when returning to this screen from navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentMonth();
    });
  }

  void _scrollToCurrentMonth() {
    if (!_scrollController.hasClients) {
      // If controller isn't attached yet, retry after a short delay
      Future.delayed(const Duration(milliseconds: 100), _scrollToCurrentMonth);
      return;
    }

    // Use more precise calculation for item height
    final monthHeight = MediaQuery.of(context).size.height * 0.45;
    
    if (_initialScrollIndex >= 0) {
      // Calculate offset considering all previous months
      final offset = _initialScrollIndex * monthHeight;
      
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _fetchReadyToWorkDates() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final provider = Provider.of<UserProvider>(context, listen: false);
      await provider.fetchReadyToWorkData();

      if (provider.readyToWorkDates.isNotEmpty) {
        final uniqueDates = <DateTime>{};

        for (var dateStr in provider.readyToWorkDates) {
          final date = DateFormat('yyyy-MM-dd').parse(dateStr);
          if (!uniqueDates.any((d) => isSameDay(d, date))) {
            uniqueDates.add(date);
          }
        }

        setState(() {
          _selectedDates.value = uniqueDates.toList();
          _originalDates.value = List.from(uniqueDates.toList());
          _hasChanges = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch availability dates: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _checkForChanges() {
    if (_originalDates.value.length != _selectedDates.value.length) {
      setState(() {
        _hasChanges = true;
      });
      return;
    }

    for (var date in _selectedDates.value) {
      if (!_originalDates.value.any((d) => isSameDay(d, date))) {
        setState(() {
          _hasChanges = true;
        });
        return;
      }
    }

    for (var date in _originalDates.value) {
      if (!_selectedDates.value.any((d) => isSameDay(d, date))) {
        setState(() {
          _hasChanges = true;
        });
        return;
      }
    }

    setState(() {
      _hasChanges = false;
    });
  }

  @override
  void dispose() {
    _selectedDates.dispose();
    _originalDates.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final bool isFetching = userProvider.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              pinned: true,
              floating: true,
              elevation: 0,
              backgroundColor: Colors.white,
              expandedHeight: 80,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: const Text(
                  'Select Availability',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              actions: [
                // Add a "Today" button to quickly jump to current month
                TextButton(
                  onPressed: _scrollToCurrentMonth,
                  child: const Text(
                    'Today',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ];
        },
        body: isFetching && _selectedDates.value.isEmpty
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildMonthsCalendar(),
                  ),
                  _buildSaveButton(userProvider),
                ],
              ),
      ),
    );
  }

  Widget _buildMonthsCalendar() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _months.length,
      padding: const EdgeInsets.only(bottom: 16),
      itemBuilder: (context, index) {
        final month = _months[index];
        // Highlight current month
        final isCurrentMonth = month.year == DateTime.now().year &&
            month.month == DateTime.now().month;

        return _buildMonthCalendar(month, isCurrentMonth, index);
      },
    );
  }

  Widget _buildMonthCalendar(DateTime month, bool isCurrentMonth, int index) {
    // Use a key for the current month to help with scrolling
    final key = isCurrentMonth ? _currentMonthKey : null;
    
    return Container(
      key: key,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        border: isCurrentMonth
            ? Border.all(color: Colors.blue.shade50, width: 2)
            : Border.all(color: Colors.grey.shade300, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(month),
                  style: TextStyle(
                    fontSize: 20,
                    color: isCurrentMonth ? Colors.blue : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isCurrentMonth)
                  const Icon(
                    Icons.circle,
                    size: 10,
                    color: Colors.blue,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: _buildCalendarGrid(month),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(DateTime month) {
    // Get the first day of the month
    final firstDayOfMonth = DateTime(month.year, month.month, 1);

    // Get the last day of the month
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);

    // Get the first day of the calendar grid (showing days from previous month)
    final firstCalendarDay = firstDayOfMonth.subtract(
      Duration(days: (firstDayOfMonth.weekday - DateTime.monday) % 7),
    );

    // Calculate number of weeks needed
    final daysInMonth = lastDayOfMonth.day;
    final startOffset = (firstDayOfMonth.weekday - DateTime.monday) % 7;
    final weeksNeeded = ((daysInMonth + startOffset) / 7).ceil();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Weekday header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            _WeekdayLabel("M"),
            _WeekdayLabel("T"),
            _WeekdayLabel("W"),
            _WeekdayLabel("T"),
            _WeekdayLabel("F"),
            _WeekdayLabel("S"),
            _WeekdayLabel("S"),
          ],
        ),

        for (int weekIndex = 0; weekIndex < weeksNeeded; weekIndex++)
          ValueListenableBuilder<List<DateTime>>(
            valueListenable: _selectedDates,
            builder: (context, selectedDates, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(7, (dayIndex) {
                  final date = firstCalendarDay.add(
                    Duration(days: weekIndex * 7 + dayIndex),
                  );

                  final belongsToCurrentMonth = date.month == month.month;

                  final isSelected =
                      selectedDates.any((d) => isSameDay(d, date));

                  final prevDaySelected = selectedDates.any(
                    (d) => isSameDay(d, date.subtract(const Duration(days: 1))),
                  );
                  final nextDaySelected = selectedDates.any(
                    (d) => isSameDay(d, date.add(const Duration(days: 1))),
                  );

                  final isToday = isSameDay(date, DateTime.now());

                  return _CalendarDay(
                    date: date,
                    isCurrentMonth: belongsToCurrentMonth,
                    isSelected: isSelected,
                    isPrevDaySelected: prevDaySelected,
                    isNextDaySelected: nextDaySelected,
                    isToday: isToday,
                    onTap: () {
                      if (belongsToCurrentMonth) {
                        final updatedSelectedDates =
                            List<DateTime>.from(selectedDates);
                        if (isSelected) {
                          updatedSelectedDates
                              .removeWhere((d) => isSameDay(d, date));
                        } else {
                          updatedSelectedDates.add(date);
                        }
                        _selectedDates.value = updatedSelectedDates;
                        _checkForChanges();
                      }
                    },
                  );
                }),
              );
            },
          ),
      ],
    );
  }

  Widget _buildSaveButton(UserProvider userProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: (!_hasChanges || _isLoading || userProvider.isLoading)
              ? null
              : () async {
                  setState(() {
                    _isLoading = true;
                  });

                  try {
                    final provider =
                        Provider.of<UserProvider>(context, listen: false);

                    final existingDatesStr = provider.readyToWorkDates;

                    final selectedDatesStr = _selectedDates.value
                        .map((date) => DateFormat('yyyy-MM-dd').format(date))
                        .toSet() 
                        .toList();

                    final datesToRemove = existingDatesStr
                        .where((dateStr) => !selectedDatesStr.contains(dateStr))
                        .toList();

                    final datesToAdd = selectedDatesStr
                        .where((dateStr) => !existingDatesStr.contains(dateStr))
                        .toList();

                    if (datesToRemove.isNotEmpty) {
                      await provider.editReadyToWorkDates(datesToRemove);
                    }

                    if (datesToAdd.isNotEmpty) {
                      await provider.readyToWorkProvider(datesToAdd);
                    }

                    await provider.fetchReadyToWorkData();

                    _originalDates.value = List.from(_selectedDates.value);
                    setState(() {
                      _hasChanges = false;
                    });

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Availability updated successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to update: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } finally {
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.blue.withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: _isLoading || userProvider.isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  _hasChanges ? 'Save changes' : 'No changes to save',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ),
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  final String text;

  const _WeekdayLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.blue[600],
        ),
      ),
    );
  }
}

class _CalendarDay extends StatelessWidget {
  final DateTime date;
  final bool isCurrentMonth;
  final bool isSelected;
  final bool isPrevDaySelected;
  final bool isNextDaySelected;
  final bool isToday;
  final VoidCallback onTap;

  const _CalendarDay({
    required this.date,
    required this.isCurrentMonth,
    required this.isSelected,
    required this.isPrevDaySelected,
    required this.isNextDaySelected,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isCurrentMonth
        ? isSelected
            ? Colors.white 
            : isToday
                ? Colors.blue
                : Colors.black
        : Colors.grey[400];

    return GestureDetector(
      onTap: isCurrentMonth ? onTap : null,
      child: Row(
        children: [
          Container(
            width: 51,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blue
                  : isToday
                      ? Colors.blue.withOpacity(0.1)
                      : Colors.transparent,

              borderRadius: isSelected
                  ? BorderRadius.horizontal(
                      left: isPrevDaySelected
                          ? Radius.zero
                          : const Radius.circular(8),
                      right: isNextDaySelected
                          ? Radius.zero
                          : const Radius.circular(8),
                    )
                  : isToday
                      ? BorderRadius.circular(8)
                      : null,

              boxShadow: isSelected && (isPrevDaySelected || isNextDaySelected)
                  ? [
                      BoxShadow(
                        color: Colors.blue,
                        spreadRadius: 0,
                        blurRadius: 0,
                        offset: Offset(
                          isPrevDaySelected ? -0.5 : 0,
                          0,
                        ),
                      ),
                      BoxShadow(
                        color: Colors.blue,
                        spreadRadius: 0,
                        blurRadius: 0,
                        offset: Offset(
                          isNextDaySelected ? 0.5 : 0,
                          0,
                        ),
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              date.day.toString(),
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight:
                    isSelected || isToday ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}