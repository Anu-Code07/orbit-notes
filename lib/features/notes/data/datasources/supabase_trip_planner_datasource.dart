import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:orbit_notes/core/failure/failure.dart';
import 'package:orbit_notes/features/notes/domain/entities/planned_trip.dart';
import 'package:orbit_notes/features/notes/domain/repositories/trip_planner_repository.dart';

/// Calls the Supabase Edge Function `plan-trip`.
/// Groq API key stays in Supabase secrets — never in the app.
class SupabaseTripPlannerDataSource implements TripPlannerRepository {
  SupabaseTripPlannerDataSource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<PlannedTrip> planTrip(TripPlanRequest request) async {
    try {
      final response = await _client.functions.invoke(
        'plan-trip',
        body: {
          'vibe': request.vibe,
          'dayCount': request.dayCount,
          'pace': request.pace,
          'focus': request.focus,
          'companions': request.companions,
          'mustInclude': request.mustInclude,
        },
      );

      final data = response.data;
      if (data is! Map) {
        throw const UnexpectedFailure('Could not read the AI plan. Try again.');
      }

      final error = data['error'];
      if (error is String && error.isNotEmpty) {
        throw UnexpectedFailure(error);
      }

      final planRaw = data['plan'];
      if (planRaw is! Map) {
        throw const UnexpectedFailure('AI returned an empty plan.');
      }

      return _parsePlan(
        Map<String, dynamic>.from(planRaw),
        request.dayCount,
      );
    } on Failure {
      rethrow;
    } on FunctionException catch (error) {
      final details = error.details;
      if (details is Map && details['error'] is String) {
        throw UnexpectedFailure(details['error'] as String);
      }
      if (error.status == 401 || error.status == 403) {
        throw const UnexpectedFailure(
          'Sign in to plan trips with AI, then try again.',
        );
      }
      if (error.status == 404) {
        throw const UnexpectedFailure(
          'Trip planning failed (404). Deploy the plan-trip function.',
        );
      }
      throw UnexpectedFailure(
        'Trip planning failed (${error.status}). Try again.',
      );
    } catch (_) {
      throw const UnexpectedFailure(
        'Could not reach trip planner. Check connection.',
      );
    }
  }

  PlannedTrip _parsePlan(Map<String, dynamic> json, int dayCount) {
    final title = '${json['title'] ?? ''}'.trim();
    final destination = '${json['destination'] ?? ''}'.trim();
    final summary = '${json['summary'] ?? ''}'.trim();
    final rawDays = json['days'];
    if (title.isEmpty || destination.isEmpty || rawDays is! List) {
      throw const UnexpectedFailure('AI plan was incomplete. Try again.');
    }

    final days = <PlannedTripDay>[];
    for (final item in rawDays) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final index = (map['dayIndex'] as num?)?.toInt() ?? (days.length + 1);
      final dayTitle = '${map['title'] ?? 'Day $index'}'.trim();
      final prompt = '${map['entryPrompt'] ?? ''}'.trim();
      if (prompt.isEmpty) continue;
      final hint = '${map['placeHint'] ?? ''}'.trim();
      days.add(
        PlannedTripDay(
          dayIndex: index,
          title: dayTitle.isEmpty ? 'Day $index' : dayTitle,
          entryPrompt: prompt,
          placeHint: hint.isEmpty ? null : hint,
        ),
      );
    }

    if (days.isEmpty) {
      throw const UnexpectedFailure('AI plan had no days. Try again.');
    }

    days.sort((a, b) => a.dayIndex.compareTo(b.dayIndex));
    return PlannedTrip(
      title: title,
      destination: destination,
      summary: summary.isEmpty ? 'A trip shaped for your journal.' : summary,
      days: days.take(dayCount).toList(),
    );
  }
}
