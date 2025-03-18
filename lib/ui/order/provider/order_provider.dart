import 'package:flutter/material.dart';
import 'package:otk_master/services/http_service.dart';
import 'package:otk_master/utils/widgets/custom_snackbars.dart';

enum OrderStatus { tailoring, tailored, checking, checked }

class OrderProvider extends ChangeNotifier {
  OrderStatus _orderStatus = OrderStatus.tailoring;
  OrderStatus get orderStatus => _orderStatus;
  set orderStatus(OrderStatus value) {
    _orderStatus = value;
    notifyListeners();

    orders = [];

    getOrders();
  }

  List _orders = [];
  List get orders => _orders;
  set orders(List value) {
    _orders = value;
    notifyListeners();
  }

  List _groups = [];
  List get groups => _groups;
  set groups(List value) {
    _groups = value;
    notifyListeners();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool _isGettingOrders = false;
  bool get isGettingOrders => _isGettingOrders;
  set isGettingOrders(bool value) {
    _isGettingOrders = value;
    notifyListeners();
  }

  OrderProvider();

  void initialize() async {
    isLoading = true;

    await getOrders();
    await getGroups();

    isLoading = false;
  }

  Future<void> getOrders() async {
    isGettingOrders = true;

    String status = "";

    switch (orderStatus) {
      case OrderStatus.tailoring:
        status = 'tailoring';
        break;
      case OrderStatus.tailored:
        status = 'tailored';
        break;
      case OrderStatus.checking:
        status = 'checking';
        break;
      case OrderStatus.checked:
        status = 'checked';
        break;
    }

    var res = await HttpService.get(Api.orders, param: {'status': status});
    if (res['status'] == Result.success) {
      orders = res['data'] ?? [];
    }

    isGettingOrders = false;
  }

  Future<void> getGroups() async {
    var res = await HttpService.get(Api.groups);
    if (res['status'] == Result.success) {
      groups = res['data'] ?? [];
    }
  }

  Future<void> fasteningSubmodelsToGroups(
    BuildContext context,
    int submodelId,
    int groupId,
  ) async {
    var res = await HttpService.post(Api.fasteningOrderToGroup, {
      "order_sub_model_id": submodelId,
      "group_id": groupId,
    });

    if (res['status'] == Result.success) {
      CustomSnackbars(context).success("Muvaffaqiyatli bog'landi");

      initialize();
    } else {
      CustomSnackbars(context).error("Bog'lashda xatolik yuz berdi!");
    }
  }

  Future<void> changeOrderStatus(
    BuildContext context,
    int orderId,
    String status,
  ) async {
    var canChange = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Buyurtma holatini o'zgartirish"),
          content: Text.rich(
            TextSpan(
              text: "Buyurtma holatini ",
              children: [
                TextSpan(
                  text: status == "checking" ? "tekshirishni boshlash" : "tekshirishni yakunlash",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: "ga o'tkazmoqchimisiz?"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text("Bekor qilish"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text("Tasdiqlash"),
            ),
          ],
        );
      },
    );

    if (canChange == null || !canChange) return;

    var res = await HttpService.post(Api.changeOrderStatus, {
      "order_id": orderId,
      "status": status,
    });

    if (res['status'] == Result.success) {
      initialize();
    }
  }
}
