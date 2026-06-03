import 'package:bunnybank_parent/models/models.dart';
import 'package:bunnybank_parent/services/api_service.dart';

class ChildrenService {
  final ApiService _api;

  ChildrenService(this._api);

  Future<List<Child>> getChildren() async {
    final data = await _api.getList('/children');
    return data.map((j) => Child.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<Child> createChild({
    required String name,
    required int age,
    required String birthday,
    String? imageUrl,
    required String pin,
  }) async {
    final data = await _api.post('/children', {
      'name': name,
      'age': age,
      'birthday': birthday,
      'image_url': imageUrl,
      'pin': pin,
    });
    return Child.fromJson(data);
  }

  Future<Child> updateChild({
    required String childId,
    required String name,
    required int age,
    required String birthday,
    String? imageUrl,
  }) async {
    final data = await _api.put('/children/$childId', {
      'name': name,
      'age': age,
      'birthday': birthday,
      'image_url': imageUrl,
    });
    return Child.fromJson(data);
  }

  Future<void> deleteChild(String id) async {
    await _api.delete('/children/$id');
  }

  Future<Child> updatePin(String childId, String pin) async {
    final data = await _api.put('/children/$childId/pin', {'pin': pin});
    return Child.fromJson(data);
  }
}
