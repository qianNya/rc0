import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_motion.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/location/map_nearby_place.dart';

class SceneMapPlaceList extends StatelessWidget {
  const SceneMapPlaceList({
    super.key,
    required this.places,
    required this.selected,
    required this.onSelected,
    this.loading = false,
    this.error,
    this.onRetry,
  });

  final List<MapNearbyPlace> places;
  final MapNearbyPlace? selected;
  final ValueChanged<MapNearbyPlace> onSelected;
  final bool loading;
  final String? error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppDimensions.spacingMd),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('附近建筑', style: AppTextStyles.label.copyWith(fontSize: 13)),
        if (error != null) ...[
          const SizedBox(height: 4),
          Text(error!, style: AppTextStyles.bodySecondary),
        ],
        const SizedBox(height: AppDimensions.spacingXs),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 168),
          child: ListView.separated(
            padding: EdgeInsets.zero,
            physics: const ClampingScrollPhysics(),
            itemCount: places.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppDimensions.spacingXs),
            itemBuilder: (context, index) {
              final place = places[index];
              final isSelected = selected?.name == place.name &&
                  selected?.point.latitude == place.point.latitude &&
                  selected?.point.longitude == place.point.longitude;
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusLg),
                  onTap: () => onSelected(place),
                  child: AnimatedContainer(
                    duration: AppMotion.fast,
                    curve: AppMotion.standard,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingSm,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusLg),
                      color: isSelected
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.12)
                          : Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.45),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          place.isCoordinateFallback
                              ? Icons.place_outlined
                              : Icons.apartment_outlined,
                          size: 18,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                        ),
                        const SizedBox(width: AppDimensions.spacingSm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                place.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                              if (place.subtitle.isNotEmpty)
                                Text(
                                  place.subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.bodySecondary
                                      .copyWith(fontSize: 12),
                                ),
                            ],
                          ),
                        ),
                        if (place.distanceLabel.isNotEmpty)
                          Text(
                            place.distanceLabel,
                            style: AppTextStyles.bodySecondary
                                .copyWith(fontSize: 11),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (error != null && onRetry != null) ...[
          const SizedBox(height: AppDimensions.spacingXs),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onRetry,
              child: const Text('重试'),
            ),
          ),
        ],
      ],
    );
  }
}
