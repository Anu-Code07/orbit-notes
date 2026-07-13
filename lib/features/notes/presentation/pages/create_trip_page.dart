import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:orbit_notes/core/di/injection.dart';
import 'package:orbit_notes/core/theme/app_colors.dart';
import 'package:orbit_notes/core/theme/app_spacing.dart';
import 'package:orbit_notes/core/widgets/orbit_button.dart';
import 'package:orbit_notes/features/notes/domain/entities/day.dart';
import 'package:orbit_notes/features/notes/domain/entities/trip.dart';
import 'package:orbit_notes/features/notes/domain/usecases/journal_usecases.dart';
import 'package:orbit_notes/features/notes/domain/usecases/trip_usecases.dart';

class CreateTripPage extends StatefulWidget {
  const CreateTripPage({super.key});

  @override
  State<CreateTripPage> createState() => _CreateTripPageState();
}

class _CreateTripPageState extends State<CreateTripPage> {
  final _titleController = TextEditingController();
  final _destinationController = TextEditingController();
  final _uuid = const Uuid();
  DateTimeRange? _range;
  String? _coverPath;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _pickDates() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      initialDateRange: _range ??
          DateTimeRange(
            start: now,
            end: now.add(const Duration(days: 3)),
          ),
    );
    if (picked != null) {
      setState(() => _range = picked);
    }
  }

  Future<void> _pickCover() async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file == null) return;
      final persisted = await getIt<PersistImage>()(file.path);
      setState(() => _coverPath = persisted);
    } catch (_) {
      setState(
        () => _error =
            'Photo access was denied or failed. You can continue without a cover.',
      );
    }
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Give your trip a title.');
      return;
    }
    if (_range == null) {
      setState(() => _error = 'Pick start and end dates.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final trips = await getIt<GetTrips>()();
      final accentIndex = trips.length % 6;
      final now = DateTime.now();
      final trip = Trip(
        id: _uuid.v4(),
        title: title,
        startDate: DateTime(
          _range!.start.year,
          _range!.start.month,
          _range!.start.day,
        ),
        endDate: DateTime(
          _range!.end.year,
          _range!.end.month,
          _range!.end.day,
        ),
        destination: _destinationController.text.trim(),
        coverPath: _coverPath,
        accentIndex: accentIndex,
        createdAt: now,
      );
      await getIt<CreateTrip>()(trip);

      // One calendar day per date in range (DST-safe).
      var cursor = DateTime(
        trip.startDate.year,
        trip.startDate.month,
        trip.startDate.day,
      );
      final end = DateTime(
        trip.endDate.year,
        trip.endDate.month,
        trip.endDate.day,
      );
      var dayIndex = 1;
      while (!cursor.isAfter(end)) {
        await getIt<CreateDay>()(
          Day(
            id: _uuid.v4(),
            tripId: trip.id,
            date: cursor,
            title: 'Day $dayIndex',
            createdAt: now,
          ),
        );
        cursor = DateTime(cursor.year, cursor.month, cursor.day + 1);
        dayIndex++;
      }

      if (!mounted) return;
      context.pop(true);
    } catch (_) {
      setState(() {
        _saving = false;
        _error = 'Could not save the trip. Try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final dateFmt = DateFormat('MMM d, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('New trip'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(spacing.lg),
        children: [
          Text(
            'Where to?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 32,
                ),
          ),
          SizedBox(height: spacing.xl),
          TextField(
            controller: _titleController,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'Trip title'),
          ),
          SizedBox(height: spacing.md),
          TextField(
            controller: _destinationController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(hintText: 'Destination'),
          ),
          SizedBox(height: spacing.md),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              _range == null
                  ? 'Select dates'
                  : '${dateFmt.format(_range!.start)} – ${dateFmt.format(_range!.end)}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            subtitle: Text(
              'Day-by-day timeline uses these dates',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.muted,
                  ),
            ),
            trailing: const Icon(Icons.calendar_today_outlined),
            onTap: _pickDates,
          ),
          SizedBox(height: spacing.md),
          if (_coverPath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.file(File(_coverPath!), fit: BoxFit.cover),
              ),
            )
          else
            Container(
              height: 140,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.surfaceCard,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Optional cover photo',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.muted,
                    ),
              ),
            ),
          SizedBox(height: spacing.sm),
          OrbitButton(
            label: _coverPath == null ? 'Add cover' : 'Change cover',
            variant: OrbitButtonVariant.secondary,
            icon: Icons.photo_outlined,
            onPressed: _pickCover,
          ),
          if (_error != null) ...[
            SizedBox(height: spacing.md),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.error,
                  ),
            ),
          ],
          SizedBox(height: spacing.xl),
          OrbitButton(
            label: 'Create trip',
            isLoading: _saving,
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }
}
