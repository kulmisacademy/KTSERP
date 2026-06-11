import 'package:flutter/material.dart';

import '../../../../app/app_theme.dart';
import '../../../auth/domain/app_role.dart';
import '../../domain/permission_registry.dart';

/// Compact permission editor: collapsed module & page dropdowns.
class AdvancedPermissionPanel extends StatefulWidget {
  const AdvancedPermissionPanel({
    super.key,
    required this.selected,
    required this.onChanged,
    this.initialRole,
    this.readOnly = false,
    this.compact = true,
  });

  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;
  final AppRole? initialRole;
  final bool readOnly;
  final bool compact;

  @override
  State<AdvancedPermissionPanel> createState() => _AdvancedPermissionPanelState();
}

class _AdvancedPermissionPanelState extends State<AdvancedPermissionPanel> {
  String _query = '';
  final _expandedModules = <String, bool>{};
  final _expandedPages = <String, bool>{};

  Set<String> get _selected => Set<String>.from(widget.selected);

  String _pageKey(String moduleId, String pageId) => '$moduleId.$pageId';

  void _toggle(String id, bool on) {
    final next = Set<String>.from(_selected);
    if (on) {
      next.add(id);
    } else {
      next.remove(id);
    }
    widget.onChanged(next);
  }

  void _toggleModule(String moduleId, bool on) {
    final next = Set<String>.from(_selected);
    for (final e in InventraxPermissionRegistry.allEntries) {
      if (e.moduleId != moduleId) continue;
      if (on) {
        next.add(e.id);
      } else {
        next.remove(e.id);
      }
    }
    widget.onChanged(next);
  }

  void _togglePage(String moduleId, String pageId, bool on) {
    final next = Set<String>.from(_selected);
    for (final e in InventraxPermissionRegistry.allEntries) {
      if (e.moduleId != moduleId || e.pageId != pageId) continue;
      if (on) {
        next.add(e.id);
      } else {
        next.remove(e.id);
      }
    }
    widget.onChanged(next);
  }

  void _selectAll() => widget.onChanged(InventraxPermissionRegistry.allPermissionIds());

  void _clearAll() => widget.onChanged({});

  void _applyTemplate(AppRole role) {
    widget.onChanged(PermissionTemplates.forRole(role));
  }

  bool _matchesQuery(PermissionModuleDef mod, List<PermissionEntry> entries) {
    if (_query.isEmpty) return true;
    final q = _query.toLowerCase();
    if (mod.name.toLowerCase().contains(q)) return true;
    return entries.any(
      (e) =>
          e.label.toLowerCase().contains(q) ||
          e.id.toLowerCase().contains(q),
    );
  }

  bool _pageMatchesQuery(PermissionPageDef page, List<PermissionEntry> pageEntries) {
    if (_query.isEmpty) return true;
    final q = _query.toLowerCase();
    if (page.label.toLowerCase().contains(q)) return true;
    return pageEntries.any(
      (e) =>
          e.label.toLowerCase().contains(q) ||
          e.id.toLowerCase().contains(q),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searching = _query.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Search permissions…',
            prefixIcon: const Icon(Icons.search, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          onChanged: (v) => setState(() => _query = v.trim()),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              if (!widget.readOnly) ...[
                _ActionChip(label: 'All', icon: Icons.done_all, onTap: _selectAll),
                const SizedBox(width: 6),
                _ActionChip(label: 'Clear', icon: Icons.clear_all, onTap: _clearAll),
                const SizedBox(width: 6),
                PopupMenuButton<AppRole>(
                  tooltip: 'Role template',
                  onSelected: _applyTemplate,
                  itemBuilder: (_) => [
                    for (final r in AppRole.assignableRoles)
                      PopupMenuItem(
                        value: r,
                        child: Text(PermissionTemplates.labels[r] ?? r.label),
                      ),
                  ],
                  child: _ActionChip(label: 'Template', icon: Icons.copy),
                ),
                const SizedBox(width: 6),
              ],
              Chip(
                label: Text('${_selected.length} on'),
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ...InventraxPermissionRegistry.modules.map((mod) {
          final entries = InventraxPermissionRegistry.allEntries
              .where((e) => e.moduleId == mod.id)
              .toList();
          if (!_matchesQuery(mod, entries)) return const SizedBox.shrink();

          final modIds = entries.map((e) => e.id).toSet();
          final modSelected = modIds.where(_selected.contains).length;
          final modAll = modIds.length;
          final moduleOn = modSelected == modAll && modAll > 0;
          final moduleExpanded =
              _expandedModules[mod.id] ?? (searching && _matchesQuery(mod, entries));

          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Material(
              color: theme.colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(10),
              child: Theme(
                data: theme.copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  key: PageStorageKey('mod-${mod.id}'),
                  tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  childrenPadding: const EdgeInsets.only(bottom: 4),
                  initiallyExpanded: moduleExpanded,
                  onExpansionChanged: (v) =>
                      setState(() => _expandedModules[mod.id] = v),
                  leading: Icon(mod.icon, size: 20, color: InventraXTheme.primary),
                  title: Text(
                    mod.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    '$modSelected of $modAll enabled · tap to expand',
                    style: theme.textTheme.bodySmall,
                  ),
                  trailing: widget.readOnly
                      ? null
                      : SizedBox(
                          width: 44,
                          child: Switch(
                            value: moduleOn,
                            onChanged: (v) => _toggleModule(mod.id, v),
                          ),
                        ),
                  children: [
                    for (final page in mod.pages)
                      _buildPageSection(
                        context,
                        mod: mod,
                        page: page,
                        entries: entries,
                        searching: searching,
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPageSection(
    BuildContext context, {
    required PermissionModuleDef mod,
    required PermissionPageDef page,
    required List<PermissionEntry> entries,
    required bool searching,
  }) {
    final theme = Theme.of(context);
    final pageEntries =
        entries.where((e) => e.pageId == page.id).toList();
    if (pageEntries.isEmpty || !_pageMatchesQuery(page, pageEntries)) {
      return const SizedBox.shrink();
    }

    final pageIds = pageEntries.map((e) => e.id).toSet();
    final pageSelected = pageIds.where(_selected.contains).length;
    final pageAll = pageIds.length;
    final pageOn = pageSelected == pageAll && pageAll > 0;
    final pageKey = _pageKey(mod.id, page.id);
    final pageExpanded = _expandedPages[pageKey] ?? searching;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        child: ExpansionTile(
          key: PageStorageKey('page-$pageKey'),
          tilePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          childrenPadding: EdgeInsets.zero,
          dense: true,
          initiallyExpanded: pageExpanded,
          onExpansionChanged: (v) => setState(() => _expandedPages[pageKey] = v),
          title: Text(
            page.label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            '$pageSelected / $pageAll',
            style: theme.textTheme.bodySmall,
          ),
          trailing: widget.readOnly
              ? null
              : SizedBox(
                  width: 40,
                  height: 28,
                  child: FittedBox(
                    child: Switch(
                      value: pageOn,
                      onChanged: (v) => _togglePage(mod.id, page.id, v),
                    ),
                  ),
                ),
          children: pageEntries
              .map(
                (e) => CheckboxListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  title: Text(
                    e.action.label,
                    style: theme.textTheme.bodySmall,
                  ),
                  subtitle: widget.compact
                      ? null
                      : Text(
                          e.id,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                  value: _selected.contains(e.id),
                  onChanged: widget.readOnly
                      ? null
                      : (v) => _toggle(e.id, v ?? false),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.icon,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      visualDensity: VisualDensity.compact,
      onPressed: onTap,
    );
  }
}
