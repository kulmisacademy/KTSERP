import 'package:drift/drift.dart' show Value;

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



final brandsListProvider = StreamProvider.autoDispose<List<Brand>>((ref) {

  final db = ref.watch(appDatabaseProvider);

  return db.watchBrands(storeId: StoreContext.storeId);

});



class BrandsPage extends ConsumerWidget {

  const BrandsPage({super.key});



  @override

  Widget build(BuildContext context, WidgetRef ref) {

    final brands = ref.watch(brandsListProvider);

    final l10n = context.l10n;



    return AppShell(

      route: '/brands',

      actions: [

        FilledButton.icon(

          onPressed: () => _showBrandDialog(context, ref),

          icon: const Icon(Icons.add, size: 18),

          label: Text(l10n.commonAdd),

        ),

      ],

      child: brands.when(

        data: (rows) {

          if (rows.isEmpty) {

            return AppEmptyState(

              title: l10n.noBrands,

              subtitle: l10n.noBrandsSubtitle,

              icon: Icons.branding_watermark_outlined,

              action: AppButton(

                label: l10n.commonAdd,

                onPressed: () => _showBrandDialog(context, ref),

              ),

            );

          }

          return ListView.separated(

            itemCount: rows.length,

            separatorBuilder: (_, __) => const Divider(height: 1),

            itemBuilder: (context, index) {

              final b = rows[index];

              return ListTile(

                leading: const Icon(Icons.branding_watermark_outlined),

                title: Text(b.name),

                trailing: PopupMenuButton<String>(

                  onSelected: (action) async {

                    if (action == 'edit') {

                      await _showBrandDialog(context, ref, existing: b);

                    } else if (action == 'delete') {

                      final ok = await showDialog<bool>(

                        context: context,

                        builder: (ctx) => AlertDialog(

                          title: Text(l10n.deleteBrandTitle),

                          content: Text(l10n.removeItemConfirm(b.name)),

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

                        await ref.read(appDatabaseProvider).deleteBrand(b.id);

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



  static Future<void> _showBrandDialog(

    BuildContext context,

    WidgetRef ref, {

    Brand? existing,

  }) async {

    final l10n = context.l10n;

    final name = TextEditingController(text: existing?.name ?? '');

    final ok = await showDialog<bool>(

      context: context,

      builder: (ctx) => AlertDialog(

        title: Text(existing == null ? l10n.addBrand : l10n.editBrand),

        content: AppInput(

          controller: name,

          label: l10n.brandNameField,

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

    if (ok != true || name.text.trim().isEmpty) return;



    final db = ref.read(appDatabaseProvider);

    final id = existing?.id ?? _uuid.v4();

    await db.upsertBrand(

      BrandsCompanion(

        id: Value(id),

        tenantId: Value(StoreContext.tenantId),

        storeId: Value(StoreContext.storeId),

        name: Value(name.text.trim()),

        createdAt: Value(existing?.createdAt ?? DateTime.now()),

      ),

    );

    name.dispose();

    if (context.mounted) {

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(content: Text(l10n.brandSaved)),

      );

    }

  }

}

