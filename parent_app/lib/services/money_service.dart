import 'package:bunnybank_parent/models/models.dart';
import 'package:bunnybank_parent/services/api_service.dart';

class MoneyService {
  final ApiService _api;

  MoneyService(this._api);

  Future<List<Reason>> getReasons() async {
    final data = await _api.getList('/reasons');
    return data.map((j) => Reason.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<Reason> createReason(String label) async {
    final data = await _api.post('/reasons', {'label': label});
    return Reason.fromJson(data);
  }

  Future<void> deleteReason(String id) async {
    await _api.delete('/reasons/$id');
  }

  Future<Map<String, dynamic>> sendMoney({
    required List<String> childIds,
    required double amount,
    required String reasonId,
  }) async {
    return await _api.post('/send-money', {
      'child_ids': childIds,
      'amount': amount,
      'reason_id': reasonId,
    });
  }
}
