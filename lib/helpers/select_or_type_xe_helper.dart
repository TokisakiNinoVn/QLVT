import 'package:flutter/material.dart';

import '../config/color_config.dart';

class AutocompleteFieldXe extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final List<Map<String, dynamic>> options;
  final String? Function() getSelectedId;
  final void Function(String?) setSelectedId;
  final bool errorState;
  final void Function(bool) setErrorState;
  final IconData icon;


  const AutocompleteFieldXe({
    super.key,
    required this.label,
    required this.controller,
    required this.options,
    required this.getSelectedId,
    required this.setSelectedId,
    required this.errorState,
    required this.setErrorState,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Nhập hoặc chọn $label',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: errorState
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.outline,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: errorState
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: errorState
                    ? Theme.of(context).colorScheme.error
                    : ColorConfig.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(
              icon,
              color: errorState
                  ? Theme.of(context).colorScheme.error
                  : ColorConfig.primary,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            errorText: errorState ? 'Vui lòng nhập hoặc chọn $label' : null,
            errorStyle: TextStyle(
              color: Theme.of(context).colorScheme.error,
            ),
            suffixIcon: PopupMenuButton<String>(
              icon: const Icon(Icons.arrow_drop_down),
              onSelected: (String value) {
                controller.text = value;

                final selectedItem = options.firstWhere(
                      (item) => '${
                      item['loaixe'] ?? ''
                  } - ${
                      item['bienso'] ?? ''
                  }' == value,
                  orElse: () => {},
                );

                setSelectedId(selectedItem['id']?.toString());
                setErrorState(false);
              },


              // onSelected: (String value) {
              //   controller.text = value;
              //   final selectedItem = options.firstWhere(
              //         (item) => item[fieldKey]?.toString() == value,
              //     orElse: () => {'id': null},
              //   );
              //   setSelectedId(selectedItem['id']?.toString());
              //   setErrorState(false);
              // },
              // itemBuilder: (BuildContext context) {
              //   return options.map((item) {
              //     final value =
              //         item[fieldKey]?.toString() ?? 'Không có tên';
              //     return PopupMenuItem<String>(
              //       value: value,
              //       child: Text(value),
              //     );
              //   }).toList();
              // },
              itemBuilder: (BuildContext context) {
                return options.map((item) {
                  final bienSo = item['bienso']?.toString() ?? '';
                  final loaiXe = item['loaixe']?.toString() ?? '';
                  final displayText = '$loaiXe - $bienSo';

                  return PopupMenuItem<String>(
                    value: displayText,
                    child: Text(displayText),
                  );
                }).toList();
              },
            ),
          ),
          // onChanged: (value) {
          //   setErrorState(false);
          //   setSelectedId(null);
          // },
          onChanged: (value) {
            setErrorState(false);
            setSelectedId(null); // reset khi người dùng nhập tay
          },
        ),
      ],
    );
  }
}
