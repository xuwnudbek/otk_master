import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:otk_master/ui/order/provider/order_provider.dart';
import 'package:otk_master/utils/theme/app_colors.dart';
import 'package:otk_master/utils/widgets/custom_dropdown.dart';
import 'package:provider/provider.dart';

class OrderPage extends StatelessWidget {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Consumer<OrderProvider>(
      builder: (context, provider, _) {
        return LayoutBuilder(builder: (context, constraints) {
          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    provider.initialize();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      spacing: 8,
                      children: [
                        Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.light,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.all(4),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              spacing: 4,
                              children: [
                                ...OrderStatus.values.map((status) {
                                  String statusString = "";

                                  if (OrderStatus.tailoring == status) {
                                    statusString = "Tikilmoqda";
                                  } else if (status == OrderStatus.tailored) {
                                    statusString = "Tikib bo'lingan";
                                  } else if (status == OrderStatus.checking) {
                                    statusString = "Tekshirilmoqda";
                                  } else if (status == OrderStatus.checked) {
                                    statusString = "Tekshirilgan";
                                  }

                                  return GestureDetector(
                                    onTap: () {
                                      provider.orderStatus = status;
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: provider.orderStatus == status ? AppColors.primary : AppColors.secondary,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        statusString,
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: provider.orderStatus == status ? AppColors.light : AppColors.dark,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: (provider.orders.isEmpty || provider.isLoading) ? 1 : provider.orders.length,
                            itemExtent: (provider.orders.isEmpty || provider.isLoading) ? constraints.maxHeight : null,
                            itemBuilder: (context, index) {
                              if (provider.isLoading || provider.isGettingOrders) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              if (provider.orders.isEmpty) {
                                return Center(
                                  child: Text('Buyurtmalar topilmadi'),
                                );
                              }

                              final order = provider.orders[index];

                              String status = order['status'] == "tailoring"
                                  ? "Tikilmoqda"
                                  : order['status'] == "tailored"
                                      ? "Tikib bo'lingan"
                                      : "Noma'lum";

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: ExpansionTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  backgroundColor: AppColors.light,
                                  collapsedBackgroundColor: AppColors.light,
                                  title: Text.rich(
                                    TextSpan(
                                      text: '#${order['id']}',
                                      style: textTheme.titleLarge?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: ' / ${order['name']}',
                                          style: textTheme.titleMedium?.copyWith(
                                            color: AppColors.dark,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  childrenPadding: EdgeInsets.all(16),
                                  expandedAlignment: Alignment.centerLeft,
                                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // model
                                    Row(
                                      children: [
                                        Text.rich(
                                          TextSpan(
                                            text: 'Model:',
                                            style: textTheme.bodyMedium,
                                            children: [
                                              TextSpan(
                                                text: ' ${order['order_model']?['model']?['name'] ?? "Unknown"}',
                                                style: textTheme.titleMedium,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    // mato
                                    Row(
                                      children: [
                                        Text.rich(
                                          TextSpan(
                                            text: 'Mato:',
                                            style: textTheme.bodyMedium,
                                            children: [
                                              TextSpan(
                                                text: ' ${order['order_model']?['material']?['name'] ?? "Nomalum"}',
                                                style: textTheme.titleMedium,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    // status
                                    Row(
                                      children: [
                                        Text(
                                          "Holat: ",
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          child: Text(
                                            status,
                                            style: textTheme.bodySmall?.copyWith(
                                              color: AppColors.light,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    // submodellar
                                    Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text.rich(
                                              TextSpan(
                                                text: 'Submodellar:',
                                                style: textTheme.bodyMedium,
                                              ),
                                            ),
                                            Wrap(
                                              spacing: 4,
                                              runSpacing: 4,
                                              children: [
                                                for (final submodel in order['order_model']?['submodels'] ?? [])
                                                  Chip(
                                                    padding: EdgeInsets.all(4),
                                                    backgroundColor: AppColors.primary,
                                                    label: Text(
                                                      submodel?['submodel']?['name'] ?? 'Unknown',
                                                      style: textTheme.bodyMedium?.copyWith(
                                                        color: AppColors.light,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text.rich(
                                              TextSpan(
                                                text: 'O\'lchamlar:',
                                                style: textTheme.bodyMedium,
                                              ),
                                            ),
                                            Wrap(
                                              spacing: 4,
                                              runSpacing: 4,
                                              children: [
                                                for (final size in order['order_model']?['sizes'] ?? [])
                                                  Chip(
                                                    padding: EdgeInsets.all(4),
                                                    backgroundColor: AppColors.primary,
                                                    label: Text(
                                                      size['size']?['name'] ?? 'Unknown',
                                                      style: textTheme.bodyMedium?.copyWith(
                                                        color: AppColors.light,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    ...((order['order_model']?['submodels'] ?? []) as List).map((submodel) {
                                      inspect(provider.groups);

                                      return DecoratedBox(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            top: BorderSide(color: AppColors.dark.withValues(alpha: 0.1)),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Row(
                                            spacing: 8,
                                            children: [
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                  child: Text(
                                                    "${submodel['submodel']?['name'] ?? "Nomalum"}",
                                                    style: textTheme.titleMedium,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: CustomDropdown(
                                                  value: submodel['group']?['id'] ?? 0,
                                                  hint: "Guruh",
                                                  items: [
                                                    DropdownMenuItem(
                                                      value: 0,
                                                      child: Text(
                                                        "Guruhni tanlang",
                                                        style: textTheme.titleSmall?.copyWith(
                                                          color: AppColors.dark.withValues(alpha: 0.2),
                                                        ),
                                                      ),
                                                    ),
                                                    ...provider.groups.map((gr) {
                                                      return DropdownMenuItem(
                                                        value: gr['id'],
                                                        child: Text(
                                                          "${gr['name'] ?? "Noma'lum"}",
                                                        ),
                                                      );
                                                    }),
                                                  ],
                                                  onChanged: (value) async {
                                                    await provider.fasteningSubmodelsToGroups(
                                                      context,
                                                      submodel['id'],
                                                      value,
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),

                                    SizedBox(height: 8),
                                    Row(
                                      spacing: 8,
                                      children: [
                                        if (provider.orderStatus == OrderStatus.checking)
                                          Expanded(
                                            child: TextButton(
                                              style: TextButton.styleFrom(
                                                backgroundColor: AppColors.primary,
                                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                              ),
                                              onPressed: () async {
                                                await provider.changeOrderStatus(
                                                  context,
                                                  order['id'],
                                                  "checked",
                                                );
                                              },
                                              child: Text(
                                                'Tekshiruvni yakunlash',
                                                style: textTheme.titleSmall?.copyWith(
                                                  color: AppColors.light,
                                                ),
                                              ),
                                            ),
                                          ),
                                        if (provider.orderStatus == OrderStatus.tailored)
                                          Expanded(
                                            child: TextButton(
                                              style: TextButton.styleFrom(
                                                backgroundColor: AppColors.success,
                                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                              ),
                                              onPressed: () async {
                                                await provider.changeOrderStatus(
                                                  context,
                                                  order['id'],
                                                  "checking",
                                                );
                                              },
                                              child: Text(
                                                'Boshlash',
                                                style: textTheme.titleSmall?.copyWith(
                                                  color: AppColors.light,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        });
      },
    );
  }
}
