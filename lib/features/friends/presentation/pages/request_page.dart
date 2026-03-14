import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitzy/core/ui_states/ui_states.dart';
import 'package:splitzy/features/friends/domain/entities/friend_request_entity.dart';
import 'package:splitzy/features/friends/presentation/cubit/friends_cubit.dart';
import 'package:splitzy/features/friends/presentation/cubit/incoming_requests_cubit.dart';

class RequestsPage extends StatelessWidget {
  const RequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Friend Requests')),
      body: BlocBuilder<IncomingRequestsCubit,
          UiStates<List<FriendRequestEntity>>>(
        builder: (context, state) {
          if (state is Progress<List<FriendRequestEntity>> ||
              state is DefaultState<List<FriendRequestEntity>>) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is Error<List<FriendRequestEntity>>) {
            return Center(child: SelectableText('Error: ${state.message}'));
          }
          if (state is Success<List<FriendRequestEntity>>) {
            final requests = state.data;
            if (requests.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No pending requests'),
                  ],
                ),
              );
            }
            return ListView.separated(
              itemCount: requests.length,
              separatorBuilder: (ctx, i) => const Divider(height: 1),
              itemBuilder: (_, i) => _RequestTile(request: requests[i]),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class _RequestTile extends StatelessWidget {
  final FriendRequestEntity request;
  const _RequestTile({required this.request});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(
          request.requester.name.isNotEmpty
              ? request.requester.name[0].toUpperCase()
              : '?',
        ),
      ),
      title: Text(request.requester.name),
      subtitle: Text(request.requester.email),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Accept
          IconButton(
            icon: const Icon(Icons.check_circle, color: Colors.green),
            onPressed: () async {
              await context.read<FriendsCubit>().acceptRequest(request.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${request.requester.name} added as friend'),
                  ),
                );
              }
            },
          ),
          // Reject
          IconButton(
            icon: const Icon(Icons.cancel, color: Colors.red),
            onPressed: () async {
              await context.read<FriendsCubit>().rejectRequest(request.id);
            },
          ),
        ],
      ),
    );
  }
}
