import 'package:flutter/material.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_strings.dart';

/// Equipment Card Widget
class EquipmentCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String price;
  final double rating;
  final int reviewCount;
  final String distance;
  final String equipmentType;
  final VoidCallback? onTap;
  final VoidCallback? onBook;

  const EquipmentCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    required this.equipmentType,
    this.onTap,
    this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.grey[200],
                child: Stack(
                  children: [
                    // Placeholder or actual image
                    Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey[400],
                        size: 48,
                      ),
                    ),
                    // Equipment Type Badge
                    Positioned(
                      top: AppDimensions.marginSmall,
                      right: AppDimensions.marginSmall,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingSmall,
                          vertical: AppDimensions.paddingXSmall,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusSmall,
                          ),
                        ),
                        child: Text(
                          equipmentType,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Content Section
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Equipment Name
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimensions.marginSmall),

                  // Rating and Distance Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Rating
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$rating ($reviewCount)',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      // Distance
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: Colors.grey,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$distance ${AppStrings.km}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.marginMedium),

                  // Price and Book Button Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            price,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                              fontSize: AppDimensions.fontLarge,
                            ),
                          ),
                          Text(
                            AppStrings.perDay,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      // Book Button
                      ElevatedButton(
                        onPressed: onBook,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingMedium,
                            vertical: AppDimensions.paddingSmall,
                          ),
                        ),
                        child: Text(
                          AppStrings.book,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Equipment Card Horizontal Layout
class EquipmentCardHorizontal extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String price;
  final double rating;
  final int reviewCount;
  final String distance;
  final String equipmentType;
  final VoidCallback? onTap;
  final VoidCallback? onBook;

  const EquipmentCardHorizontal({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    required this.equipmentType,
    this.onTap,
    this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Row(
            children: [
              // Image
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMedium,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.grey[400],
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.marginMedium),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimensions.marginSmall),
                    // Type and Distance
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingSmall,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            equipmentType,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: Colors.grey,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$distance ${AppStrings.km}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.marginSmall),
                    // Price and Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$price/일',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$rating ($reviewCount)',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.marginMedium),
              // Book Button
              ElevatedButton(
                onPressed: onBook,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(AppDimensions.paddingSmall),
                ),
                child: const Icon(Icons.arrow_forward, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
