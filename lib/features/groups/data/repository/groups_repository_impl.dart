import 'package:fpdart/fpdart.dart';
import 'package:splitzy/core/error/errors.dart';
import 'package:splitzy/features/groups/data/datasource/groups_remote_data_source.dart';
import 'package:splitzy/features/groups/domain/entities/group_entity.dart';
import 'package:splitzy/features/groups/domain/repository/groups_repository.dart';

class GroupsRepositoryImpl implements GroupsRepository {
  final GroupsRemoteDatasource _datasource;
  const GroupsRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, List<GroupEntity>>> getGroups() async {
    try {
      final groups = await _datasource.getGroups();
      return Right(groups);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, GroupEntity>> getGroup(String groupId) async {
    try {
      final group = await _datasource.getGroup(groupId);
      return Right(group);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, GroupEntity>> createGroup(
      String name, List<String> memberIds) async {
    try {
      final group = await _datasource.createGroup(name, memberIds);
      return Right(group);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addMember(String groupId, String userId) async {
    try {
      await _datasource.addMember(groupId, userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<GroupEntity>>> watchGroups() {
    return _datasource.watchGroups().map(
      (groups) => Right<Failure, List<GroupEntity>>(groups),
    ).handleError(
      (e) => Left<Failure, List<GroupEntity>>(
        ServerFailure(message: e.toString()),
      ),
    );
  }
}
