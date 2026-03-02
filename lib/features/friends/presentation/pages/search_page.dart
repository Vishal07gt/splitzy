import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitzy/core/ui_states/ui_states.dart';
import 'package:splitzy/features/auth/domain/entities/user_entity.dart';
import 'package:splitzy/features/friends/presentation/cubit/friends_cubit.dart';
import 'package:splitzy/features/friends/presentation/cubit/search_cubit.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();

  // track which users have pending requests sent
  final _sentRequests = <String>{};

  @override
  void dispose() {
    _searchController.dispose();
    context.read<SearchCubit>().clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search by name or email...',
            border: InputBorder.none,
          ),
          onChanged: (query) => context.read<SearchCubit>().search(query),
        ),
      ),
      body: BlocBuilder<SearchCubit, UiStates<List<User>>>(
        builder: (context, state) {
          if (state is Progress<List<User>>) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is Error<List<User>>) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is Success<List<User>>) {
            final users = state.data;
            if (users.isEmpty) {
              return const Center(
                child: Text(
                  'No users found',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }
            return ListView.separated(
              itemCount: users.length,
              separatorBuilder: (ctx, i) => const Divider(height: 1),
              itemBuilder: (_, i) => _SearchResultTile(
                user: users[i],
                requestSent: _sentRequests.contains(users[i].id),
                onAdd: () => _sendRequest(users[i]),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Future<void> _sendRequest(User user) async {
    await context.read<FriendsCubit>().sendRequest(user.id);

    setState(() => _sentRequests.add(user.id));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Friend request sent to ${user.name}')),
      );
    }
  }
}

class _SearchResultTile extends StatelessWidget {
  final User user;
  final bool requestSent;
  final VoidCallback onAdd;

  const _SearchResultTile({
    required this.user,
    required this.requestSent,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(
          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
        ),
      ),
      title: Text(user.name),
      subtitle: Text(user.email),
      trailing: requestSent
          ? const Chip(label: Text('Sent ✓'))
          : IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: onAdd,
            ),
    );
  }
}
