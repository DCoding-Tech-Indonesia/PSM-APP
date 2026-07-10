import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:travis/core/presentations/widgets/core_selected_dropdown_indicator.dart';

/// A generic reusable dropdown with search, styled for the app's design system.
///
/// Uses [DropdownSearch] from the `dropdown_search` package with a
/// bottom-sheet popup, rounded corners, a coloured header, and a search box.
class CoreDropdownSearch<T> extends StatelessWidget {
  const CoreDropdownSearch({
    super.key,
    required this.label,
    required this.popupTitle,
    required this.items,
    required this.itemAsString,
    required this.compareFn,
    this.selectedItem,
    this.onSelected,
    this.hintText,
    this.headerColor,
    this.isRequired = false,
    this.isItemSelected,
    this.readOnly = false, // 🛠️ Tambah default param readOnly
  });

  /// Label shown inside the input field.
  final String label;

  /// Title displayed at the top of the bottom-sheet popup.
  final String popupTitle;

  /// The full list of items to show in the dropdown.
  final List<T> items;

  /// Converts an item to its display string.
  final String Function(T item) itemAsString;

  /// Equality comparison used to determine the selected item.
  final bool Function(T a, T b) compareFn;

  /// Currently selected item (pre-selects the field value).
  final T? selectedItem;

  /// Callback fired when the user picks an item. Returns `null` if cleared.
  final ValueChanged<T?>? onSelected;

  /// Optional hint text; defaults to the [label] value.
  final String? hintText;

  /// Background color of the popup header bar. Defaults to [Colors.blueAccent].
  final Color? headerColor;

  /// When `true`, appends a red asterisk to the label.
  final bool isRequired;

  final bool Function(T item)? isItemSelected;

  /// 🛠️ Menentukan apakah dropdown hanya bisa dibaca dan tidak bisa diklik.
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A5568),
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),

        const SizedBox(height: 8),

        DropdownSearch<T>(
          enabled: !readOnly,
          items: (filter, _) => items
              .where(
                (item) => itemAsString(
                  item,
                ).toLowerCase().contains(filter.toLowerCase()),
              )
              .toList(),
          selectedItem: selectedItem,
          itemAsString: itemAsString,
          compareFn: compareFn,

          decoratorProps: DropDownDecoratorProps(
            decoration: InputDecoration(
              hintText: hintText ?? '',
              filled: true,
              fillColor: readOnly
                  ? Colors.grey.withValues(alpha: 0.12)
                  : Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 14,
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1.2),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xFF1565C0),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          popupProps: PopupProps.modalBottomSheet(
            showSearchBox: true,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                hintText: 'Cari...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                filled: true,
                fillColor: Colors.grey.withValues(alpha: 0.1),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            searchDelay: const Duration(milliseconds: 300),
            title: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: headerColor ?? Theme.of(context).primaryColor,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      popupTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            modalBottomSheetProps: const ModalBottomSheetProps(
              enableDrag: true,
              barrierDismissible: true,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(24)),
              ),
            ),
            itemBuilder: (context, item, isSelected, _) {
              final theme = Theme.of(context);

              final selected = isItemSelected?.call(item) ?? isSelected;

              return Container(
                color: selected
                    ? theme.colorScheme.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        itemAsString(item),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: selected ? theme.colorScheme.primary : null,
                        ),
                      ),
                    ),
                    CoreSelectedDropdownIndicator(active: selected),
                  ],
                ),
              );
            },
          ),
          onSelected: onSelected,
        ),
      ],
    );
  }
}
