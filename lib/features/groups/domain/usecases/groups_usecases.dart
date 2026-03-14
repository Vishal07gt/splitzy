import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:splitzy/core/error/errors.dart';
import 'package:splitzy/core/usecases/usecase.dart';
import 'package:splitzy/features/groups/domain/entities/group_entity.dart';
import 'package:splitzy/features/groups/domain/repository/groups_repository.dart';

// ── Get Groups ───────────────────────────────────────────────
class GetGroupsUsecase implements UseCase<List<GroupEntity>, NoParams> {
  final GroupsRepository _repo;
  const GetGroupsUsecase(this._repo);

  @override
  Future<Either<Failure, List<GroupEntity>>> call(NoParams params) =>
      _repo.getGroups();
}

// ── Get Single Group ─────────────────────────────────────────
class GetGroupUsecase implements UseCase<GroupEntity, GetGroupParams> {
  final GroupsRepository _repo;
  const GetGroupUsecase(this._repo);

  @override
  Future<Either<Failure, GroupEntity>> call(GetGroupParams params) =>
      _repo.getGroup(params.groupId);
}

class GetGroupParams extends Equatable {
  final String groupId;
  const GetGroupParams({required this.groupId});

  @override
  List<Object?> get props => [groupId];
}

// ── Create Group ─────────────────────────────────────────────
class CreateGroupUsecase implements UseCase<GroupEntity, CreateGroupParams> {
  final GroupsRepository _repo;
  const CreateGroupUsecase(this._repo);

  @override
  Future<Either<Failure, GroupEntity>> call(CreateGroupParams params) =>
      _repo.createGroup(params.name, params.memberIds);
}

class CreateGroupParams extends Equatable {
  final String name;
  final List<String> memberIds;
  const CreateGroupParams({required this.name, required this.memberIds});

  @override
  List<Object?> get props => [name, memberIds];
}

// ── Add Member ───────────────────────────────────────────────
class AddMemberUsecase implements UseCase<void, AddMemberParams> {
  final GroupsRepository _repo;
  const AddMemberUsecase(this._repo);

  @override
  Future<Either<Failure, void>> call(AddMemberParams params) =>
      _repo.addMember(params.groupId, params.userId);
}

class AddMemberParams extends Equatable {
  final String groupId;
  final String userId;
  const AddMemberParams({required this.groupId, required this.userId});

  @override
  List<Object?> get props => [groupId, userId];
}

// ── Watch Groups (Stream) ────────────────────────────────────
class WatchGroupsUsecase {
  final GroupsRepository _repo;
  const WatchGroupsUsecase(this._repo);

  Stream<Either<Failure, List<GroupEntity>>> call() =>
      _repo.watchGroups();
}
