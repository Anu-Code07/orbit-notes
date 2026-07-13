import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:orbit_notes/core/config/groq_secrets.dart';
import 'package:orbit_notes/core/failure/failure.dart';
import 'package:orbit_notes/features/notes/domain/entities/planned_trip.dart';
import 'package:orbit_notes/features/notes/domain/repositories/trip_planner_repository.dart';

/// Local/dev planner via Groq. Uses gitignored [GroqSecrets.apiKey].
/// Prefer the Supabase `plan-trip` function in production.
class GroqTripPlannerDataSource implements TripPlannerRepository {
  GroqTripPlannerDataSource({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  static const _model = 'llama-3.3-70b-versatile';
  static final _endpoint =
      Uri.parse('https://api.groq.com/openai/v1/chat/completions');

  @override
  Future<PlannedTrip> planTrip(TripPlanRequest request) async {
    final apiKey = GroqSecrets.apiKey.trim();
    if (apiKey.isEmpty) {
      throw const UnexpectedFailure(
        'Trip planner is not set up yet. Deploy plan-trip or add a local Groq key.',
      );
    }

    final vibe = request.vibe.trim();
    if (vibe.length < 2) {
      throw const UnexpectedFailure('Describe the trip vibe first.');
    }

    final dayCount = request.dayCount.clamp(1, 14);
    final must = request.mustInclude.trim().isEmpty
        ? 'none'
        : request.mustInclude.trim();

    try {
      final response = await _client.post(
        _endpoint,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'temperature': 0.7,
          'response_format': {'type': 'json_object'},
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are Orbit, a poetic travel journal planner. '
                  'Reply with JSON only matching: '
                  '{"title":string,"destination":string,"summary":string,'
                  '"days":[{"dayIndex":number,"title":string,"placeHint":string,'
                  '"entryPrompt":string}]}. '
                  'dayIndex starts at 1. placeHint MUST be a real searchable '
                  'landmark or neighborhood name (good for photos). '
                  'entryPrompt is a short journal spark (1-2 sentences). '
                  'Keep titles evocative, not generic.',
            },
            {
              'role': 'user',
              'content':
                  'Plan a $dayCount-day travel journal for Orbit Notes.\n'
                  'Vibe: $vibe\n'
                  'Pace: ${request.pace}\n'
                  'Focus: ${request.focus}\n'
                  'Companions: ${request.companions}\n'
                  'Must include: $must\n'
                  'Return exactly $dayCount days.',
            },
          ],
        }),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw UnexpectedFailure(
          'Trip planning failed (${response.statusCode}). Try again.',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        throw const UnexpectedFailure('Could not read the AI plan. Try again.');
      }

      final content =
          decoded['choices']?[0]?['message']?['content']?.toString().trim();
      if (content == null || content.isEmpty) {
        throw const UnexpectedFailure('AI returned an empty plan.');
      }

      final planRaw = jsonDecode(content);
      if (planRaw is! Map) {
        throw const UnexpectedFailure('AI returned an empty plan.');
      }

      return _parsePlan(Map<String, dynamic>.from(planRaw), dayCount);
    } on Failure {
      rethrow;
    } on FormatException {
      throw const UnexpectedFailure('AI plan was incomplete. Try again.');
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
