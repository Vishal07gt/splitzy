import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitzy/core/ui_states/ui_states.dart';
import 'package:splitzy/features/groups/domain/entities/group_entity.dart';
import 'package:splitzy/features/groups/domain/usecases/groups_usecases.dart';

class GroupDetailCubit extends Cubit<UiStates<GroupEntity>> {
  final GetGroupUsecase getGroupUsecase;
  final AddMemberUsecase addMemberUsecase;

  GroupDetailCubit({
    required this.getGroupUsecase,
    required this.addMemberUsecase,
  }) : super(DefaultState<GroupEntity>());

  Future<void> loadGroup(String groupId) async {
    emit(Progress<GroupEntity>());
    final result = await getGroupUsecase.call(
      GetGroupParams(groupId: groupId),
    );
    result.fold(
      (failure) => emit(Error<GroupEntity>(failure.message)),
      (group) => emit(Success<GroupEntity>(group)),
    );
  }

  Future<void> addMember(String groupId, String userId) async {
    final result = await addMemberUsecase.call(
      AddMemberParams(groupId: groupId, userId: userId),
    );
    result.fold(
      (failure) => emit(Error<GroupEntity>(failure.message)),
      (_) => loadGroup(groupId),
    );
  }
}
