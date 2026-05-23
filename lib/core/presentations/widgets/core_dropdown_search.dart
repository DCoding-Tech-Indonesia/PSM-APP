import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

/// A generic reusable dropdown with search, styled for the app's design system.
///
/// Uses [DropdownSearch] from the `dropdown_search` package with a
/// bottom-sheet popup, rounded corners, a coloured header, and a search box.
///
/// Example usage:
/// ```dart
/// CoreDropdownSearch<ReferenceBus>(
///   label: 'Pilih Bus',
///   popupTitle: 'Daftar Bus',
///   items: state.referenceBus,
///   selectedItem: selectedBus,
///   itemAsString: (item) => '${item.nomorLambung} - ${item.platNomor}',
///   compareFn: (a, b) => a.id == b.id,
///   onSelected: (value) { ... },
/// )
/// ```
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

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<T>(
      items: (filter, _) => items
          .where(
            (item) =>
                itemAsString(item).toLowerCase().contains(filter.toLowerCase()),
          )
          .toList(),
      selectedItem: selectedItem,
      itemAsString: itemAsString,
      compareFn: compareFn,
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          hintText: hintText ?? label,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 12,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      popupProps: PopupProps.dialog(
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
                padding: const EdgeInsets.only(
                  top: 20,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
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
        dialogProps: const DialogProps(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
        ),
        itemBuilder: (context, item, isSelected, _) {
          final theme = Theme.of(context);
          return Container(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    itemAsString(item),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected ? theme.colorScheme.primary : null,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: theme.colorScheme.primary),
              ],
            ),
          );
        },
      ),
      onSelected: onSelected,
      // onChanged: onSelected,
    );
  }
}
