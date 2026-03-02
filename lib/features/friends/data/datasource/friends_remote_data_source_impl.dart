import 'dart:async';

import 'package:splitzy/features/auth/data/model/user_model.dart';
import 'package:splitzy/features/auth/domain/entities/user_entity.dart';
import 'package:splitzy/features/friends/data/models/friend_model.dart';
import 'package:splitzy/features/friends/data/models/friend_request_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import 'friends_remote_data_source.dart';


// ── Implementation ────────────────────────────────────────────
class FriendsRemoteDatasourceImpl implements FriendsRemoteDatasource {
  final SupabaseClient _client;
  FriendsRemoteDatasourceImpl(this._client);

  String get _currentUserId => _client.auth.currentUser!.id;

  // ── Search users ────────────────────────────────────────────
  @override
  Future<List<User>> searchUsers(String query) async {
    final response = await _client
        .from('users')
        .select('id, name, email, avatar_url')
        .or('name.ilike.%$query%, email.ilike.%$query%')
        .neq('id', _currentUserId) // exclude self
        .limit(20);

    return (response as List)
        .map((json) => UserModel.fromjson(json as Map<String, dynamic>))
        .toList();
  }

  // ── Send friend request ─────────────────────────────────────
  @override
  Future<void> sendFriendRequest(String addresseeId) async {
    await _client.from('friendships').insert({
      'requester_id': _currentUserId,
      'addressee_id': addresseeId,
      'status':       'pending',
      'source':       'manual',
    });
  }

  // ── Accept friend request ───────────────────────────────────
  @override
  Future<void> acceptFriendRequest(String friendshipId) async {
    await _client
        .from('friendships')
        .update({'status': 'accepted'})
        .eq('id', friendshipId);
  }

  // ── Reject friend request ───────────────────────────────────
  @override
  Future<void> rejectFriendRequest(String friendshipId) async {
    await _client
        .from('friendships')
        .update({'status': 'rejected'})
        .eq('id', friendshipId);
  }

  // ── Get all accepted friends ────────────────────────────────
  @override
  Future<List<FriendModel>> getFriends() async {
    final response = await _client
        .from('friendships')
        .select('''
          id,
          requester_id,
          addressee_id,
          source,
          created_at,
          requester:users!friendships_requester_id_fkey(id, name, email, avatar_url),
          addressee:users!friendships_addressee_id_fkey(id, name, email, avatar_url)
        ''')
        .eq('status', 'accepted')
        .or('requester_id.eq.$_currentUserId,addressee_id.eq.$_currentUserId');

    return (response as List)
        .map((json) => FriendModel.fromJson(
      json as Map<String, dynamic>,
      _currentUserId,
    ))
        .toList();
  }

  // ── Watch incoming requests — Realtime ⚡ ───────────────────
  @override
  Stream<List<FriendRequestModel>> watchIncomingRequests() {
    // Initial fetch + realtime updates
    final controller = StreamController<List<FriendRequestModel>>.broadcast();

    // Fetch initial data
    _fetchIncomingRequests().then((requests) {
      if (!controller.isClosed) controller.add(requests);
    });

    // Subscribe to realtime changes on friendships table
    _client
        .channel('user_requests:$_currentUserId')
        .onPostgresChanges(
      event:  PostgresChangeEvent.all,
      schema: 'public',
      table:  'friendships',
      filter: PostgresChangeFilter(
        type:   PostgresChangeFilterType.eq,
        column: 'addressee_id',
        value:  _currentUserId,
      ),
      callback: (_) async {
        // refetch on any change
        final updated = await _fetchIncomingRequests();
        if (!controller.isClosed) controller.add(updated);
      },
    )
        .subscribe();

    return controller.stream;
  }

  Future<List<FriendRequestModel>> _fetchIncomingRequests() async {
    final response = await _client
        .from('friendships')
        .select('''
          id,
          status,
          created_at,
          requester:users!friendships_requester_id_fkey(id, name, email, avatar_url),
          addressee:users!friendships_addressee_id_fkey(id, name, email, avatar_url)
        ''')
        .eq('addressee_id', _currentUserId)
        .eq('status', 'pending');

    return (response as List)
        .map((json) => FriendRequestModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}