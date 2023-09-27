import 'package:flutter/material.dart';

import '../../../../../../domain/enums.dart';
import '../../../../../global/colors.dart';
import '../../../../../global/extensions/build_context_ext.dart';

class TrendingTimeWindow extends StatelessWidget {
  const TrendingTimeWindow({
    super.key,
    required this.timeWindow,
    required this.onChanged,
  });
  final TimeWindow timeWindow;
  final void Function(TimeWindow) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Row(
        children: [
          Text(
            'TENDENCIAS',
            style: context.textTheme.titleSmall,
          ),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Material(
              color:
                  context.darkMode ? AppColors.dark : const Color(0xfff0f0f0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: DropdownButton<TimeWindow>(
                  value: timeWindow,
                  isDense: true,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(
                      value: TimeWindow.day,
                      child: Text(
                        'Últimas 24h',
                      ),
                    ),
                    DropdownMenuItem(
                      value: TimeWindow.week,
                      child: Text(
                        'Última semana',
                      ),
                    ),
                  ],
                  onChanged: (mTimeWindow) {
                    if (mTimeWindow != null && timeWindow != mTimeWindow) {
                      onChanged(mTimeWindow);
                    }
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
        ],
      ),
    );
  }
}
