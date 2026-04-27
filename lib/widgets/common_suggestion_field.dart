import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';

class CommonSuggestionField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final List<Map<String, dynamic>> suggestions;
  final Function(Map<String, dynamic>) onSelected;
  final String? Function(String?)? validator;
  final bool isLoading;
  final String? label;

  const CommonSuggestionField({
    super.key,
    required this.controller,
    required this.hint,
    required this.suggestions,
    required this.onSelected,
    this.validator,
    this.isLoading = false,
    this.label,
  });

  @override
  State<CommonSuggestionField> createState() => _CommonSuggestionFieldState();
}

class _CommonSuggestionFieldState extends State<CommonSuggestionField> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final FocusNode _focusNode = FocusNode();
  bool _isOverlayVisible = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _showOverlay();
      } else {
        _hideOverlay();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _hideOverlay();
    super.dispose();
  }

  void _showOverlay() {
    if (_isOverlayVisible) return;
    
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isOverlayVisible = true;
    });
  }

  void _hideOverlay() {
    if (!_isOverlayVisible) return;
    
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isOverlayVisible = false;
    });
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 5.0),
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: widget.controller,
                builder: (context, value, child) {
                  final filteredList = widget.suggestions
                      .where((element) =>
                          element['name']
                              ?.toString()
                              .toLowerCase()
                              .contains(value.text.toLowerCase()) ??
                          false)
                      .toList();

                  if (filteredList.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CommonText('No results found', fontSize: 14, color: AppColors.textSecondary),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      return ListTile(
                        title: CommonText(item['name'] ?? '', fontSize: 14),
                        onTap: () {
                          widget.onSelected(item);
                          _focusNode.unfocus();
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          CommonText(
            widget.label!,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 6),
        ],
        CompositedTransformTarget(
          link: _layerLink,
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            validator: widget.validator,
            onChanged: (val) {
              if (!_isOverlayVisible) {
                _showOverlay();
              }
            },
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              suffixIcon: widget.isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
            ),
          ),
        ),
      ],
    );
  }
}
