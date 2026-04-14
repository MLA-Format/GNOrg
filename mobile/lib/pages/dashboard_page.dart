import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/game_service.dart';
import '../theme.dart';
import '../widgets/auth_shell.dart';

// ─── Dashboard page ────────────────────────────────────────────────────────────

/// Read-only game-collection dashboard. Add / edit / delete are web-only.
/// Supports search and filter via the AppBar and a bottom sheet.
class DashboardPage extends StatefulWidget {
  final VoidCallback onSignOut;

  const DashboardPage({super.key, required this.onSignOut});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Game> _games = [];
  bool _loaded = false;
  bool? _hasAnyGames;
  String _fetchError = '';

  final _searchCtrl = TextEditingController();
  String _search = '';
  _Filters _filters = const _Filters();

  @override
  void initState() {
    super.initState();
    _checkAuth();
    _searchCtrl.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_searchCtrl.text != _search) {
      setState(() => _search = _searchCtrl.text);
      _loadGames();
    }
  }

  // ── Auth guard ─────────────────────────────────────────────────────────────

  Future<void> _checkAuth() async {
    final token = await AuthService.getValidToken();
    if (!mounted) return;
    if (token == null) { widget.onSignOut(); return; }
    _loadGames();
  }

  // ── Data ───────────────────────────────────────────────────────────────────

  Future<void> _loadGames() async {
    setState(() => _fetchError = '');
    try {
      final results = await GameService.getGames(
        name: _search.isEmpty ? null : _search,
        playerCount: _filters.playerCount,
        genreCategory: _filters.genreCategory.isEmpty ? null : _filters.genreCategory,
        portable: _filters.portable,
      );
      if (!mounted) return;
      setState(() {
        _games = results;
        _loaded = true;
        if (results.isNotEmpty) {
          _hasAnyGames = true;
        } else if (_search.isEmpty && _filters.isEmpty) {
          _hasAnyGames = false;
        }
      });
    } on UnauthorizedException {
      if (!mounted) return;
      widget.onSignOut();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loaded = true;
        _fetchError = 'Could not load games. Please try again.';
      });
    }
  }

  // ── Sheets ─────────────────────────────────────────────────────────────────

  void _showFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(
        filters: _filters,
        onApply: (f) {
          Navigator.pop(context);
          setState(() => _filters = f);
          _loadGames();
        },
      ),
    );
  }

  // ── Sign out ───────────────────────────────────────────────────────────────

  Future<void> _signOut() async {
    await AuthService.clearToken();
    widget.onSignOut();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: _DashAppBar(
        searchCtrl: _searchCtrl,
        hasFilters: !_filters.isEmpty,
        onFilter: _showFilter,
        onResetFilter: () {
          setState(() => _filters = const _Filters());
          _loadGames();
        },
        onSignOut: _signOut,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!_loaded) return const _SkeletonList();

    if (_fetchError.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ErrorBanner(message: _fetchError),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _loadGames,
              child: Text(
                'Try again',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  color: Colors.white70,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_games.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: const Icon(Icons.grid_view_rounded, color: Colors.white38, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              _hasAnyGames == true ? 'No games found' : 'No games yet',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _hasAnyGames == true
                  ? 'Try adjusting your search or filters.'
                  : 'Add games on the web to see them here.',
              style: GoogleFonts.jetBrainsMono(fontSize: 12, color: Colors.white54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.lime,
      onRefresh: _loadGames,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: _games.length,
        itemBuilder: (_, i) => _GameListTile(game: _games[i]),
      ),
    );
  }
}

// ─── AppBar ────────────────────────────────────────────────────────────────────

class _DashAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController searchCtrl;
  final bool hasFilters;
  final VoidCallback onFilter;
  final VoidCallback onResetFilter;
  final VoidCallback onSignOut;

  const _DashAppBar({
    required this.searchCtrl,
    required this.hasFilters,
    required this.onFilter,
    required this.onResetFilter,
    required this.onSignOut,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.lime,
      elevation: 0,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'GNOrg',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.navy,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: onSignOut,
          child: Text(
            'Sign out',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.navy,
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.navy.withOpacity(0.15)),
                  ),
                  child: TextField(
                    controller: searchCtrl,
                    style: GoogleFonts.jetBrainsMono(
                        fontSize: 13, color: AppColors.navy),
                    cursorColor: AppColors.navy,
                    decoration: InputDecoration(
                      hintText: 'Search games…',
                      hintStyle: GoogleFonts.jetBrainsMono(
                          fontSize: 13,
                          color: AppColors.navy.withOpacity(0.4)),
                      prefixIcon: Icon(Icons.search,
                          size: 18, color: AppColors.navy.withOpacity(0.4)),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onFilter,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: hasFilters
                        ? AppColors.navy
                        : Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.navy.withOpacity(0.3)),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.tune,
                          size: 18,
                          color: hasFilters
                              ? AppColors.lime
                              : AppColors.navy.withOpacity(0.7)),
                      if (hasFilters)
                        Positioned(
                          top: 7,
                          right: 7,
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.lime,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (hasFilters) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onResetFilter,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.navy,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.close,
                        size: 16, color: AppColors.lime),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Game list tile ────────────────────────────────────────────────────────────

class _GameListTile extends StatelessWidget {
  final Game game;

  const _GameListTile({required this.game});

  @override
  Widget build(BuildContext context) {
    final details = <String>[];
    if (game.playerLabel.isNotEmpty) details.add(game.playerLabel);
    final genre = [game.genre.category, game.genre.type]
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .join(' · ');
    if (genre.isNotEmpty) details.add(genre);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.07)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  game.name,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (details.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    details.join('  —  '),
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      color: Colors.white54,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (game.portable == true) ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.lime.withOpacity(0.12),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                    color: AppColors.lime.withOpacity(0.3)),
              ),
              child: Text(
                '✦',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.lime,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Skeleton list ─────────────────────────────────────────────────────────────

class _SkeletonList extends StatelessWidget {
  const _SkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: 10,
      itemBuilder: (_, i) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.white.withOpacity(0.07)),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 13,
              width: 100.0 + (i % 3) * 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 7),
            Container(
              height: 10,
              width: 140.0 + (i % 2) * 30,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bottom sheet shell ────────────────────────────────────────────────────────

class _SheetShell extends StatelessWidget {
  final String title;
  final Widget child;

  const _SheetShell({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: Colors.white54, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

// ─── Filter sheet ──────────────────────────────────────────────────────────────

class _FilterSheet extends StatefulWidget {
  final _Filters filters;
  final ValueChanged<_Filters> onApply;

  const _FilterSheet({required this.filters, required this.onApply});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late final TextEditingController _playerCtrl;
  late final TextEditingController _genreCtrl;
  String _portable = '';

  @override
  void initState() {
    super.initState();
    _playerCtrl = TextEditingController(
        text: widget.filters.playerCount?.toString() ?? '');
    _genreCtrl = TextEditingController(text: widget.filters.genreCategory);
    _portable = widget.filters.portable == null
        ? ''
        : widget.filters.portable!
            ? 'true'
            : 'false';
  }

  @override
  void dispose() {
    _playerCtrl.dispose();
    _genreCtrl.dispose();
    super.dispose();
  }

  void _apply() {
    widget.onApply(_Filters(
      playerCount: int.tryParse(_playerCtrl.text.trim()),
      genreCategory: _genreCtrl.text.trim(),
      portable: _portable.isEmpty ? null : _portable == 'true',
    ));
  }

  void _reset() {
    widget.onApply(const _Filters());
  }

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      title: 'Filter Games',
      child: Column(
        children: [
          _FilterTextField(
            label: 'Player count',
            controller: _playerCtrl,
            placeholder: '4',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 14),
          _FilterTextField(
            label: 'Genre',
            controller: _genreCtrl,
            placeholder: 'Strategy',
          ),
          const SizedBox(height: 14),
          _FilterDropdown(
            label: 'Portable',
            value: _portable,
            items: const [
              DropdownMenuItem(value: '', child: Text('— any —')),
              DropdownMenuItem(value: 'true', child: Text('Yes')),
              DropdownMenuItem(value: 'false', child: Text('No')),
            ],
            onChanged: (v) => setState(() => _portable = v ?? ''),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _reset,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    foregroundColor: Colors.white70,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('Reset',
                      style: GoogleFonts.jetBrainsMono(fontSize: 13)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _apply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lime,
                    foregroundColor: AppColors.navy,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Apply',
                      style: GoogleFonts.jetBrainsMono(
                          fontSize: 13, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Filter form widgets ───────────────────────────────────────────────────────

class _FilterTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String placeholder;
  final TextInputType keyboardType;

  const _FilterTextField({
    required this.label,
    required this.controller,
    this.placeholder = '',
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.jetBrainsMono(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF9CA3AF),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.jetBrainsMono(fontSize: 13, color: Colors.white),
          cursorColor: AppColors.lime,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: GoogleFonts.jetBrainsMono(
                fontSize: 13, color: Colors.white24),
            filled: true,
            fillColor: AppColors.inputDark,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  BorderSide(color: Colors.white.withOpacity(0.12)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: AppColors.lime, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.jetBrainsMono(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF9CA3AF),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          items: items,
          onChanged: onChanged,
          dropdownColor: AppColors.cardDark,
          style:
              GoogleFonts.jetBrainsMono(fontSize: 13, color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.inputDark,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  BorderSide(color: Colors.white.withOpacity(0.12)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: AppColors.lime, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Filter state ──────────────────────────────────────────────────────────────

class _Filters {
  final int? playerCount;
  final String genreCategory;
  final bool? portable;

  const _Filters({
    this.playerCount,
    this.genreCategory = '',
    this.portable,
  });

  bool get isEmpty =>
      playerCount == null && genreCategory.isEmpty && portable == null;
}
