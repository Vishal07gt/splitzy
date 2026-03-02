import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:splitzy/core/ui_states/ui_states.dart';
import 'package:splitzy/features/friends/domain/entities/friend_entity.dart';
import 'package:splitzy/features/friends/domain/entities/friend_request_entity.dart';
import 'package:splitzy/features/friends/presentation/cubit/friends_cubit.dart';
import 'package:splitzy/features/friends/presentation/cubit/incoming_requests_cubit.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        actions: [
          // Incoming requests badge
          BlocBuilder<IncomingRequestsCubit, UiStates<List<FriendRequestEntity>>>(
            builder: (context, state) {
              if (state is Success<List<FriendRequestEntity>> &&
                  state.data.isNotEmpty) {
                return Badge(
                  label: Text('${state.data.length}'),
                  child: IconButton(
                    icon: const Icon(Icons.person_add),
                    onPressed: () => context.push('/friends/requests'),
                  ),
                );
              }
              if (state is DefaultState<List<FriendRequestEntity>>) {
                return const IconButton(
                  icon: Icon(Icons.person_add),
                  onPressed: null,
                );
              }
              return IconButton(
                icon: const Icon(Icons.person_add),
                onPressed: () => context.push('/friends/requests'),
              );
            },
          ),
          // Search button
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/friends/search'),
          ),
        ],
      ),
      body: BlocBuilder<FriendsCubit, UiStates<List<FriendEntity>>>(
        builder: (context, state) {
          if (state is Progress<List<FriendEntity>>) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is Error<List<FriendEntity>>) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<FriendsCubit>().loadFriends(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is Success<List<FriendEntity>>) {
            final friends = state.data;
            if (friends.isEmpty) {
              return _EmptyFriends(
                onSearch: () => context.push('/friends/search'),
              );
            }
            return RefreshIndicator(
              onRefresh: () => context.read<FriendsCubit>().loadFriends(),
              child: ListView.separated(
                itemCount: friends.length,
                separatorBuilder: (ctx, i) => const Divider(height: 1),
                itemBuilder: (_, i) => _FriendTile(friend: friends[i]),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class _FriendTile extends StatelessWidget {
  final FriendEntity friend;
  const _FriendTile({required this.friend});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(
          friend.friend.name.isNotEmpty
              ? friend.friend.name[0].toUpperCase()
              : '?',
        ),
      ),
      title: Text(friend.friend.name),
      subtitle: Text(friend.friend.email),
      trailing: friend.source == FriendSource.group
          ? const Chip(label: Text('via group', style: TextStyle(fontSize: 10)))
          : null,
      onTap: () {
        // TODO: navigate to friend profile/balance screen
      },
    );
  }
}

class _EmptyFriends extends StatelessWidget {
  final VoidCallback onSearch;
  const _EmptyFriends({required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No friends yet', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          const Text('Search for people to add',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onSearch,
            icon: const Icon(Icons.search),
            label: const Text('Find Friends'),
          ),
        ],
      ),
    );
  }
}
