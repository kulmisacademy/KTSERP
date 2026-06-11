import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:uuid/uuid.dart';



import '../../../core/l10n/l10n_extension.dart';

import '../../../core/ux/user_friendly_error.dart';

import '../../../core/store_context.dart';

import '../../../data/local/app_database.dart';

import '../../../data/local/db_provider.dart';

import '../../../ui/components/app_button.dart';

import '../../../ui/components/app_empty_state.dart';

import '../../../ui/components/app_input.dart';

import '../../../ui/layout/app_shell.dart';



const _uuid = Uuid();



final categoriesListProvider = StreamProvider.autoDispose<List<Category>>((ref) {

  final db = ref.watch(appDatabaseProvider);

  return db.watchCategories(storeId: StoreContext.storeId);

});



class CategoriesPage extends ConsumerWidget {

  const CategoriesPage({super.key});



  @override

  Widget build(BuildContext context, WidgetRef ref) {

    final categories = ref.watch(categoriesListProvider);

    final l10n = context.l10n;



    return AppShell(

      route: '/categories',

      actions: [

        FilledButton.icon(

          onPressed: () => _showCategoryDialog(context, ref),

          icon: const Icon(Icons.add, size: 18),

          label: Text(l10n.commonAdd),

        ),

      ],

      child: categories.when(

        data: (rows) {

          if (rows.isEmpty) {

            return AppEmptyState(

              title: l10n.noCategories,

              subtitle: l10n.noCategoriesSubtitle,

              icon: Icons.category_outlined,

              action: AppButton(

                label: l10n.commonAdd,

                onPressed: () => _showCategoryDialog(context, ref),

              ),

            );

          }

          return ListView.separated(

            itemCount: rows.length,

            separatorBuilder: (_, __) => const Divider(height: 1),

            itemBuilder: (context, index) {

              final c = rows[index];

              return ListTile(

                leading: const Icon(Icons.label_outline),

                title: Text(c.name),

                trailing: PopupMenuButton<String>(

                  onSelected: (action) async {

                    if (action == 'edit') {

                      await _showCategoryDialog(context, ref, existing: c);

                    } else if (action == 'delete') {

                      final ok = await showDialog<bool>(

                        context: context,

                        builder: (ctx) => AlertDialog(

                          title: Text(l10n.deleteCategoryTitle),

                          content: Text(l10n.removeItemConfirm(c.name)),

                          actions: [

                            TextButton(

                              onPressed: () => Navigator.pop(ctx, false),

                              child: Text(l10n.commonCancel),

                            ),

                            FilledButton(

                              onPressed: () => Navigator.pop(ctx, true),

                              child: Text(l10n.commonDelete),

                            ),

                          ],

                        ),

                      );

                      if (ok == true) {

                        await ref

                            .read(appDatabaseProvider)

                            .deleteCategory(c.id);

                      }

                    }

                  },

                  itemBuilder: (_) => [

                    PopupMenuItem(value: 'edit', child: Text(l10n.commonEdit)),

                    PopupMenuItem(value: 'delete', child: Text(l10n.commonDelete)),

                  ],

                ),

              );

            },

          );

        },

        loading: () => const Center(child: CircularProgressIndicator()),

        error: (e, _) => Center(child: Text(userFriendlyError(e, l10n: l10n))),

      ),

    );

  }



  static Future<void> _showCategoryDialog(

    BuildContext context,

    WidgetRef ref, {

    Category? existing,

  }) async {

    final l10n = context.l10n;

    final name = TextEditingController(text: existing?.name ?? '');

    final ok = await showDialog<bool>(

      context: context,

      builder: (ctx) => AlertDialog(

        title: Text(existing == null ? l10n.addCategory : l10n.editCategory),

        content: AppInput(

          controller: name,

          label: l10n.categoryName,

          autofocus: true,

        ),

        actions: [

          TextButton(

            onPressed: () => Navigator.pop(ctx, false),

            child: Text(l10n.commonCancel),

          ),

          FilledButton(

            onPressed: () => Navigator.pop(ctx, true),

            child: Text(l10n.commonSave),

          ),

        ],

      ),

    );

    if (ok != true || name.text.trim().isEmpty) {

      name.dispose();

      return;

    }

    await ref.read(appDatabaseProvider).upsertCategory(

          CategoriesCompanion.insert(

            id: existing?.id ?? _uuid.v4(),

            tenantId: StoreContext.tenantId,

            storeId: StoreContext.storeId,

            name: name.text.trim(),

          ),

        );

    name.dispose();

    if (context.mounted) {

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(content: Text(l10n.categorySaved)),

      );

    }

  }

}

