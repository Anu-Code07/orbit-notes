import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import 'package:orbit_notes/core/di/injection.dart';
import 'package:orbit_notes/core/failure/failure.dart';
import 'package:orbit_notes/core/location/device_location_service.dart';
import 'package:orbit_notes/core/theme/app_colors.dart';
import 'package:orbit_notes/core/theme/app_radii.dart';
import 'package:orbit_notes/core/theme/app_spacing.dart';
import 'package:orbit_notes/core/widgets/orbit_button.dart';
import 'package:orbit_notes/features/notes/domain/entities/place_search_result.dart';
import 'package:orbit_notes/features/notes/domain/usecases/search_places.dart';
import 'package:orbit_notes/features/notes/presentation/bloc/entry/entry_bloc.dart';

class EntryEditorPage extends StatelessWidget {
  const EntryEditorPage({
    super.key,
    required this.tripId,
    required this.dayId,
    this.entryId,
  });

  final String tripId;
  final String dayId;
  final String? entryId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = getIt<EntryBloc>();
        if (entryId == null) {
          bloc.add(PrepareNewEntry(dayId: dayId, tripId: tripId));
        } else {
          bloc.add(LoadEntry(entryId: entryId!, tripId: tripId));
        }
        return bloc;
      },
      child: const _EntryEditorView(),
    );
  }
}

class _EntryEditorView extends StatefulWidget {
  const _EntryEditorView();

  @override
  State<_EntryEditorView> createState() => _EntryEditorViewState();
}

