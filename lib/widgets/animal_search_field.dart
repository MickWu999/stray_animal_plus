import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_theme.dart';
import '../providers/animal_browser_provider.dart';

class AnimalSearchField extends ConsumerStatefulWidget {
  const AnimalSearchField({super.key, this.hintText = '搜尋動物、品種或收容所'});

  final String hintText;

  @override
  ConsumerState<AnimalSearchField> createState() => _AnimalSearchFieldState();
}

class _AnimalSearchFieldState extends ConsumerState<AnimalSearchField> {
  late final TextEditingController _controller;
  late final ProviderSubscription<String> _keywordSubscription;

  @override
  void initState() {
    super.initState();
    final keyword = ref.read(animalBrowserProvider).keyword;
    _controller = TextEditingController(text: keyword);
    _keywordSubscription = ref.listenManual<String>(
      animalBrowserProvider.select((state) => state.keyword),
      (previous, next) {
        if (_controller.text == next) {
          return;
        }
        _controller.value = TextEditingValue(
          text: next,
          selection: TextSelection.collapsed(offset: next.length),
        );
      },
    );
  }

  @override
  void dispose() {
    _keywordSubscription.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: ref.read(animalBrowserProvider.notifier).setKeyword,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: AppTheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.primaryButton),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
      ),
    );
  }
}
