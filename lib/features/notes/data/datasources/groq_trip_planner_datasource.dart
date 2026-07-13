import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:orbit_notes/core/config/groq_config.dart';
import 'package:orbit_notes/core/failure/failure.dart';
import 'package:orbit_notes/features/notes/domain/entities/planned_trip.dart';
import 'package:orbit_notes/features/notes/domain/repositories/trip_planner_repository.dart';

class GroqTripPlannerDataSource implements TripPlannerRepository {
  GroqTripPlannerDataSource({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<PlannedTrip> planTrip(TripPlanRequest request) async {
    if (!GroqConfig.isConfigured) {
      throw const UnexpectedFailure(
        'Add GROQ_API_KEY via --dart-define to plan trips with AI.',
      );
    }

    final uri = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
    final body = {
      'model': GroqConfig.model,
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
              'entryPrompt is a short journal spark '
              '(1-2 sentences). Keep titles evocative, not generic.',
        },
        {
          'role': 'user',
          'content': _userPrompt(request),
        },
      ],
    };

    try {
      final response = await _client
          .post(
            uri,
            headers: {
              'Authorization': 'Bearer ${GroqConfig.apiKey}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 45));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw UnexpectedFailure(
          'Trip planning failed (${response.statusCode}). Try again.',
        );
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = decoded['choices'];
      if (choices is! List || choices.isEmpty) {
        throw const UnexpectedFailure('AI returned an empty plan.');
      }
      final message = choices.first as Map<String, dynamic>;
      final content =
          ((message['message'] as Map?)?['content'] as String?)?.trim();
      if (content == null || content.isEmpty) {
        throw const UnexpectedFailure('AI returned an empty plan.');
      }

      final planJson = jsonDecode(content) as Map<String, dynamic>;
      return _parsePlan(planJson, request.dayCount);
    } on Failure {
      rethrow;
    } on FormatException {
      throw const UnexpectedFailure('Could not read the AI plan. Try again.');
    } catch (_) {
      throw const UnexpectedFailure(
        'Could not reach Groq. Check connection and API key.',
      );
    }
  }

  String _userPrompt(TripPlanRequest request) {
    final must = request.mustInclude.trim().isEmpty
        ? 'none'
        : request.mustInclude.trim();
    return '''
Plan a ${request.dayCount}-day travel journal for Orbit Notes.
Vibe: ${request.vibe}
Pace: ${request.pace}
Focus: ${request.focus}
Companions: ${request.companions}
Must include: $must
Return exactly ${request.dayCount} days.
''';
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
      days.add(
        PlannedTripDay(
          dayIndex: index,
          title: dayTitle.isEmpty ? 'Day $index' : dayTitle,
          entryPrompt: prompt,
          placeHint: '${map['placeHint'] ?? ''}'.trim().isEmpty
              ? null
              : '${map['placeHint']}'.trim(),
        ),
      );
    }

    if (days.isEmpty) {
      throw const UnexpectedFailure('AI plan had no days. Try again.');
    }

    days.sort((a, b) => a.dayIndex.compareTo(b.dayIndex));
    final trimmed = days.take(dayCount).toList();
    return PlannedTrip(
      title: title,
      destination: destination,
      summary: summary.isEmpty ? 'A trip shaped for your journal.' : summary,
      days: trimmed,
    );
  }
}
