import 'package:flutter/material.dart';
import 'package:eventease/theme/app_theme.dart';
import 'package:eventease/utils/helpers.dart';
import 'package:eventease/widgets/custom_button.dart';

class CustomTimePicker extends StatefulWidget {
  final TimeOfDay? initialTime;
  final ValueChanged<TimeOfDay>? onTimeSelected;
  final String? label;
  final String? hint;
  final bool use24HourFormat;
  final bool showSeconds;
  final TimePickerInterval interval;

  const CustomTimePicker({
    super.key,
    this.initialTime,
    this.onTimeSelected,
    this.label,
    this.hint,
    this.use24HourFormat = false,
    this.showSeconds = false,
    this.interval = TimePickerInterval.fifteenMinutes,
  });

  @override
  State<CustomTimePicker> createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime ?? TimeOfDay.now();
  }

  Future<void> _showTimePicker() async {
    final pickedTime = await showDialog<TimeOfDay>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: TimePickerDialog2(
          initialTime: _selectedTime,
          use24HourFormat: widget.use24HourFormat,
          showSeconds: widget.showSeconds,
          interval: widget.interval,
          onTimeSelected: (time) {
            Navigator.of(context).pop(time);
          },
        ),
      ),
    );

    if (pickedTime != null) {
      setState(() => _selectedTime = pickedTime);
      widget.onTimeSelected?.call(pickedTime);
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
          onTap: _showTimePicker,
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
                  Icons.access_time_rounded,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  _formatTime(_selectedTime),
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

  String _formatTime(TimeOfDay time) {
    if (widget.use24HourFormat) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      final hour = time.hourOfPeriod;
      final minute = time.minute.toString().padLeft(2, '0');
      final period = time.period == DayPeriod.am ? 'AM' : 'PM';
      return '${hour == 0 ? 12 : hour}:$minute $period';
    }
  }
}

class TimePickerDialog2 extends StatefulWidget {
  final TimeOfDay initialTime;
  final bool use24HourFormat;
  final bool showSeconds;
  final TimePickerInterval interval;
  final ValueChanged<TimeOfDay>? onTimeSelected;

  const TimePickerDialog2({
    super.key,
    required this.initialTime,
    this.use24HourFormat = false,
    this.showSeconds = false,
    this.interval = TimePickerInterval.fifteenMinutes,
    this.onTimeSelected,
  });

  @override
  State<TimePickerDialog2> createState() => _TimePickerDialog2State();
}

class _TimePickerDialog2State extends State<TimePickerDialog2> {
  late int _selectedHour;
  late int _selectedMinute;
  late DayPeriod _selectedPeriod;

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialTime.hour;
    _selectedMinute = widget.initialTime.minute;
    _selectedPeriod = widget.initialTime.period;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Select Time',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHourPicker(),
              const Text(
                ':',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildMinutePicker(),
              if (!widget.use24HourFormat) ...[
                const SizedBox(width: 16),
                _buildPeriodPicker(),
              ],
            ],
          ),
          const SizedBox(height: 24),
          Row(
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
                onPressed: () {
                  final selectedTime = TimeOfDay(
                    hour: widget.use24HourFormat
                        ? _selectedHour
                        : _selectedHour +
                            (_selectedPeriod == DayPeriod.pm ? 12 : 0),
                    minute: _selectedMinute,
                  );
                  widget.onTimeSelected?.call(selectedTime);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHourPicker() {
    final hours = widget.use24HourFormat
        ? List.generate(24, (index) => index)
        : List.generate(12, (index) => index + 1);

    return SizedBox(
      width: 60,
      child: ListWheelScrollView(
        itemExtent: 40,
        diameterRatio: 1.5,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (index) {
          setState(() => _selectedHour = hours[index]);
        },
        children: hours.map((hour) {
          return Center(
            child: Text(
              hour.toString().padLeft(2, '0'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: hour == _selectedHour
                    ? FontWeight.bold
                    : FontWeight.normal,
                color:
                    hour == _selectedHour ? AppTheme.primaryColor : Colors.black87,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMinutePicker() {
    final minutes = List.generate(
      60 ~/ widget.interval.minutes,
      (index) => index * widget.interval.minutes,
    );

    return SizedBox(
      width: 60,
      child: ListWheelScrollView(
        itemExtent: 40,
        diameterRatio: 1.5,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (index) {
          setState(() => _selectedMinute = minutes[index]);
        },
        children: minutes.map((minute) {
          return Center(
            child: Text(
              minute.toString().padLeft(2, '0'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: minute == _selectedMinute
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: minute == _selectedMinute
                    ? AppTheme.primaryColor
                    : Colors.black87,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPeriodPicker() {
    return Column(
      children: [
        _PeriodButton(
          period: DayPeriod.am,
          isSelected: _selectedPeriod == DayPeriod.am,
          onTap: () => setState(() => _selectedPeriod = DayPeriod.am),
        ),
        const SizedBox(height: 8),
        _PeriodButton(
          period: DayPeriod.pm,
          isSelected: _selectedPeriod == DayPeriod.pm,
          onTap: () => setState(() => _selectedPeriod = DayPeriod.pm),
        ),
      ],
    );
  }
}

class _PeriodButton extends StatelessWidget {
  final DayPeriod period;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodButton({
    required this.period,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          period == DayPeriod.am ? 'AM' : 'PM',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}

enum TimePickerInterval {
  oneMinute(1),
  fiveMinutes(5),
  tenMinutes(10),
  fifteenMinutes(15),
  thirtyMinutes(30);

  final int minutes;
  const TimePickerInterval(this.minutes);
}
