import 'dart:async';

import 'package:splitzy/features/settlements/data/models/settlement_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import 'settlements_remote_data_source.dart';

class SettlementsRemoteDatasourceImpl implements SettlementsRemoteDatasource {
  final SupabaseClient _client;
  SettlementsRemoteDatasourceImpl(this._client);

  static const _settlementSelect = '''
    id, group_id, paid_by, paid_to, amount, note, created_at,
    paid_by_user:users!settlements_paid_by_fkey(id, name, email, avatar_url),
    paid_to_user:users!settlements_paid_to_fkey(id, name, email, avatar_url)
  ''';

  // ── Get group settlements ───────────────────────────────────
  @override
  Future<List<SettlementModel>> getGroupSettlements(String groupId) async {
    final response = await _client
        .from('settlements')
        .select(_settlementSelect)
        .eq('group_id', groupId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) =>
            SettlementModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ── Create settlement ───────────────────────────────────────
  @override
  Future<SettlementModel> createSettlement({
    required String groupId,
    required String paidBy,
    required String paidTo,
    required double amount,
    String? note,
  }) async {
    final response = await _client
        .from('settlements')
        .insert({
          'group_id': groupId,
          'paid_by': paidBy,
          'paid_to': paidTo,
          'amount': amount,
          'note': note,
        })
        .select(_settlementSelect)
        .single();

    return SettlementModel.fromJson(response);
  }

  // ── Watch group settlements — Realtime ──────────────────────
  @override
  Stream<List<SettlementModel>> watchGroupSettlements(String groupId) {
    final controller = StreamController<List<SettlementModel>>.broadcast();

    // Initial fetch
    getGroupSettlements(groupId).then((settlements) {
      if (!controller.isClosed) controller.add(settlements);
    });

    // Subscribe to realtime changes on settlements table
    _client
        .channel('group_settlements:$groupId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'settlements',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'group_id',
            value: groupId,
          ),
          callback: (_) async {
            final updated = await getGroupSettlements(groupId);
            if (!controller.isClosed) controller.add(updated);
          },
        )
        .subscribe();

    return controller.stream;
  }
}
