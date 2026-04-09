import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game.dart';
import '../services/games_service.dart';
import '../theme.dart';

/// Dashboard page — simplified mobile port of `web/src/pages/UserDash.tsx`.
///
/// Shows the user's game collection as copy-paste-friendly text entries.
/// Supports live search and collapsible filters (player count, genre, portable).
/// A floating "copy all" button copies every visible game to the clipboard.
class DashboardPage extends StatefulWidget {
  /// Called on sign-out (or on 401 response) to navigate back to login.
  final VoidCallback onSignOut;

  const DashboardPage({super.key, required this.onSignOut});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // ── Controllers ───────────────────────────────────────────────────────────

  final _searchCtrl = TextEditingController();
  final _playerCountCtrl = TextEditingController();
  final _genreCategoryCtrl = TextEditingController();

  // ── State ─────────────────────────────────────────────────────────────────

  List<Game> _games = [];
  bool _loading = true;
  String? _error;
  bool _showFilters = false;
  String _portableFilter = ''; // '' = any, 'true' = yes, 'false' = no

  Timer? _debounce;

  // ── Init / Dispose ────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearchChanged);
    _loadGames();
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    _playerCountCtrl.dispose();
    _genreCategoryCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ── Data ──────────────────────────────────────────────────────────────────

  /// Debounces the search field so we don't hit the API on every keypress.
  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _loadGames);
  }

  Future<void> _loadGames() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final playerCount = int.tryParse(_playerCountCtrl.text);
      bool? portable;
      if (_portableFilter == 'true') portable = true;
      if (_portableFilter == 'false') portable = false;

      final result = await GamesService.getGames(
        name: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
        playerCount: playerCount,
        genreCategory: _genreCategoryCtrl.text.trim().isEmpty
            ? null
            : _genreCategoryCtrl.text.trim(),
        portable: portable,
      );

      if (!mounted) return;

      if (result.unauthorized) {
        widget.onSignOut();
        return;
      }

      setState(() {
        _games = result.games ?? [];
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Failed to load games. Check your connection.';
      });
    }
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _handleSignOut() async {
    await GamesService.logoff();
    if (mounted) widget.onSignOut();
  }

  void _copyGame(Game game) {
    Clipboard.setData(ClipboardData(text: game.copyText));
    _showCopiedSnackBar('Copied: ${game.name}');
  }

  void _copyAll() {
    if (_games.isEmpty) return;
    final text = _games.map((g) => g.copyText).join('\n');
    Clipboard.setData(ClipboardData(text: text));
    final count = _games.length;
    _showCopiedSnackBar('Copied $count game${count == 1 ? '' : 's'}');
  }

  void _showCopiedSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.jetBrainsMono(fontSize: 12),
        ),
        duration: const Duration(milliseconds: 1500),
        backgroundColor: AppColors.cardDark,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
    );
  }

  void _applyFilters() {
    setState(() => _showFilters = false);
    _loadGames();
  }

  void _resetFilters() {
    setState(() {
      _playerCountCtrl.clear();
      _genreCategoryCtrl.clear();
      _portableFilter = '';
      _showFilters = false;
    });
    _loadGames();
  }

  bool get _hasFilters =>
      _playerCountCtrl.text.isNotEmpty ||
      _genreCategoryCtrl.text.isNotEmpty ||
      _portableFilter.isNotEmpty;

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: _buildAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSearchRow(),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            child: _showFilters ? _buildFilterPanel() : const SizedBox.shrink(),
          ),
          Expanded(child: _buildGameList()),
        ],
      ),
      floatingActionButton: _games.isNotEmpty
          ? FloatingActionButton.small(
              onPressed: _copyAll,
              backgroundColor: AppColors.lime,
              foregroundColor: AppColors.navy,
              tooltip: 'Copy all',
              child: const Icon(Icons.copy_all),
            )
          : null,
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.cardDark,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.lime,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'GNOrg',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
      actions: [
        TextButton.icon(
          onPressed: _handleSignOut,
          icon: const Icon(Icons.logout, size: 16, color: Color(0xFFD1D5DB)),
          label: Text(
            'Sign out',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              color: const Color(0xFFD1D5DB),
            ),
          ),
        ),
      ],
    );
  }

  // ── Search row ────────────────────────────────────────────────────────────

  Widget _buildSearchRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              style:
                  GoogleFonts.jetBrainsMono(fontSize: 13, color: Colors.white),
              cursorColor: AppColors.lime,
              decoration: InputDecoration(
                hintText: 'Search games...',
                hintStyle: GoogleFonts.jetBrainsMono(
                  fontSize: 13,
                  color: const Color(0xFF6B7280),
                ),
                prefixIcon: const Icon(Icons.search,
                    color: Color(0xFF6B7280), size: 20),
                filled: true,
                fillColor: AppColors.inputDark,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: AppColors.lime, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _FilterToggleButton(
            active: _showFilters,
            hasFilters: _hasFilters,
            onTap: () => setState(() => _showFilters = !_showFilters),
          ),
          if (_hasFilters) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: _resetFilters,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                decoration: BoxDecoration(
                  color: AppColors.inputDark,
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Text(
                  'Reset',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    color: AppColors.lime,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Filter panel ──────────────────────────────────────────────────────────

  Widget _buildFilterPanel() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _FilterLabel(text: 'PLAYER COUNT'),
          const SizedBox(height: 6),
          TextField(
            controller: _playerCountCtrl,
            keyboardType: TextInputType.number,
            style:
                GoogleFonts.jetBrainsMono(fontSize: 13, color: Colors.white),
            cursorColor: AppColors.lime,
            decoration: _filterInputDecoration('e.g. 4'),
          ),
          const SizedBox(height: 12),

          _FilterLabel(text: 'GENRE'),
          const SizedBox(height: 6),
          TextField(
            controller: _genreCategoryCtrl,
            style:
                GoogleFonts.jetBrainsMono(fontSize: 13, color: Colors.white),
            cursorColor: AppColors.lime,
            decoration: _filterInputDecoration('e.g. Strategy'),
          ),
          const SizedBox(height: 12),

          _FilterLabel(text: 'PORTABLE'),
          const SizedBox(height: 6),
          _PortableDropdown(
            value: _portableFilter,
            onChanged: (v) => setState(() => _portableFilter = v ?? ''),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetFilters,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withOpacity(0.2)),
                    foregroundColor: const Color(0xFFD1D5DB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Reset',
                    style: GoogleFonts.jetBrainsMono(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lime,
                    foregroundColor: AppColors.navy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Apply',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _filterInputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.jetBrainsMono(
          fontSize: 13,
          color: const Color(0xFF6B7280),
        ),
        filled: true,
        fillColor: AppColors.inputDark,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.lime, width: 1.5),
        ),
      );

  // ── Game list ─────────────────────────────────────────────────────────────

  Widget _buildGameList() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.lime,
          strokeWidth: 2,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error!,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                color: const Color(0xFFF87171),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _loadGames,
              child: Text(
                'Try again',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  color: AppColors.lime,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_games.isEmpty) {
      return Center(
        child: Text(
          _hasFilters || _searchCtrl.text.isNotEmpty
              ? 'No games match your search'
              : 'No games yet',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 13,
            color: const Color(0xFF6B7280),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
      itemCount: _games.length,
      itemBuilder: (context, index) {
        final game = _games[index];
        return _GameTile(
          game: game,
          onCopy: () => _copyGame(game),
        );
      },
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

/// The filter toggle button with a lime dot indicator when filters are active.
class _FilterToggleButton extends StatelessWidget {
  final bool active;
  final bool hasFilters;
  final VoidCallback onTap;

  const _FilterToggleButton({
    required this.active,
    required this.hasFilters,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.lime.withOpacity(0.15)
                  : AppColors.inputDark,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: active
                    ? AppColors.lime.withOpacity(0.5)
                    : Colors.white.withOpacity(0.1),
              ),
            ),
            child: Icon(
              Icons.tune,
              size: 20,
              color: active ? AppColors.lime : const Color(0xFFD1D5DB),
            ),
          ),
          if (hasFilters)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.lime,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Uppercase label used above each filter field.
class _FilterLabel extends StatelessWidget {
  final String text;
  const _FilterLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.jetBrainsMono(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFD1D5DB),
        letterSpacing: 1.2,
      ),
    );
  }
}

/// Portable yes/no/any dropdown.
class _PortableDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const _PortableDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.cardDark,
          style: GoogleFonts.jetBrainsMono(fontSize: 13, color: Colors.white),
          iconEnabledColor: const Color(0xFF6B7280),
          items: [
            DropdownMenuItem(
              value: '',
              child: Text('— any —',
                  style: GoogleFonts.jetBrainsMono(
                      fontSize: 13, color: Colors.white)),
            ),
            DropdownMenuItem(
              value: 'true',
              child: Text('Yes',
                  style: GoogleFonts.jetBrainsMono(
                      fontSize: 13, color: Colors.white)),
            ),
            DropdownMenuItem(
              value: 'false',
              child: Text('No',
                  style: GoogleFonts.jetBrainsMono(
                      fontSize: 13, color: Colors.white)),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// A single game row showing the name, subtitle, and a copy-icon button.
class _GameTile extends StatelessWidget {
  final Game game;
  final VoidCallback onCopy;

  const _GameTile({required this.game, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    final subtitle = game.subtitle;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 4, 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.name,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              onPressed: onCopy,
              icon: const Icon(Icons.copy, size: 18),
              color: const Color(0xFF6B7280),
              tooltip: 'Copy',
            ),
          ],
        ),
      ),
    );
  }
}
