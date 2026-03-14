import 'package:fpdart/fpdart.dart';
import 'package:splitzy/core/error/errors.dart';
import 'package:splitzy/features/groups/domain/entities/group_entity.dart';

abstract class GroupsRepository {
  /// Get all groups the current user belongs to
  Future<Either<Failure, List<GroupEntity>>> getGroups();

  /// Get a single group by ID with members
  Future<Either<Failure, GroupEntity>> getGroup(String groupId);

  /// Create a new group and add creator as member
  Future<Either<Failure, GroupEntity>> createGroup(String name, List<String> memberIds);

  /// Add a member to a group
  Future<Either<Failure, void>> addMember(String groupId, String userId);

  /// Stream of groups — real-time
  Stream<Either<Failure, List<GroupEntity>>> watchGroups();
}
