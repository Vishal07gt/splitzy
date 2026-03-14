import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitzy/core/ui_states/ui_states.dart';
import 'package:splitzy/core/usecases/usecase.dart';
import 'package:splitzy/features/groups/domain/entities/group_entity.dart';
import 'package:splitzy/features/groups/domain/usecases/groups_usecases.dart';

class GroupsCubit extends Cubit<UiStates<List<GroupEntity>>> {
  final GetGroupsUsecase getGroupsUsecase;
  final CreateGroupUsecase createGroupUsecase;

  GroupsCubit({
    required this.getGroupsUsecase,
    required this.createGroupUsecase,
  }) : super(DefaultState<List<GroupEntity>>());

  Future<void> loadGroups() async {
    emit(Progress<List<GroupEntity>>());
    final result = await getGroupsUsecase.call(NoParams());
    result.fold(
      (failure) => emit(Error<List<GroupEntity>>(failure.message)),
      (groups) => emit(Success<List<GroupEntity>>(groups)),
    );
  }

  Future<void> createGroup(String name, List<String> memberIds) async {
    final result = await createGroupUsecase.call(
      CreateGroupParams(name: name, memberIds: memberIds),
    );
    result.fold(
      (failure) => emit(Error<List<GroupEntity>>(failure.message)),
      (_) => loadGroups(),
    );
  }
}
