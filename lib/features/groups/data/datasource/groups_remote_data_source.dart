import 'package:splitzy/features/groups/data/models/group_model.dart';

abstract class GroupsRemoteDatasource {
  Future<List<GroupModel>> getGroups();
  Future<GroupModel> getGroup(String groupId);
  Future<GroupModel> createGroup(String name, List<String> memberIds);
  Future<void> addMember(String groupId, String userId);
  Stream<List<GroupModel>> watchGroups();
}
