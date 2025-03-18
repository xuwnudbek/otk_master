import 'package:flutter/material.dart';
import 'package:otk_master/services/http_service.dart';
import 'package:otk_master/utils/extensions/datetime_extension.dart';

class ResultProvider extends ChangeNotifier {
  DateTime? _date;
  DateTime? get date => _date;
  set date(value) {
    _date = value;
    notifyListeners();

    initialize();
  }

  List _results = [];
  List get results => _results;
  set results(List results) {
    _results = results;
    notifyListeners();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  void initialize() async {
    isLoading = true;

    await getResults();

    isLoading = false;
  }

  Future<void> getResults() async {
    var res = await HttpService.get(Api.results, param: {
      if (date != null) "date": date!.toYMD,
    });

    if (res['status'] == Result.success) {
      results = res['data'] ?? [];
    }
  }
}
