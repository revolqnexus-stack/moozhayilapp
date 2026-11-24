import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/models/aura_session.dart';
import '../../../core/services/api_service.dart';
import '../../auth/providers/auth_provider.dart';

part 'aura_provider.g.dart';

class AuraRepository {
  const AuraRepository(this._apiService);

  final ApiService _apiService;

  Future<AuraInsightResponse> insight() async {
    try {
      final response = await _apiService.client.post<Map<String, dynamic>>(
        '/aura/insight',
      );
      return AuraInsightResponse.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<AuraPlanResponse> plan({
    required String occasion,
    required String targetDate,
    required int budgetPaise,
  }) async {
    try {
      final response = await _apiService.client.post<Map<String, dynamic>>(
        '/aura/plan',
        data: {
          'occasion': occasion,
          'target_date': targetDate,
          'budget_paise': budgetPaise,
        },
      );
      return AuraPlanResponse.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<AuraDiscoverResponse> discover({
    required String forPerson,
    required String occasion,
    required int budgetPaise,
  }) async {
    try {
      final response = await _apiService.client.post<Map<String, dynamic>>(
        '/aura/discover',
        data: {
          'for_person': forPerson,
          'occasion': occasion,
          'budget_paise': budgetPaise,
        },
      );
      return AuraDiscoverResponse.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<CreateAuraSessionResponse> createSession({
    required String flowType,
  }) async {
    try {
      final response = await _apiService.client.post<Map<String, dynamic>>(
        '/aura/sessions',
        data: {'flow_type': flowType},
      );
      return CreateAuraSessionResponse.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<AuraMessageResponse> postMessage({
    required String sessionId,
    required String message,
    String? currentGoalId,
    String? viewingProductId,
  }) async {
    try {
      final response = await _apiService.client.post<Map<String, dynamic>>(
        '/aura/sessions/$sessionId/messages',
        data: {
          'message': message,
          if (currentGoalId != null || viewingProductId != null)
            'context': {
              'current_goal_id': currentGoalId,
              'viewing_product_id': viewingProductId,
            },
        },
      );
      return AuraMessageResponse.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}

@riverpod
AuraRepository auraRepository(Ref ref) {
  return AuraRepository(ref.watch(apiServiceProvider));
}

@riverpod
Future<AuraInsightResponse> auraInsight(Ref ref) async {
  if (watchSignedInUserId(ref) == null) {
    return const AuraInsightResponse(
      insightText:
          'Sign in to get personalised gold insights and jewellery guidance.',
      insightType: 'onboarding',
      linkRoute: '/auth',
    );
  }

  return ref.watch(auraRepositoryProvider).insight();
}

@riverpod
class AuraConversation extends _$AuraConversation {
  @override
  FutureOr<List<AuraConversationMessage>> build(String sessionId) => [];

  Future<AuraMessageResponse> sendMessage(String message) async {
    final previousMessages = state.value ?? [];
    final userMessage = AuraConversationMessage(role: 'user', content: message);
    state = AsyncData([...previousMessages, userMessage]);

    try {
      final response = await ref
          .read(auraRepositoryProvider)
          .postMessage(sessionId: sessionId, message: message);

      final auraMessage = AuraConversationMessage(
        role: 'aura',
        content: response.response.text,
        action: response.response.action,
        products: response.response.products,
      );

      state = AsyncData([...?state.value, auraMessage]);
      return response;
    } catch (error, stackTrace) {
      // Roll back the user message so the conversation isn't left in a broken
      // state with a dangling unanswered message.
      state = AsyncData(previousMessages);
      // Rethrow so the UI can display an appropriate error to the user.
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}

@riverpod
class AuraActions extends _$AuraActions {
  @override
  FutureOr<void> build() {}

  Future<AuraPlanResponse> plan({
    required String occasion,
    required String targetDate,
    required int budgetPaise,
  }) async {
    return ref
        .read(auraRepositoryProvider)
        .plan(
          occasion: occasion,
          targetDate: targetDate,
          budgetPaise: budgetPaise,
        );
  }

  Future<AuraDiscoverResponse> discover({
    required String forPerson,
    required String occasion,
    required int budgetPaise,
  }) async {
    return ref
        .read(auraRepositoryProvider)
        .discover(
          forPerson: forPerson,
          occasion: occasion,
          budgetPaise: budgetPaise,
        );
  }

  Future<String> startChatSession() async {
    final response = await ref
        .read(auraRepositoryProvider)
        .createSession(flowType: 'chat');
    return response.sessionId;
  }

  Future<void> refreshInsight() async {
    ref.invalidate(auraInsightProvider);
    await ref.read(auraInsightProvider.future);
  }
}