class _EntryEditorViewState extends State<_EntryEditorView> {
  late final TextEditingController _bodyController;
  late final TextEditingController _placeController;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _bodyController = TextEditingController();
    _placeController = TextEditingController();
  }

  @override
  void dispose() {
    _bodyController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file == null || !mounted) return;
      context.read<EntryBloc>().add(AddLocalPhoto(file.path));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not access photos. Check permissions.'),
        ),
      );
    }
  }

  Future<void> _useGps() async {
    setState(() => _locating = true);
    try {
      final result = await getIt<DeviceLocationService>().getCurrentPosition();
      if (!mounted) return;
      final label = _placeController.text.trim().isEmpty
          ? 'Current spot'
          : _placeController.text.trim();
      context.read<EntryBloc>().add(
            SetMapPin(
              latitude: result.point.latitude,
              longitude: result.point.longitude,
              label: label,
            ),
          );
      if (_placeController.text.trim().isEmpty) {
        _placeController.text = label;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.accuracyMeters == null
                ? 'Pinned your current location.'
                : 'Pinned (±${result.accuracyMeters!.round()} m).',
          ),
        ),
      );
    } on Failure catch (failure) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not get GPS. Try again or pin manually.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _pickPin(EntryEditing state) async {
    final result = await showModalBottomSheet<_PinResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.canvas,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.radii.xl),
        ),
      ),
      builder: (context) => PlacePinPickerSheet(
        initial: state.pinLatitude != null && state.pinLongitude != null
            ? LatLng(state.pinLatitude!, state.pinLongitude!)
            : const LatLng(35.0116, 135.7681),
        label: state.placeName,
      ),
    );
    if (result != null && mounted) {
      context.read<EntryBloc>().add(
            SetMapPin(
              latitude: result.point.latitude,
              longitude: result.point.longitude,
              label: result.label,
            ),
          );
      _placeController.text = result.label;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radii = context.radii;

    return BlocConsumer<EntryBloc, EntryState>(
      listener: (context, state) {
        if (state is EntrySaved) {
          context.pop(true);
        }
        if (state is EntryEditing) {
          if (_bodyController.text != state.body) {
            _bodyController.text = state.body;
            _bodyController.selection =
                TextSelection.collapsed(offset: state.body.length);
          }
          if (_placeController.text != state.placeName) {
            _placeController.text = state.placeName;
          }
        }
      },
      builder: (context, state) {
        if (state is EntryLoading || state is EntryInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is EntryError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(state.failure.message)),
          );
        }
        if (state is! EntryEditing) {
          return const Scaffold(body: SizedBox.shrink());
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(state.isNew ? 'New entry' : 'Edit entry'),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: spacing.sm),
                child: OrbitButton(
                  label: 'Save',
                  isLoading: state.isSaving,
                  onPressed: state.isSaving
                      ? null
                      : () => context.read<EntryBloc>().add(const SaveEntry()),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: EdgeInsets.all(spacing.lg),
            children: [
              TextField(
                controller: _placeController,
                decoration: const InputDecoration(hintText: 'Place name'),
                onChanged: (v) =>
                    context.read<EntryBloc>().add(PlaceNameChanged(v)),
              ),
              SizedBox(height: spacing.md),
              TextField(
                controller: _bodyController,
                minLines: 8,
                maxLines: 16,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'What happened today?',
                  alignLabelWithHint: true,
                ),
                onChanged: (v) =>
                    context.read<EntryBloc>().add(BodyChanged(v)),
              ),
              SizedBox(height: spacing.lg),
              Text(
                'PHOTOS & PLACE',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              SizedBox(height: spacing.sm),
              OrbitButton(
                label: 'Photo',
                variant: OrbitButtonVariant.secondary,
                icon: Icons.photo_outlined,
                onPressed: _pickPhoto,
              ),
              SizedBox(height: spacing.sm),
              Row(
                children: [
                  Expanded(
                    child: OrbitButton(
                      label: _locating ? 'Locating…' : 'Use GPS',
                      variant: OrbitButtonVariant.secondary,
                      icon: Icons.my_location,
                      isLoading: _locating,
                      onPressed: _locating ? null : _useGps,
                    ),
                  ),
                  SizedBox(width: spacing.sm),
                  Expanded(
                    child: OrbitButton(
                      label: state.pinLatitude == null ? 'Map pin' : 'Edit pin',
                      variant: OrbitButtonVariant.secondary,
                      icon: Icons.map_outlined,
                      onPressed: () => _pickPin(state),
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing.xs),
              Text(
                'GPS drops your current spot. Map pin lets you place it by hand.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.muted,
                    ),
              ),
              if (state.allPhotoPaths.isNotEmpty) ...[
                SizedBox(height: spacing.lg),
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.allPhotoPaths.length,
                    separatorBuilder: (_, __) => SizedBox(width: spacing.sm),
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: radii.lgRadius,
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Image.file(
                            File(state.allPhotoPaths[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              if (state.pinLatitude != null) ...[
                SizedBox(height: spacing.md),
                Text(
                  'Pin · ${state.pinLatitude!.toStringAsFixed(4)}, ${state.pinLongitude!.toStringAsFixed(4)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.muted,
                      ),
                ),
              ],
              if (state.message != null) ...[
                SizedBox(height: spacing.md),
                Text(
                  state.message!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.error,
                      ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _PinResult {
  const _PinResult({required this.point, required this.label});

  final LatLng point;
  final String label;
}

class PlacePinPickerSheet extends StatefulWidget {
  const PlacePinPickerSheet({
    super.key,
    required this.initial,
    required this.label,
  });

  final LatLng initial;
  final String label;

  @override
  State<PlacePinPickerSheet> createState() => _PlacePinPickerSheetState();
}

class _PlacePinPickerSheetState extends State<PlacePinPickerSheet> {
  late LatLng _point;
  late final TextEditingController _labelController;
  late final TextEditingController _searchController;
  late final MapController _mapController;
  bool _locating = false;
  bool _searching = false;
  String? _searchError;
  List<PlaceSearchResult> _results = const [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _point = widget.initial;
    _labelController = TextEditingController(text: widget.label);
    _searchController = TextEditingController();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _labelController.dispose();
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      _runSearch(value);
    });
  }

  Future<void> _runSearch(String value) async {
    final query = value.trim();
    if (query.length < 2) {
      setState(() {
        _results = const [];
        _searchError = null;
        _searching = false;
      });
      return;
    }
    setState(() {
      _searching = true;
      _searchError = null;
    });
    try {
      final results = await getIt<SearchPlaces>()(query);
      if (!mounted) return;
      setState(() {
        _results = results;
        _searching = false;
        if (results.isEmpty) {
          _searchError = 'No places found.';
        }
      });
    } on Failure catch (failure) {
      if (!mounted) return;
      setState(() {
        _searching = false;
        _results = const [];
        _searchError = failure.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _searching = false;
        _results = const [];
        _searchError = 'Could not search places.';
      });
    }
  }

  void _selectResult(PlaceSearchResult result) {
    final point = LatLng(result.latitude, result.longitude);
    setState(() {
      _point = point;
      _results = const [];
      _searchError = null;
      _searchController.text = result.name;
    });
    _labelController.text = result.name;
    _mapController.move(point, 14);
    FocusScope.of(context).unfocus();
  }

  Future<void> _jumpToGps() async {
    setState(() => _locating = true);
    try {
      final result = await getIt<DeviceLocationService>().getCurrentPosition();
      if (!mounted) return;
      setState(() => _point = result.point);
      _mapController.move(result.point, 15);
      if (_labelController.text.trim().isEmpty) {
        _labelController.text = 'Current spot';
      }
    } on Failure catch (failure) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not get GPS. Tap the map instead.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final height = MediaQuery.sizeOf(context).height * 0.82;

    return SizedBox(
      height: height,
      child: Padding(
        padding: EdgeInsets.all(spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Place a pin',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: spacing.sm),
            Text(
              'Search a place, tap the map, or jump to GPS.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.muted,
                  ),
            ),
            SizedBox(height: spacing.md),
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search a place…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
            ),
            if (_results.isNotEmpty)
              Flexible(
                flex: 0,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 140),
                  child: Material(
                    color: colors.surfaceSoft,
                    borderRadius: BorderRadius.circular(12),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _results.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, color: colors.hairline),
                      itemBuilder: (context, index) {
                        final item = _results[index];
                        return ListTile(
                          dense: true,
                          title: Text(item.name),
                          subtitle: Text(
                            item.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _selectResult(item),
                        );
                      },
                    ),
                  ),
                ),
              )
            else if (_searchError != null)
              Padding(
                padding: EdgeInsets.only(top: spacing.xs),
                child: Text(
                  _searchError!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.muted,
                      ),
                ),
              ),
            SizedBox(height: spacing.md),
            TextField(
              controller: _labelController,
              decoration: const InputDecoration(hintText: 'Label'),
            ),
            SizedBox(height: spacing.md),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(context.radii.lg),
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _point,
                        initialZoom: 12,
                        onTap: (_, latLng) => setState(() => _point = latLng),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.orbit.orbit_notes',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _point,
                              width: 40,
                              height: 40,
                              child: Icon(
                                Icons.location_on,
                                color: colors.brandCoral,
                                size: 36,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Positioned(
                      right: spacing.sm,
                      top: spacing.sm,
                      child: OrbitButton(
                        label: _locating ? '…' : 'GPS',
                        icon: Icons.my_location,
                        variant: OrbitButtonVariant.frost,
                        isLoading: _locating,
                        onPressed: _locating ? null : _jumpToGps,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: spacing.md),
            OrbitButton(
              label: 'Use this pin',
              onPressed: () {
                Navigator.of(context).pop(
                  _PinResult(
                    point: _point,
                    label: _labelController.text.trim(),
                  ),
                );
              },
            ),
            SizedBox(height: MediaQuery.paddingOf(context).bottom),
          ],
        ),
      ),
    );
  }
}
