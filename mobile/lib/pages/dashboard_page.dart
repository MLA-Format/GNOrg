import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../services/game_service.dart';
import '../theme.dart';
import '../widgets/auth_shell.dart';

// ─── Dashboard page ────────────────────────────────────────────────────────────

/// Main game-collection dashboard — Flutter port of `web/src/pages/UserDash.tsx`.
///
/// Auth-guards on mount. Loads games from the API. Add/edit/delete/filter via
/// bottom sheets. Image upload via `image_picker`.
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

  void _handleUnauthorized() => widget.onSignOut();

  // ── Bottom sheets ──────────────────────────────────────────────────────────

  void _openSheet(Widget sheet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => sheet,
    );
  }

  void _showGameAction(Game game) {
    _openSheet(_ActionSheet(
      game: game,
      onEdit: () {
        Navigator.pop(context);
        _showGameForm(initial: game);
      },
      onDeleted: () {
        Navigator.pop(context);
        _loadGames();
      },
      onUnauthorized: _handleUnauthorized,
    ));
  }

  void _showGameForm({Game? initial}) {
    _openSheet(_GameFormSheet(
      initial: initial,
      onSaved: () {
        Navigator.pop(context);
        _loadGames();
      },
      onUnauthorized: _handleUnauthorized,
    ));
  }

  void _showFilter() {
    _openSheet(_FilterSheet(
      filters: _filters,
      onApply: (f) {
        Navigator.pop(context);
        setState(() => _filters = f);
        _loadGames();
      },
    ));
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
    final hasFilters = !_filters.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: _DashAppBar(
        searchCtrl: _searchCtrl,
        hasFilters: hasFilters,
        onFilter: _showFilter,
        onResetFilter: () {
          setState(() => _filters = const _Filters());
          _loadGames();
        },
        onSignOut: _signOut,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.lime,
        foregroundColor: AppColors.navy,
        onPressed: () => _showGameForm(),
        child: const Icon(Icons.add),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!_loaded) return _SkeletonGrid();

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
                  : 'Add your first game to get started.',
              style: GoogleFonts.jetBrainsMono(fontSize: 12, color: Colors.white54),
              textAlign: TextAlign.center,
            ),
            if (_hasAnyGames != true) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _showGameForm(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lime,
                  foregroundColor: AppColors.navy,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Add game',
                    style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w700)),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.lime,
      onRefresh: _loadGames,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemCount: _games.length,
        itemBuilder: (_, i) => _GameCard(
          game: _games[i],
          onTap: () => _showGameAction(_games[i]),
        ),
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
      titleSpacing: 16,
      title: Text(
        'GNOrg',
        style: GoogleFonts.jetBrainsMono(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.navy,
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
        child: Container(
          color: AppColors.lime,
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchCtrl,
                  style: GoogleFonts.jetBrainsMono(fontSize: 13, color: AppColors.navy),
                  cursorColor: AppColors.navy,
                  decoration: InputDecoration(
                    hintText: 'Search games…',
                    hintStyle: GoogleFonts.jetBrainsMono(
                        fontSize: 13, color: AppColors.navy.withOpacity(0.4)),
                    prefixIcon: Icon(Icons.search, size: 18, color: AppColors.navy.withOpacity(0.5)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.6),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.navy.withOpacity(0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.navy.withOpacity(0.5)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Filter button
              GestureDetector(
                onTap: onFilter,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: hasFilters ? AppColors.navy : Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.navy.withOpacity(0.3)),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.tune,
                          size: 18, color: hasFilters ? AppColors.lime : AppColors.navy),
                      if (hasFilters)
                        Positioned(
                          top: 6,
                          right: 6,
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
                    child: const Icon(Icons.close, size: 16, color: AppColors.lime),
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

// ─── Game Card ─────────────────────────────────────────────────────────────────

class _GameCard extends StatelessWidget {
  final Game game;
  final VoidCallback onTap;

  const _GameCard({required this.game, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final playerLabel = game.playerLabel;
    final genreLabel = [game.genre.category, game.genre.type]
        .where((s) => s != null && s.isNotEmpty)
        .join(' · ');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.navy.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  SizedBox.expand(
                    child: game.coverImage != null
                        ? Image.network(
                            game.coverImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _PlaceholderCover(),
                          )
                        : _PlaceholderCover(),
                  ),
                  // Options button
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: onTap,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppColors.navy.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white.withOpacity(0.15)),
                        ),
                        child: const Icon(Icons.more_vert, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.name,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        if (playerLabel.isNotEmpty) _Chip(label: playerLabel),
                        if (game.portable != null)
                          _Chip(
                            label: game.portable! ? '✦ Portable' : 'Not portable',
                            filled: game.portable!,
                          ),
                      ],
                    ),
                    if (genreLabel.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          genreLabel,
                          style: GoogleFonts.jetBrainsMono(
                              fontSize: 9, color: AppColors.navy.withOpacity(0.5)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderCover extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        color: AppColors.lime.withOpacity(0.2),
        child: const Center(
          child: Icon(Icons.grid_view_rounded, size: 32, color: Colors.black12),
        ),
      );
}

class _Chip extends StatelessWidget {
  final String label;
  final bool filled;

  const _Chip({required this.label, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: filled ? AppColors.navy : AppColors.navy.withOpacity(0.06),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: filled ? AppColors.navy : AppColors.navy.withOpacity(0.12),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 9,
          fontWeight: FontWeight.w500,
          color: filled ? AppColors.lime : AppColors.navy,
        ),
      ),
    );
  }
}

// ─── Skeleton ──────────────────────────────────────────────────────────────────

class _SkeletonGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: 8,
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

// ─── Bottom sheet helpers ──────────────────────────────────────────────────────

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
          // Drag handle
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

// ─── Action sheet ──────────────────────────────────────────────────────────────

class _ActionSheet extends StatefulWidget {
  final Game game;
  final VoidCallback onEdit;
  final VoidCallback onDeleted;
  final VoidCallback onUnauthorized;

  const _ActionSheet({
    required this.game,
    required this.onEdit,
    required this.onDeleted,
    required this.onUnauthorized,
  });

  @override
  State<_ActionSheet> createState() => _ActionSheetState();
}

class _ActionSheetState extends State<_ActionSheet> {
  bool _confirming = false;
  bool _deleting = false;
  String _error = '';

  Future<void> _handleDelete() async {
    setState(() { _deleting = true; _error = ''; });
    final err = await GameService.deleteGame(widget.game.name);
    if (!mounted) return;
    setState(() => _deleting = false);
    if (err == '__unauthorized__') { widget.onUnauthorized(); return; }
    if (err != null) { setState(() => _error = err); return; }
    widget.onDeleted();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      title: widget.game.name,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SheetButton(
            icon: Icons.edit_outlined,
            label: 'Edit game',
            iconColor: AppColors.lime,
            onTap: widget.onEdit,
          ),
          const SizedBox(height: 8),

          if (!_confirming)
            _SheetButton(
              icon: Icons.delete_outline,
              label: 'Delete game',
              iconColor: const Color(0xFFF87171),
              textColor: const Color(0xFFF87171),
              onTap: () => setState(() => _confirming = true),
            )
          else ...[
            Text(
              'Are you sure? This cannot be undone.',
              style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.white54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _confirming = false),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      foregroundColor: Colors.white70,
                    ),
                    child: Text('Cancel',
                        style: GoogleFonts.jetBrainsMono(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _deleting ? null : _handleDelete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF87171).withOpacity(0.2),
                      foregroundColor: const Color(0xFFF87171),
                    ),
                    child: Text(
                      _deleting ? 'Deleting…' : 'Yes, delete',
                      style: GoogleFonts.jetBrainsMono(
                          fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],

          if (_error.isNotEmpty) ...[
            const SizedBox(height: 12),
            ErrorBanner(message: _error),
          ],
        ],
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color textColor;
  final VoidCallback onTap;

  const _SheetButton({
    required this.icon,
    required this.label,
    required this.iconColor,
    this.textColor = Colors.white,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.inputDark,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 18),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.jetBrainsMono(fontSize: 13, color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Game form sheet (add / edit) ─────────────────────────────────────────────

class _GameFormSheet extends StatefulWidget {
  final Game? initial;
  final VoidCallback onSaved;
  final VoidCallback onUnauthorized;

  const _GameFormSheet({
    this.initial,
    required this.onSaved,
    required this.onUnauthorized,
  });

  @override
  State<_GameFormSheet> createState() => _GameFormSheetState();
}

class _GameFormSheetState extends State<_GameFormSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _minCtrl;
  late final TextEditingController _maxCtrl;
  late final TextEditingController _exactCtrl;
  late final TextEditingController _genreCatCtrl;
  late final TextEditingController _genreTypeCtrl;

  String _portable = '';
  String _coverImage = '';
  bool _uploading = false;
  bool _saving = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    final g = widget.initial;
    _nameCtrl = TextEditingController(text: g?.name ?? '');
    _minCtrl = TextEditingController(text: g?.players?.min?.toString() ?? '');
    _maxCtrl = TextEditingController(text: g?.players?.max?.toString() ?? '');
    _exactCtrl = TextEditingController(
        text: g?.players?.exact?.join(', ') ?? '');
    _genreCatCtrl = TextEditingController(text: g?.genre.category ?? '');
    _genreTypeCtrl = TextEditingController(text: g?.genre.type ?? '');
    _portable = g?.portable == null ? '' : g!.portable! ? 'true' : 'false';
    _coverImage = g?.coverImage ?? '';
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl, _minCtrl, _maxCtrl, _exactCtrl, _genreCatCtrl, _genreTypeCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  List<int> _parseExact(String raw) =>
      raw.split(',').map((s) => int.tryParse(s.trim())).whereType<int>().toList();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null || !mounted) return;

    setState(() { _uploading = true; _error = ''; });
    final url = await GameService.uploadImage(
      File(picked.path),
      onError: (e) { if (mounted) setState(() => _error = e); },
    );
    if (!mounted) return;
    setState(() {
      _uploading = false;
      if (url != null) _coverImage = url;
    });
  }

  Future<void> _handleSubmit() async {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Name is required');
      return;
    }

    final exact = _parseExact(_exactCtrl.text);
    final players = <String, dynamic>{};
    if (_minCtrl.text.isNotEmpty) players['min'] = int.tryParse(_minCtrl.text);
    if (_maxCtrl.text.isNotEmpty) players['max'] = int.tryParse(_maxCtrl.text);
    if (exact.isNotEmpty) players['exact'] = exact;

    final payload = <String, dynamic>{
      'name': _nameCtrl.text.trim(),
      'players': players.isEmpty ? null : players,
      'genre': {
        'category': _genreCatCtrl.text.trim().isEmpty ? null : _genreCatCtrl.text.trim(),
        'type': _genreTypeCtrl.text.trim().isEmpty ? null : _genreTypeCtrl.text.trim(),
      },
      'portable': _portable.isEmpty ? null : _portable == 'true',
      'coverImage': _coverImage.isEmpty ? null : _coverImage,
    };

    setState(() { _saving = true; _error = ''; });
    String? err;
    if (widget.initial != null) {
      payload['id'] = widget.initial!.id;
      err = await GameService.editGame(payload);
    } else {
      err = await GameService.createGame(payload);
    }
    if (!mounted) return;
    setState(() => _saving = false);

    if (err == '__unauthorized__') { widget.onUnauthorized(); return; }
    if (err != null) { setState(() => _error = err!); return; }
    widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle + header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
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
                        isEdit ? 'Edit Game' : 'Add Game',
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
                ],
              ),
            ),
            // Scrollable fields
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: EdgeInsets.fromLTRB(
                  24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
                children: [
                  _FormField(label: 'Name *', controller: _nameCtrl, placeholder: 'Catan', maxLength: 100),
                  const SizedBox(height: 14),

                  Row(children: [
                    Expanded(child: _FormField(
                        label: 'Players min',
                        controller: _minCtrl,
                        placeholder: '1',
                        keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: _FormField(
                        label: 'Players max',
                        controller: _maxCtrl,
                        placeholder: '4',
                        keyboardType: TextInputType.number)),
                  ]),
                  const SizedBox(height: 14),

                  _FormField(
                    label: 'Exact counts (e.g. 2, 4, 8)',
                    controller: _exactCtrl,
                    placeholder: '2, 4, 8',
                    maxLength: 100,
                  ),
                  const SizedBox(height: 14),

                  Row(children: [
                    Expanded(child: _FormField(
                        label: 'Genre', controller: _genreCatCtrl, placeholder: 'Strategy', maxLength: 50)),
                    const SizedBox(width: 12),
                    Expanded(child: _FormField(
                        label: 'Game type', controller: _genreTypeCtrl, placeholder: 'Eurogame', maxLength: 50)),
                  ]),
                  const SizedBox(height: 14),

                  // Portable dropdown
                  _DropdownField(
                    label: 'Portable',
                    value: _portable,
                    items: const [
                      DropdownMenuItem(value: '', child: Text('— select —')),
                      DropdownMenuItem(value: 'true', child: Text('Yes')),
                      DropdownMenuItem(value: 'false', child: Text('No')),
                    ],
                    onChanged: (v) => setState(() => _portable = v ?? ''),
                  ),
                  const SizedBox(height: 14),

                  // Cover image
                  _CoverImageField(
                    coverImage: _coverImage,
                    uploading: _uploading,
                    onPick: _pickImage,
                  ),
                  const SizedBox(height: 16),

                  if (_error.isNotEmpty) ...[
                    ErrorBanner(message: _error),
                    const SizedBox(height: 14),
                  ],

                  AuthButton(
                    label: _saving ? 'Saving…' : isEdit ? 'Save changes' : 'Add game',
                    onPressed: (_saving || _uploading) ? null : _handleSubmit,
                    loading: _saving,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Form sub-widgets ─────────────────────────────────────────────────────────

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String placeholder;
  final TextInputType keyboardType;
  final int? maxLength;

  const _FormField({
    required this.label,
    required this.controller,
    this.placeholder = '',
    this.keyboardType = TextInputType.text,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
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
          maxLength: maxLength,
          buildCounter: maxLength != null
              ? (_, {required currentLength, required isFocused, maxLength}) => null
              : null,
          style: GoogleFonts.jetBrainsMono(fontSize: 13, color: Colors.white),
          cursorColor: AppColors.lime,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: GoogleFonts.jetBrainsMono(fontSize: 13, color: Colors.white24),
            filled: true,
            fillColor: AppColors.inputDark,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.lime, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
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
          style: GoogleFonts.jetBrainsMono(fontSize: 13, color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.inputDark,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.lime, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _CoverImageField extends StatelessWidget {
  final String coverImage;
  final bool uploading;
  final VoidCallback onPick;

  const _CoverImageField({
    required this.coverImage,
    required this.uploading,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'COVER IMAGE',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF9CA3AF),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        if (coverImage.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              coverImage,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        if (coverImage.isNotEmpty) const SizedBox(height: 8),
        GestureDetector(
          onTap: uploading ? null : onPick,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.inputDark,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.lime.withOpacity(0.3),
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  uploading ? Icons.hourglass_empty : Icons.upload_rounded,
                  size: 16,
                  color: AppColors.lime.withOpacity(0.7),
                ),
                const SizedBox(width: 8),
                Text(
                  uploading
                      ? 'Uploading…'
                      : coverImage.isNotEmpty
                          ? 'Replace image'
                          : 'Upload image',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    color: AppColors.lime.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
          _FormField(
            label: 'Player count',
            controller: _playerCtrl,
            placeholder: '4',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 14),
          _FormField(
            label: 'Genre',
            controller: _genreCtrl,
            placeholder: 'Strategy',
          ),
          const SizedBox(height: 14),
          _DropdownField(
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
