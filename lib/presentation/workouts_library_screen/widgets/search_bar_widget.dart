import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Search bar widget with voice input capability
class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final VoidCallback onFilterTap;
  final List<String> recentSearches;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onSearch,
    required this.onFilterTap,
    required this.recentSearches,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _showRecentSearches = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    await _speech.initialize();
  }

  Future<void> _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        HapticFeedback.mediumImpact();
        _speech.listen(
          onResult: (result) {
            setState(() {
              widget.controller.text = result.recognizedWords;
              if (result.finalResult) {
                _isListening = false;
                widget.onSearch(result.recognizedWords);
              }
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline,
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: widget.controller,
                    onChanged: (value) {
                      if (value.isEmpty) {
                        setState(() => _showRecentSearches = true);
                      } else {
                        setState(() => _showRecentSearches = false);
                      }
                    },
                    onSubmitted: (value) {
                      widget.onSearch(value);
                      setState(() => _showRecentSearches = false);
                    },
                    onTap: () {
                      if (widget.controller.text.isEmpty) {
                        setState(() => _showRecentSearches = true);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Search workouts...',
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(2.w),
                        child: CustomIconWidget(
                          iconName: 'search',
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                      suffixIcon: widget.controller.text.isNotEmpty
                          ? IconButton(
                              icon: CustomIconWidget(
                                iconName: 'close',
                                color: theme.colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                              onPressed: () {
                                widget.controller.clear();
                                widget.onSearch('');
                                setState(() => _showRecentSearches = true);
                              },
                            )
                          : IconButton(
                              icon: CustomIconWidget(
                                iconName: _isListening ? 'mic' : 'mic_none',
                                color: _isListening
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                              onPressed: _startListening,
                            ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 1.5.h,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Container(
                height: 6.h,
                width: 12.w,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: CustomIconWidget(
                    iconName: 'tune',
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    widget.onFilterTap();
                  },
                ),
              ),
            ],
          ),
        ),
        if (_showRecentSearches && widget.recentSearches.isNotEmpty)
          Container(
            color: theme.colorScheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  child: Text(
                    'Recent Searches',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                ...widget.recentSearches.take(5).map((search) {
                  return InkWell(
                    onTap: () {
                      widget.controller.text = search;
                      widget.onSearch(search);
                      setState(() => _showRecentSearches = false);
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.5.h,
                      ),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'history',
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 18,
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(
                              search,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                Divider(height: 1, color: theme.colorScheme.outline),
              ],
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }
}
