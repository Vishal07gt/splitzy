import 'dart:async';

import 'package:splitzy/features/groups/data/models/group_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import 'groups_remote_data_source.dart';

class GroupsRemoteDatasourceImpl implements GroupsRemoteDatasource {
  final SupabaseClient _client;
  GroupsRemoteDatasourceImpl(this._client);

  String get _currentUserId => _client.auth.currentUser!.id;

  static const _groupSelect = '''
    id, name, avatar_url, created_by, created_at,
    group_members(
      user:users(id, name, email, avatar_url)
    )
  ''';

  // ── Get all groups ──────────────────────────────────────────
  @override
  Future<List<GroupModel>> getGroups() async {
    final response = await _client
        .from('groups')
        .select(_groupSelect)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => GroupModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ── Get single group ────────────────────────────────────────
  @override
  Future<GroupModel> getGroup(String groupId) async {
    final response = await _client
        .from('groups')
        .select(_groupSelect)
        .eq('id', groupId)
        .single();

    return GroupModel.fromJson(response);
  }

  // ── Create group ────────────────────────────────────────────
  @override
  Future<GroupModel> createGroup(String name, List<String> memberIds) async {
    // 1. Insert the group
    final groupResponse = await _client
        .from('groups')
        .insert({
          'name': name,
          'created_by': _currentUserId,
        })
        .select()
        .single();

    final groupId = groupResponse['id'] as String;

    // 2. Add creator + selected members to group_members
    final allMemberIds = {_currentUserId, ...memberIds};
    await _client.from('group_members').insert(
      allMemberIds.map((uid) => {'group_id': groupId, 'user_id': uid}).toList(),
    );

    // 3. Return full group with members
    return getGroup(groupId);
  }

  // ── Add member ──────────────────────────────────────────────
  @override
  Future<void> addMember(String groupId, String userId) async {
    await _client.from('group_members').insert({
      'group_id': groupId,
      'user_id': userId,
    });
  }

  // ── Watch groups — Realtime ─────────────────────────────────
  @override
  Stream<List<GroupModel>> watchGroups() {
    final controller = StreamController<List<GroupModel>>.broadcast();

    // Initial fetch
    getGroups().then((groups) {
      if (!controller.isClosed) controller.add(groups);
    });

    // Subscribe to realtime changes on group_members table
    _client
        .channel('user_groups:$_currentUserId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'group_members',
          callback: (_) async {
            final updated = await getGroups();
            if (!controller.isClosed) controller.add(updated);
          },
        )
        .subscribe();

    return controller.stream;
  }
}
