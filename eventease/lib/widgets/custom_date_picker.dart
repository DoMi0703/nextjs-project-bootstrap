import 'package:flutter/material.dart';
import 'package:eventease/theme/app_theme.dart';
import 'package:eventease/utils/helpers.dart';
import 'package:eventease/widgets/custom_button.dart';

class CustomDatePicker extends StatefulWidget {
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime>? onDateSelected;
  final String? label;
  final String? hint;
  final bool showWeekDays;
  final bool showMonthName;
  final bool allowPastDates;
  final bool showSelectedDateButton;
  final DatePickerMode initialDatePickerMode;

  const CustomDatePicker({
    super.key,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.onDateSelected,
    this.label,
    this.hint,
    this.showWeekDays = true,
    this.showMonthName = true,
    this.allowPastDates = false,
    this.showSelectedDateButton = true,
    this.initialDatePickerMode = DatePickerMode.day,
  });

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  late DateTime _selectedDate;
  late DateTime _firstDate;
  late DateTime _lastDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _firstDate = widget.firstDate ??
        (widget.allowPastDates
            ? DateTime(1900)
            : DateTime.now().subtract(const Duration(days: 1)));
    _lastDate = widget.lastDate ?? DateTime(2100);
  }

  Future<void> _showDatePicker() async {
    final pickedDate = await showDialog<DateTime>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: CalendarDatePicker2(
          initialDate: _selectedDate,
          firstDate: _firstDate,
          lastDate: _lastDate,
          onDateSelected: (date) {
            Navigator.of(context).pop(date);
          },
          showWeekDays: widget.showWeekDays,
          showMonthName: widget.showMonthName,
        ),
      ),
    );

    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
      widget.onDateSelected?.call(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        InkWell(
          onTap: _showDatePicker,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  Helpers.formatDate(_selectedDate, format: 'MMMM d, y'),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CalendarDatePicker2 extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime>? onDateSelected;
  final bool showWeekDays;
  final bool showMonthName;

  const CalendarDatePicker2({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.onDateSelected,
    this.showWeekDays = true,
    this.showMonthName = true,
  });

  @override
  State<CalendarDatePicker2> createState() => _CalendarDatePicker2State();
}

class _CalendarDatePicker2State extends State<CalendarDatePicker2> {
  late DateTime _currentMonth;
  late DateTime _selectedDate;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
    _selectedDate = widget.initialDate;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool _isSelectedDate(DateTime date) {
    return date.year == _selectedDate.year &&
        date.month == _selectedDate.month &&
        date.day == _selectedDate.day;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  void _onDateSelected(DateTime date) {
    setState(() => _selectedDate = date);
    widget.onDateSelected?.call(date);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          if (widget.showWeekDays) _buildWeekDays(),
          _buildCalendarGrid(),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            setState(() {
              _currentMonth = DateTime(
                _currentMonth.year,
                _currentMonth.month - 1,
              );
            });
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
            setState(() {
              _currentMonth = DateTime(
                _currentMonth.year,
                _currentMonth.month + 1,
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildWeekDays() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    ).day;

    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;
    final prevMonthDays = (firstWeekday + 6) % 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: 42,
      itemBuilder: (context, index) {
        final day = index - prevMonthDays + 1;
        if (day < 1 || day > daysInMonth) {
          return const SizedBox.shrink();
        }

        final date = DateTime(_currentMonth.year, _currentMonth.month, day);
        final isSelected = _isSelectedDate(date);
        final isToday = _isToday(date);

        return InkWell(
          onTap: () => _onDateSelected(date),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryColor
                  : isToday
                      ? AppTheme.primaryColor.withOpacity(0.1)
                      : null,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                day.toString(),
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
          ),
        );
      },
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CustomButton(
            text: 'Cancel',
            onPressed: () => Navigator.of(context).pop(),
            variant: ButtonVariant.text,
          ),
          const SizedBox(width: 8),
          CustomButton(
            text: 'OK',
            onPressed: () => Navigator.of(context).pop(_selectedDate),
          ),
        ],
      ),
    );
  }
}
