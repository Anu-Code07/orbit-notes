import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:orbit_notes/core/theme/app_colors.dart';
import 'package:orbit_notes/core/theme/app_radii.dart';
import 'package:orbit_notes/core/theme/app_spacing.dart';
import 'package:orbit_notes/core/widgets/frosted_glass.dart';
import 'package:orbit_notes/features/notes/domain/entities/map_pin.dart';

class TripMapView extends StatelessWidget {
  const TripMapView({
    super.key,
    required this.pins,
    this.height = 220,
    this.onTap,
  });

  final List<MapPin> pins;
  final double height;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radii = context.radii;
    final spacing = context.spacing;
    final center = pins.isEmpty
        ? const LatLng(35.0116, 135.7681)
        : LatLng(pins.first.latitude, pins.first.longitude);

    return Material(
      color: colors.surfaceSoft,
      borderRadius: radii.xlRadius,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: center,
                initialZoom: pins.isEmpty ? 3 : 11,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.orbit.orbit_notes',
                ),
                MarkerLayer(
                  markers: pins
                      .map(
                        (pin) => Marker(
                          point: LatLng(pin.latitude, pin.longitude),
                          width: 40,
                          height: 40,
                          child: Icon(
                            Icons.location_on,
                            color: colors.brandCoral,
                            size: 36,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
            if (onTap != null)
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(onTap: onTap),
                ),
              ),
            if (pins.isEmpty)
              IgnorePointer(
                child: Center(
                  child: FrostedGlass(
                    borderRadius: radii.pillRadius,
                    tintOpacity: 0.55,
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.md,
                      vertical: spacing.sm,
                    ),
                    child: Text(
                      'No pins yet',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colors.ink,
                          ),
                    ),
                  ),
                ),
              )
            else
              Positioned(
                left: spacing.sm,
                bottom: spacing.sm,
                child: IgnorePointer(
                  child: FrostedGlass(
                    borderRadius: radii.pillRadius,
                    tintOpacity: 0.5,
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.md,
                      vertical: spacing.xs,
                    ),
                    child: Text(
                      '${pins.length} pin${pins.length == 1 ? '' : 's'}',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
