import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:splitzy/core/ui_states/ui_states.dart';
import 'package:splitzy/features/friends/domain/entities/friend_entity.dart';
import 'package:splitzy/features/friends/presentation/cubit/friends_cubit.dart';
import 'package:splitzy/features/groups/domain/entities/group_entity.dart';
import 'package:splitzy/features/groups/presentation/cubit/group_detail_cubit.dart';

class AddMemberPage extends StatelessWidget {
  final String groupId;
  const AddMemberPage({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Member')),
      body: BlocBuilder<GroupDetailCubit, UiStates<GroupEntity>>(
        builder: (context, groupState) {
          final existingMemberIds = <String>{};
          if (groupState is Success<GroupEntity>) {
            existingMemberIds
                .addAll(groupState.data.members.map((m) => m.id));
          }

          return BlocBuilder<FriendsCubit,
              UiStates<List<FriendEntity>>>(
            builder: (context, friendsState) {
              if (friendsState is Progress<List<FriendEntity>>) {
                return const Center(child: CircularProgressIndicator());
              }
              if (friendsState is Error<List<FriendEntity>>) {
                return Center(
                    child: SelectableText('Error: ${friendsState.message}'));
              }
              if (friendsState is Success<List<FriendEntity>>) {
                final available = friendsState.data
                    .where((f) =>
                        !existingMemberIds.contains(f.friend.id))
                    .toList();
                if (available.isEmpty) {
                  return const Center(
                    child: Text('All friends are already in this group'),
                  );
                }
                return ListView.builder(
                  itemCount: available.length,
                  itemBuilder: (_, i) {
                    final friend = available[i];
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
                      trailing: IconButton(
                        icon: const Icon(Icons.person_add),
                        onPressed: () {
                          context
                              .read<GroupDetailCubit>()
                              .addMember(groupId, friend.friend.id);
                          context.pop();
                        },
                      ),
                    );
                  },
                );
              }
              return const SizedBox();
            },
          );
        },
      ),
    );
  }
}
