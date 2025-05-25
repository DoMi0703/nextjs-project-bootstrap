import 'package:flutter/material.dart';
import 'package:eventease/theme/app_theme.dart';
import 'package:eventease/utils/helpers.dart';
import 'package:eventease/widgets/custom_button.dart';

class CustomCalendar extends StatefulWidget {
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime>? onDateSelected;
  final List<DateTime>? markedDates;
  final Map<DateTime, List<CalendarEvent>>? events;
  final CalendarStyle style;
  final bool showWeekDays;
  final bool showMonthName;
  final bool allowPastDates;
  final bool animated;
  final Widget Function(CalendarEvent event)? eventBuilder;

  const CustomCalendar({
    super.key,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.onDateSelected,
    this.markedDates,
    this.events,
    this.style = CalendarStyle.month,
    this.showWeekDays = true,
    this.showMonthName = true,
    this.allowPastDates = true,
    this.animated = true,
    this.eventBuilder,
  });

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  late DateTime _currentMonth;
  late DateTime _selectedDate;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _currentMonth = DateTime(_selectedDate.year, _selectedDate.month);
    _pageController = PageController(
      initialPage: _getPageIndex(_currentMonth),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int _getPageIndex(DateTime date) {
    final firstDate = widget.firstDate ?? DateTime(1900);
    return (date.year - firstDate.year) * 12 + date.month - firstDate.month;
  }

  DateTime _getDateFromPageIndex(int index) {
    final firstDate = widget.firstDate ?? DateTime(1900);
    return DateTime(
      firstDate.year + index ~/ 12,
      firstDate.month + index % 12,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentMonth = _getDateFromPageIndex(index);
    });
  }

  void _onDateTap(DateTime date) {
    setState(() => _selectedDate = date);
    widget.onDateSelected?.call(date);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        if (widget.showWeekDays) _buildWeekDays(),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              final month = _getDateFromPageIndex(index);
              return _buildMonth(month);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
          Text(
            widget.showMonthName
                ? Helpers.formatDate(_currentMonth, format: 'MMMM y')
                : Helpers.formatDate(_currentMonth, format: 'MM/y'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDays() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          Text('S', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('M', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('T', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('W', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('T', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('F', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('S', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMonth(DateTime month) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;
    final prevMonthDays = (firstWeekday + 6) % 7;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: 42,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final day = index - prevMonthDays + 1;
        if (day < 1 || day > daysInMonth) {
          return const SizedBox.shrink();
        }

        final date = DateTime(month.year, month.month, day);
        final isSelected = _selectedDate.year == date.year &&
            _selectedDate.month == date.month &&
            _selectedDate.day == date.day;
        final isToday = DateTime.now().year == date.year &&
            DateTime.now().month == date.month &&
            DateTime.now().day == date.day;
        final isMarked = widget.markedDates?.contains(date) ?? false;
        final events = widget.events?[date] ?? [];

        return _CalendarDay(
          date: date,
          isSelected: isSelected,
          isToday: isToday,
          isMarked: isMarked,
          events: events,
          onTap: _onDateTap,
          eventBuilder: widget.eventBuilder,
          animated: widget.animated,
        );
      },
    );
  }
}

class _CalendarDay extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final bool isMarked;
  final List<CalendarEvent> events;
  final ValueChanged<DateTime> onTap;
  final Widget Function(CalendarEvent event)? eventBuilder;
  final bool animated;

  const _CalendarDay({
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.isMarked,
    required this.events,
    required this.onTap,
    this.eventBuilder,
    required this.animated,
  });

  @override
  Widget build(BuildContext context) {
    Widget day = InkWell(
      onTap: () => onTap(date),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor
              : isToday
                  ? AppTheme.primaryColor.withOpacity(0.1)
                  : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                date.day.toString(),
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : isToday
                          ? AppTheme.primaryColor
                          : Colors.black87,
                  fontWeight:
                      isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isMarked)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            if (events.isNotEmpty)
              Positioned(
                bottom: 4,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: events
                      .take(3)
                      .map(
                        (event) => Container(
                          width: 4,
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: event.color ?? AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );

    if (animated) {
      day = AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isSelected ? 1 : 0.8,
        child: day,
      );
    }

    return day;
  }
}

enum CalendarStyle {
  month,
  week,
  day,
}

class CalendarEvent {
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final Color? color;

  const CalendarEvent({
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    this.color,
  });
}
