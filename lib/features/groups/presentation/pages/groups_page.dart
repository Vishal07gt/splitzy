import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:splitzy/core/ui_states/ui_states.dart';
import 'package:splitzy/features/groups/domain/entities/group_entity.dart';
import 'package:splitzy/features/groups/presentation/cubit/groups_cubit.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () => context.push('/friends'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push('/groups/create');
          if (result == true && context.mounted) {
            context.read<GroupsCubit>().loadGroups();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<GroupsCubit, UiStates<List<GroupEntity>>>(
        builder: (context, state) {
          if (state is Progress<List<GroupEntity>>) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is Error<List<GroupEntity>>) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SelectableText('Error: ${state.message}'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<GroupsCubit>().loadGroups(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is Success<List<GroupEntity>>) {
            final groups = state.data;
            if (groups.isEmpty) {
              return const _EmptyGroups();
            }
            return RefreshIndicator(
              onRefresh: () => context.read<GroupsCubit>().loadGroups(),
              child: ListView.separated(
                itemCount: groups.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (_, i) => _GroupTile(group: groups[i]),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class _GroupTile extends StatelessWidget {
  final GroupEntity group;
  const _GroupTile({required this.group});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(
          group.name.isNotEmpty ? group.name[0].toUpperCase() : '?',
        ),
      ),
      title: Text(group.name),
      subtitle: Text('${group.members.length} members'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push('/groups/${group.id}'),
    );
  }
}

class _EmptyGroups extends StatelessWidget {
  const _EmptyGroups();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.group_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No groups yet', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          const Text('Create a group to start splitting expenses',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () async {
              final result = await context.push('/groups/create');
              if (result == true && context.mounted) {
                context.read<GroupsCubit>().loadGroups();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Group'),
          ),
        ],
      ),
    );
  }
}
