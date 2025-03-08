import 'package:flutter/material.dart';
import 'package:otk_master/ui/result/provider/result_provider.dart';
import 'package:otk_master/utils/extensions/datetime_extension.dart';
import 'package:otk_master/utils/theme/app_colors.dart';
import 'package:provider/provider.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Consumer<ResultProvider>(
      builder: (context, provider, _) {
        return LayoutBuilder(builder: (context, constraints) {
          return Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.light,
                  borderRadius: BorderRadius.circular(8),
                ),
                margin: EdgeInsets.only(left: 8, top: 8, right: 8),
                padding: EdgeInsets.only(left: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      provider.date != null ? provider.date!.toYMD : DateTime.now().toYMD,
                      style: textTheme.titleMedium,
                    ),
                    Spacer(),
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.light,
                        foregroundColor: AppColors.dark,
                      ),
                      onPressed: () async {
                        var res = await showDatePicker(
                          context: context,
                          initialEntryMode: DatePickerEntryMode.calendarOnly,
                          locale: Locale('uz', "UZ"),
                          firstDate: DateTime.now().subtract(Duration(days: 30)),
                          lastDate: DateTime.now(),
                          confirmText: "Tanlash",
                        );

                        if (res != null) {
                          provider.date = res;
                        }
                      },
                      icon: Icon(
                        Icons.calendar_today_rounded,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    provider.initialize();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      // shrinkWrap: true,
                      itemCount: (provider.results.isEmpty || provider.isLoading) ? 1 : provider.results.length,
                      itemExtent: (provider.results.isEmpty || provider.isLoading) ? constraints.maxHeight * 0.8 : null,
                      itemBuilder: (context, index) {
                        if (provider.isLoading) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (provider.results.isEmpty) {
                          return Center(
                            child: Text('Natijalar topilmadi'),
                          );
                        }

                        final result = provider.results[index];

                        List descriptions = result['descriptions'] ?? [];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: ExpansionTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            collapsedShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: AppColors.light,
                            collapsedBackgroundColor: AppColors.light,
                            title: Text.rich(
                              TextSpan(children: [
                                TextSpan(
                                  text: "#${result['order']['id'] ?? 0}",
                                  style: textTheme.titleMedium?.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                                TextSpan(
                                  text: " - ",
                                  style: textTheme.titleMedium?.copyWith(
                                    color: AppColors.dark.withValues(alpha: 0.5),
                                  ),
                                ),
                                TextSpan(
                                  text: "${result['model']?['name'] ?? "Nomalum"}",
                                  style: textTheme.titleMedium?.copyWith(
                                    color: AppColors.dark.withValues(alpha: 0.5),
                                  ),
                                ),
                              ]),
                            ),
                            subtitle: Text(
                              "${result['submodel']?['name'] ?? "Nomalum"}",
                              style: textTheme.titleSmall?.copyWith(
                                color: AppColors.dark.withValues(alpha: 0.5),
                              ),
                            ),
                            trailing: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: "${result['qualityChecksTrue']}",
                                    style: textTheme.titleLarge?.copyWith(
                                      color: AppColors.success,
                                    ),
                                  ),
                                  TextSpan(
                                    text: " / ",
                                    style: textTheme.titleSmall?.copyWith(
                                      color: AppColors.dark.withValues(alpha: 0.5),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "${result['qualityChecksFalse']}",
                                    style: textTheme.titleLarge?.copyWith(
                                      color: AppColors.danger,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            childrenPadding: EdgeInsets.all(8),
                            children: [
                              ...descriptions.map(
                                (desc) {
                                  return ListTile(
                                    tileColor: AppColors.light,
                                    dense: true,
                                    shape: Border(
                                      top: BorderSide(
                                        color: AppColors.dark.withValues(alpha: 0.1),
                                      ),
                                    ),
                                    title: Text(
                                      "${desc['description'] ?? "Nomalum"}",
                                    ),
                                    trailing: Text(
                                      "${desc['count'] ?? 0}",
                                      style: textTheme.titleMedium,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
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
