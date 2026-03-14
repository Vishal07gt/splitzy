import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:splitzy/core/ui_states/ui_states.dart';
import 'package:splitzy/features/friends/domain/entities/friend_entity.dart';
import 'package:splitzy/features/friends/presentation/cubit/friends_cubit.dart';
import 'package:splitzy/features/groups/domain/entities/group_entity.dart';
import 'package:splitzy/features/groups/presentation/cubit/groups_cubit.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final _nameController = TextEditingController();
  final _selectedMemberIds = <String>{};

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Group')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 24),
            const Text('Add Friends',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Expanded(
              child: BlocBuilder<FriendsCubit,
                  UiStates<List<FriendEntity>>>(
                builder: (context, state) {
                  if (state is Progress<List<FriendEntity>>) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is Error<List<FriendEntity>>) {
                    return Center(child: SelectableText('Error: ${state.message}'));
                  }
                  if (state is Success<List<FriendEntity>>) {
                    final friends = state.data;
                    if (friends.isEmpty) {
                      return const Center(
                        child: Text('Add some friends first to create a group'),
                      );
                    }
                    return ListView.builder(
                      itemCount: friends.length,
                      itemBuilder: (_, i) {
                        final friend = friends[i];
                        final isSelected =
                            _selectedMemberIds.contains(friend.friend.id);
                        return CheckboxListTile(
                          value: isSelected,
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                _selectedMemberIds.add(friend.friend.id);
                              } else {
                                _selectedMemberIds.remove(friend.friend.id);
                              }
                            });
                          },
                          title: Text(friend.friend.name),
                          subtitle: Text(friend.friend.email),
                          secondary: CircleAvatar(
                            child: Text(
                              friend.friend.name.isNotEmpty
                                  ? friend.friend.name[0].toUpperCase()
                                  : '?',
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                final name = _nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter a group name')),
                  );
                  return;
                }
                final cubit = context.read<GroupsCubit>();
                await cubit.createGroup(
                  name,
                  _selectedMemberIds.toList(),
                );
                if (context.mounted) {
                  final state = cubit.state;
                  if (state is Error<List<GroupEntity>>) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: SelectableText(state.message)),
                    );
                  } else {
                    context.pop(true);
                  }
                }
              },
              child: const Text('Create Group'),
            ),
          ],
        ),
      ),
    );
  }
}
