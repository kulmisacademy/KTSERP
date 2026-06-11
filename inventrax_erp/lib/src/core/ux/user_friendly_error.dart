import 'package:inventrax_erp/l10n/app_localizations.dart';

/// Maps technical failures to calm, actionable copy for end users.
String userFriendlyError(Object error, {AppLocalizations? l10n}) {
  final raw = error.toString().toLowerCase();
  final l = l10n;

  if (raw.contains('socket') ||
      raw.contains('network') ||
      raw.contains('failed host lookup') ||
      raw.contains('connection')) {
    return l?.errorNetwork ??
        'Unable to reach the server. Your changes are saved locally and will sync when you\'re back online.';
  }

  if (raw.contains('timeout') || raw.contains('timed out')) {
    return l?.errorTimeout ??
        'That took too long. Please try again — your local data is safe.';
  }

  if (raw.contains('permission') ||
      raw.contains('rls') ||
      raw.contains('not authorized') ||
      raw.contains('403')) {
    return l?.errorPermission ??
        'You don\'t have permission for this action. Ask your store admin if you need access.';
  }

  if (raw.contains('unique') ||
      raw.contains('duplicate') ||
      raw.contains('already exists')) {
    return l?.errorDuplicate ??
        'This record already exists. Check barcode, SKU, or name and try again.';
  }

  if (raw.contains('sync') || raw.contains('queue')) {
    return l?.errorSync ??
        'Unable to sync right now. Changes are queued and will retry automatically.';
  }

  if (raw.contains('sql') ||
      raw.contains('drift') ||
      raw.contains('database') ||
      raw.contains('constraint')) {
    return l?.errorDatabase ??
        'Something went wrong saving locally. Please try again or contact support.';
  }

  return l?.errorGeneric ?? 'Something went wrong. Please try again.';
}
