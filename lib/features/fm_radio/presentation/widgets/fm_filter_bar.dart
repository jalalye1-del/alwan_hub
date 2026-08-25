// lib/features/fm_radio/presentation/widgets/fm_filter_bar.dart

import 'package:flutter/material.dart' hide Text;
import 'package:alwan_hub/core/localization/localized_text.dart';
import '../../domain/models/fm_filter.dart';

class FmFilterBar extends StatelessWidget {
  const FmFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onChanged,
  });

  final FmFilter selectedFilter;
  final ValueChanged<FmFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: FmFilter.values.length,
        separatorBuilder: (context, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = FmFilter.values[index];
          final selected = filter == selectedFilter;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            child: FilterChip(
              showCheckmark: false,
              label: Text(
                filter.title,
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : Colors.grey.shade700,
                  fontWeight: FontWeight.w700,
                ),
              ),
              selected: selected,
              backgroundColor: Colors.white,
              selectedColor: const Color(0xff6C4DFF),
              side: BorderSide(
                color: selected
                    ? Colors.transparent
                    : Colors.grey.shade300,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onSelected: (_) => onChanged(filter),
            ),
          );
        },
      ),
    );
  }
}
