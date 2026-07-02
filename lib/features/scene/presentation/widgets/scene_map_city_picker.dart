import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_motion.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/location/map_city_catalog.dart';
import '../../../../shared/widgets/glass/glass_sheet.dart';
import '../../../../shared/widgets/glass/glass_text_field.dart';

Future<MapCityPreset?> showSceneMapCityPicker(
  BuildContext context, {
  required String selectedCity,
}) {
  return showGlassScrollSheet<MapCityPreset>(
    context,
    maxHeightFraction: 0.55,
    builder: (context, maxHeight) => _SceneMapCityPickerBody(
      maxHeight: maxHeight,
      selectedCity: selectedCity,
    ),
  );
}

class _SceneMapCityPickerBody extends StatefulWidget {
  const _SceneMapCityPickerBody({
    required this.maxHeight,
    required this.selectedCity,
  });

  final double maxHeight;
  final String selectedCity;

  @override
  State<_SceneMapCityPickerBody> createState() => _SceneMapCityPickerBodyState();
}

class _SceneMapCityPickerBodyState extends State<_SceneMapCityPickerBody> {
  final _queryController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  List<MapCityPreset> get _results => MapCityCatalog.search(_query);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.maxHeight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.spacingLg,
          0,
          AppDimensions.spacingLg,
          AppDimensions.spacingSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('选择城市', style: AppTextStyles.title.copyWith(fontSize: 17)),
            const SizedBox(height: AppDimensions.spacingSm),
            GlassTextField(
              controller: _queryController,
              hintText: '搜索城市',
              prefixIcon: Icons.search,
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Expanded(
              child: AnimatedSwitcher(
                duration: AppMotion.fast,
                child: _results.isEmpty
                    ? Center(
                        key: const ValueKey('empty'),
                        child: Text(
                          '未找到匹配城市',
                          style: AppTextStyles.bodySecondary,
                        ),
                      )
                    : ListView.separated(
                        key: ValueKey(_query),
                        itemCount: _results.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: AppDimensions.spacingXs),
                        itemBuilder: (context, index) {
                          final city = _results[index];
                          final selected = city.name == widget.selectedCity;
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusLg,
                              ),
                              onTap: () => Navigator.pop(context, city),
                              child: Ink(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusLg,
                                  ),
                                  color: selected
                                      ? Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.12)
                                      : null,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppDimensions.spacingMd,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.location_city_outlined,
                                        size: 20,
                                        color: selected
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                      ),
                                      const SizedBox(
                                        width: AppDimensions.spacingSm,
                                      ),
                                      Expanded(
                                        child: Text(
                                          city.name,
                                          style: AppTextStyles.body.copyWith(
                                            fontWeight: selected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                      if (selected)
                                        Icon(
                                          Icons.check_circle,
                                          size: 18,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
