import { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import logo from '../assets/gnorg-logo.png';
import ErrorBanner from '../components/NewErrorBanner';

// ─── Types ────────────────────────────────────────────────────────────────────

interface Genre {
    category: string | null;
    type: string | null;
}

interface Game {
    _id: string;
    name: string;
    players: number | null;
    genre: Genre;
    portable: boolean | null;
    coverImage: string | null;
}

interface Filters {
    players: string;
    genreCategory: string;
    portable: string; // "true" | "false" | ""
}

// ─── Constants ────────────────────────────────────────────────────────────────

const API = 'http://localhost:3000';

const EMPTY_FILTERS: Filters = { players: '', genreCategory: '', portable: '' };

// ─── Helpers ──────────────────────────────────────────────────────────────────

/** Retrieve the JWT from localStorage. */
const getToken = () => localStorage.getItem('token');

/** Shared auth headers for all API calls. */
const authHeaders = () => ({
    'Content-Type': 'application/json',
    Authorization: `Bearer ${getToken()}`,
});

// ─── Sub-components ──────────────────────────────────────────────────────────

/** Labelled text/select input styled to match the dark-card theme. */
function Field({
    label,
    type = 'text',
    placeholder,
    value,
    onChange,
    children,
}: {
    label: string;
    type?: string;
    placeholder?: string;
    value: string;
    onChange: (v: string) => void;
    children?: React.ReactNode;
}) {
    const base =
        'bg-[#13151f] border border-[#ffffff20] rounded-lg px-4 py-2.5 text-sm text-white ' +
        'placeholder-gray-500 focus:outline-none focus:border-[#e8f56e] focus:ring-1 ' +
        'focus:ring-[#e8f56e] transition-all w-full';

    return (
        <div className="flex flex-col gap-1.5">
            <label className="text-xs font-semibold text-gray-400 uppercase tracking-widest">{label}</label>
            {children ? (
                <select className={base} value={value} onChange={(e) => onChange(e.target.value)}>
                    {children}
                </select>
            ) : (
                <input
                    type={type}
                    placeholder={placeholder}
                    value={value}
                    onChange={(e) => onChange(e.target.value)}
                    className={base}
                />
            )}
        </div>
    );
}

/** Individual game card. */
function GameCard({ game, onAction }: { game: Game; onAction: (game: Game) => void }) {
    return (
        <div className="bg-[#1e2130] border border-[#ffffff10] rounded-2xl overflow-hidden flex flex-col group hover:border-[#e8f56e40] transition-all duration-200 shadow-lg">
            {/* Cover image or placeholder */}
            <div className="relative w-full aspect-[3/2] bg-[#13151f] flex items-center justify-center overflow-hidden">
                {game.coverImage ? (
                    <img
                        src={game.coverImage}
                        alt={game.name}
                        className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                    />
                ) : (
                    /* Placeholder board-game grid pattern */
                    <svg width="48" height="48" viewBox="0 0 48 48" fill="none" opacity="0.25">
                        <rect x="4" y="4" width="40" height="40" rx="4" stroke="#e8f56e" strokeWidth="2" />
                        <line x1="4" y1="17" x2="44" y2="17" stroke="#e8f56e" strokeWidth="1.5" />
                        <line x1="4" y1="31" x2="44" y2="31" stroke="#e8f56e" strokeWidth="1.5" />
                        <line x1="17" y1="4" x2="17" y2="44" stroke="#e8f56e" strokeWidth="1.5" />
                        <line x1="31" y1="4" x2="31" y2="44" stroke="#e8f56e" strokeWidth="1.5" />
                    </svg>
                )}

                {/* ⋯ action button */}
                <button
                    onClick={() => onAction(game)}
                    className="absolute top-2 right-2 w-8 h-8 rounded-lg bg-[#0a0f2e]/80 backdrop-blur-sm border border-[#ffffff20] flex items-center justify-center text-white hover:bg-[#e8f56e] hover:text-[#0a0f2e] transition-all"
                    aria-label="Game options"
                >
                    <svg width="14" height="14" viewBox="0 0 14 14" fill="currentColor">
                        <circle cx="7" cy="2" r="1.3" />
                        <circle cx="7" cy="7" r="1.3" />
                        <circle cx="7" cy="12" r="1.3" />
                    </svg>
                </button>
            </div>

            {/* Card body */}
            <div className="p-4 flex flex-col gap-2 flex-1">
                <h3 className="text-sm font-bold text-white leading-tight">{game.name}</h3>

                <div className="flex flex-wrap gap-2 mt-auto pt-2">
                    {/* Player count badge */}
                    {game.players != null && (
                        <span className="flex items-center gap-1 text-xs font-medium bg-[#13151f] border border-[#ffffff15] rounded-md px-2 py-1 text-gray-300">
                            <svg width="11" height="11" viewBox="0 0 11 11" fill="none">
                                <circle cx="5.5" cy="3.5" r="2" stroke="#9ca3af" strokeWidth="1.2" />
                                <path d="M1.5 10c0-2.2 1.8-4 4-4s4 1.8 4 4" stroke="#9ca3af" strokeWidth="1.2" strokeLinecap="round" />
                            </svg>
                            {game.players}
                        </span>
                    )}

                    {/* Portable badge */}
                    {game.portable != null && (
                        <span
                            className={`text-xs font-medium rounded-md px-2 py-1 border ${
                                game.portable
                                    ? 'bg-[#e8f56e15] border-[#e8f56e40] text-[#e8f56e]'
                                    : 'bg-[#ffffff08] border-[#ffffff15] text-gray-400'
                            }`}
                        >
                            {game.portable ? '✦ Portable' : 'Not portable'}
                        </span>
                    )}
                </div>

                {/* Genre */}
                {(game.genre?.category || game.genre?.type) && (
                    <p className="text-xs text-gray-500 mt-1">
                        {[game.genre.category, game.genre.type].filter(Boolean).join(' · ')}
                    </p>
                )}
            </div>
        </div>
    );
}

// ─── Modal: Game Form (Add / Edit) ───────────────────────────────────────────

function GameFormModal({
    initial,
    onClose,
    onSaved,
}: {
    initial: Game | null; // null = adding new
    onClose: () => void;
    onSaved: () => void;
}) {
    const isEdit = Boolean(initial);

    const [form, setForm] = useState({
        name: initial?.name ?? '',
        players: initial?.players?.toString() ?? '',
        genreCategory: initial?.genre?.category ?? '',
        genreType: initial?.genre?.type ?? '',
        portable: initial?.portable != null ? String(initial.portable) : '',
        coverImage: initial?.coverImage ?? '',
    });

    const [error, setError] = useState('');
    const [saving, setSaving] = useState(false);

    const set = (key: keyof typeof form) => (v: string) => setForm((f) => ({ ...f, [key]: v }));

    const handleSubmit = async () => {
        if (!form.name.trim()) { setError('Name is required'); return; }
        setSaving(true);
        try {
            const payload: Record<string, unknown> = {
                name: form.name,
                players: form.players ? Number(form.players) : null,
                genre: {
                    category: form.genreCategory || null,
                    type: form.genreType || null,
                },
                portable: form.portable !== '' ? form.portable === 'true' : null,
                coverImage: form.coverImage || null,
            };
            if (isEdit) payload.id = initial!._id;

            const res = await fetch(`${API}/${isEdit ? 'edit' : 'add'}-game`, {
                method: 'POST',
                headers: authHeaders(),
                body: JSON.stringify(payload),
            });

            if (!res.ok) { setError('Failed to save. Please try again.'); return; }
            onSaved();
            onClose();
        } catch {
            setError('Network error. Please try again.');
        } finally {
            setSaving(false);
        }
    };

    return (
        <ModalShell onClose={onClose} title={isEdit ? 'Edit Game' : 'Add Game'}>
            <div className="flex flex-col gap-4">
                <Field label="Name *" placeholder="Catan" value={form.name} onChange={set('name')} />
                <Field label="Players" type="number" placeholder="4" value={form.players} onChange={set('players')} />
                <div className="grid grid-cols-2 gap-3">
                    <Field label="Genre category" placeholder="Strategy" value={form.genreCategory} onChange={set('genreCategory')} />
                    <Field label="Genre type" placeholder="Eurogame" value={form.genreType} onChange={set('genreType')} />
                </div>
                <Field label="Portable" value={form.portable} onChange={set('portable')}>
                    <option value="">— select —</option>
                    <option value="true">Yes</option>
                    <option value="false">No</option>
                </Field>
                <Field label="Cover image URL" placeholder="https://…" value={form.coverImage} onChange={set('coverImage')} />

                {error && <ErrorBanner message={error} />}

                <button
                    onClick={handleSubmit}
                    disabled={saving}
                    className="w-full bg-[#e8f56e] hover:bg-[#f0f8a0] disabled:opacity-50 transition-colors text-[#0a0f2e] text-sm font-bold py-3 rounded-lg cursor-pointer tracking-wide"
                >
                    {saving ? 'Saving…' : isEdit ? 'Save changes' : 'Add game'}
                </button>
            </div>
        </ModalShell>
    );
}

// ─── Modal: Game Actions (Edit / Delete) ─────────────────────────────────────

function GameActionModal({
    game,
    onClose,
    onEdit,
    onDeleted,
}: {
    game: Game;
    onClose: () => void;
    onEdit: () => void;
    onDeleted: () => void;
}) {
    const [confirming, setConfirming] = useState(false);
    const [deleting, setDeleting] = useState(false);
    const [error, setError] = useState('');

    const handleDelete = async () => {
        setDeleting(true);
        try {
            const res = await fetch(`${API}/delete-game`, {
                method: 'POST',
                headers: authHeaders(),
                body: JSON.stringify({ name: game.name }),
            });
            if (!res.ok) { setError('Delete failed. Please try again.'); return; }
            onDeleted();
            onClose();
        } catch {
            setError('Network error.');
        } finally {
            setDeleting(false);
        }
    };

    return (
        <ModalShell onClose={onClose} title={game.name}>
            <div className="flex flex-col gap-3">
                <button
                    onClick={onEdit}
                    className="w-full flex items-center gap-3 px-4 py-3 rounded-lg bg-[#13151f] border border-[#ffffff15] text-white text-sm font-medium hover:border-[#e8f56e50] transition-all"
                >
                    <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                        <path d="M11 2l3 3-8 8H3v-3l8-8z" stroke="#e8f56e" strokeWidth="1.4" strokeLinejoin="round" />
                    </svg>
                    Edit game
                </button>

                {!confirming ? (
                    <button
                        onClick={() => setConfirming(true)}
                        className="w-full flex items-center gap-3 px-4 py-3 rounded-lg bg-[#13151f] border border-[#ffffff15] text-red-400 text-sm font-medium hover:border-red-500/40 transition-all"
                    >
                        <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                            <path d="M3 4h10M6 4V3h4v1M5 4v9h6V4H5z" stroke="#f87171" strokeWidth="1.4" strokeLinecap="round" strokeLinejoin="round" />
                        </svg>
                        Delete game
                    </button>
                ) : (
                    <div className="flex flex-col gap-2">
                        <p className="text-xs text-gray-400 text-center">Are you sure? This cannot be undone.</p>
                        <div className="flex gap-2">
                            <button
                                onClick={() => setConfirming(false)}
                                className="flex-1 py-2.5 rounded-lg border border-[#ffffff15] text-sm text-gray-300 hover:border-[#ffffff30] transition-all"
                            >
                                Cancel
                            </button>
                            <button
                                onClick={handleDelete}
                                disabled={deleting}
                                className="flex-1 py-2.5 rounded-lg bg-red-500/20 border border-red-500/40 text-sm text-red-400 font-semibold hover:bg-red-500/30 disabled:opacity-50 transition-all"
                            >
                                {deleting ? 'Deleting…' : 'Yes, delete'}
                            </button>
                        </div>
                    </div>
                )}

                {error && <ErrorBanner message={error} />}
            </div>
        </ModalShell>
    );
}

// ─── Modal: Filter ────────────────────────────────────────────────────────────

function FilterModal({
    filters,
    onChange,
    onClose,
    onReset,
}: {
    filters: Filters;
    onChange: (f: Filters) => void;
    onClose: () => void;
    onReset: () => void;
}) {
    const [local, setLocal] = useState<Filters>(filters);
    const set = (key: keyof Filters) => (v: string) => setLocal((f) => ({ ...f, [key]: v }));

    const apply = () => { onChange(local); onClose(); };
    const reset = () => { setLocal(EMPTY_FILTERS); onReset(); onClose(); };

    return (
        <ModalShell onClose={onClose} title="Filter games">
            <div className="flex flex-col gap-4">
                <Field label="Player count" type="number" placeholder="4" value={local.players} onChange={set('players')} />
                <Field label="Genre category" placeholder="Strategy" value={local.genreCategory} onChange={set('genreCategory')} />
                <Field label="Portable" value={local.portable} onChange={set('portable')}>
                    <option value="">— any —</option>
                    <option value="true">Yes</option>
                    <option value="false">No</option>
                </Field>

                <div className="flex gap-2 pt-1">
                    <button
                        onClick={reset}
                        className="flex-1 py-2.5 rounded-lg border border-[#ffffff15] text-sm text-gray-300 hover:border-[#ffffff30] transition-all"
                    >
                        Reset
                    </button>
                    <button
                        onClick={apply}
                        className="flex-1 py-2.5 rounded-lg bg-[#e8f56e] text-[#0a0f2e] text-sm font-bold hover:bg-[#f0f8a0] transition-colors"
                    >
                        Apply
                    </button>
                </div>
            </div>
        </ModalShell>
    );
}

// ─── Shared: Modal Shell ──────────────────────────────────────────────────────

function ModalShell({ onClose, title, children }: { onClose: () => void; title: string; children: React.ReactNode }) {
    // Close on Escape key
    useEffect(() => {
        const handler = (e: KeyboardEvent) => { if (e.key === 'Escape') onClose(); };
        document.addEventListener('keydown', handler);
        return () => document.removeEventListener('keydown', handler);
    }, [onClose]);

    return (
        <div
            className="fixed inset-0 z-50 flex items-center justify-center p-4"
            style={{ background: 'rgba(0,0,0,0.7)', backdropFilter: 'blur(4px)' }}
            onClick={(e) => { if (e.target === e.currentTarget) onClose(); }}
        >
            <div
                className="bg-[#1e2130] border border-[#ffffff15] rounded-2xl w-full max-w-[440px] shadow-2xl"
                style={{ animation: 'slideUp 0.2s ease both' }}
            >
                <div className="flex items-center justify-between px-6 pt-6 pb-4 border-b border-[#ffffff10]">
                    <h2 className="text-base font-bold text-white">{title}</h2>
                    <button
                        onClick={onClose}
                        className="w-7 h-7 rounded-lg flex items-center justify-center text-gray-400 hover:text-white hover:bg-[#ffffff10] transition-all"
                    >
                        <svg width="12" height="12" viewBox="0 0 12 12" fill="none">
                            <path d="M1 1l10 10M11 1L1 11" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
                        </svg>
                    </button>
                </div>
                <div className="p-6">{children}</div>
            </div>
        </div>
    );
}

// ─── Main Dashboard ───────────────────────────────────────────────────────────

export default function Dashboard() {
    const navigate = useNavigate();

    // All games fetched from the API.
    const [games, setGames] = useState<Game[]>([]);
    const [loading, setLoading] = useState(true);
    const [fetchError, setFetchError] = useState('');

    // Search bar state.
    const [search, setSearch] = useState('');

    // Active filter values.
    const [filters, setFilters] = useState<Filters>(EMPTY_FILTERS);

    // Modal visibility state.
    const [showAdd, setShowAdd] = useState(false);
    const [showFilter, setShowFilter] = useState(false);
    const [actionGame, setActionGame] = useState<Game | null>(null); // game options modal
    const [editGame, setEditGame] = useState<Game | null>(null);     // edit form modal

    // Active tab (only "games" for now, but tab system is extensible).
    const [tab] = useState<'games'>('games');

    // Check for a valid JWT on mount; redirect to login if missing/expired.
    useEffect(() => {
        const token = getToken();
        if (!token) { navigate('/login'); return; }
        try {
            const { exp } = JSON.parse(atob(token.split('.')[1]));
            if (exp * 1000 <= Date.now()) { localStorage.removeItem('token'); navigate('/login'); }
        } catch {
            localStorage.removeItem('token');
            navigate('/login');
        }
    }, [navigate]);

    // Fetch games whenever search or filters change.
    const loadGames = useCallback(async () => {
        setLoading(true);
        setFetchError('');
        try {
            const body: Record<string, unknown> = {};
            if (search) body.name = search;
            if (filters.players) body.players = Number(filters.players);
            if (filters.genreCategory) body.genre = { category: filters.genreCategory };
            if (filters.portable !== '') body.portable = filters.portable === 'true';

            const res = await fetch(`${API}/games`, {
                method: 'POST',
                headers: authHeaders(),
                body: JSON.stringify(body),
            });

            if (res.status === 404) { setGames([]); return; }
            if (!res.ok) throw new Error('Fetch failed');

            setGames(await res.json());
        } catch {
            setFetchError('Could not load games. Please try again.');
        } finally {
            setLoading(false);
        }
    }, [search, filters]);

    useEffect(() => { loadGames(); }, [loadGames]);

    // Whether any filter is currently active (used for indicator dot).
    const hasActiveFilters = Object.values(filters).some(Boolean);

    // Sign out: clear token and navigate to landing.
    const handleSignOut = () => { localStorage.removeItem('token'); navigate('/'); };

    return (
        <div className="min-h-screen bg-[#0a0f2e] text-white">
            {/* Animation keyframes */}
            <style>{`
                @keyframes slideUp { from { opacity: 0; transform: translateY(12px); } to { opacity: 1; transform: translateY(0); } }
                @keyframes fadeIn  { from { opacity: 0; } to { opacity: 1; } }
            `}</style>

            {/* ── Nav ─────────────────────────────────────────── */}
            <nav className="border-b border-[#ffffff10] bg-[#0a0f2e]/90 backdrop-blur-sm sticky top-0 z-40">
                <div className="max-w-7xl mx-auto px-6 flex items-center justify-between h-14">
                    {/* Logo */}
                    <div className="flex items-center gap-2.5">
                        <img src={logo} alt="GNOrg" className="w-8 h-8" />
                        <span className="text-base font-bold tracking-tight">
                            GN<span style={{ color: '#8aab00' }}>Org</span>
                        </span>
                    </div>

                    {/* Sign out */}
                    <button
                        onClick={handleSignOut}
                        className="text-xs font-semibold text-gray-400 hover:text-white transition-colors px-3 py-1.5 rounded-lg hover:bg-[#ffffff0d]"
                    >
                        Sign out
                    </button>
                </div>
            </nav>

            {/* ── Tab bar ─────────────────────────────────────── */}
            <div className="border-b border-[#ffffff10] bg-[#0d1235]">
                <div className="max-w-7xl mx-auto px-6 flex gap-1">
                    {/* Extend this array to add more tabs in the future */}
                    {(['games'] as const).map((t) => (
                        <button
                            key={t}
                            className={`px-4 py-3 text-sm font-semibold border-b-2 transition-all capitalize ${
                                tab === t
                                    ? 'border-[#e8f56e] text-[#e8f56e]'
                                    : 'border-transparent text-gray-400 hover:text-white'
                            }`}
                        >
                            {t}
                        </button>
                    ))}
                </div>
            </div>

            {/* ── Tab content ─────────────────────────────────── */}
            <main className="max-w-7xl mx-auto px-6 py-8">
                {tab === 'games' && (
                    <div style={{ animation: 'fadeIn 0.3s ease both' }}>

                        {/* ── Toolbar: search + filter + add ── */}
                        <div className="flex flex-wrap items-center gap-3 mb-8">
                            {/* Search input */}
                            <div className="relative flex-1 min-w-[200px]">
                                <svg
                                    className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-500"
                                    width="15" height="15" viewBox="0 0 15 15" fill="none"
                                >
                                    <circle cx="6.5" cy="6.5" r="5" stroke="currentColor" strokeWidth="1.4" />
                                    <path d="M10.5 10.5l3 3" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round" />
                                </svg>
                                <input
                                    type="text"
                                    placeholder="Search games…"
                                    value={search}
                                    onChange={(e) => setSearch(e.target.value)}
                                    className="w-full bg-[#1e2130] border border-[#ffffff15] rounded-xl pl-9 pr-4 py-2.5 text-sm text-white placeholder-gray-500 focus:outline-none focus:border-[#e8f56e] focus:ring-1 focus:ring-[#e8f56e] transition-all"
                                />
                            </div>

                            {/* Filter button with active indicator */}
                            <button
                                onClick={() => setShowFilter(true)}
                                className={`relative flex items-center gap-2 px-4 py-2.5 rounded-xl border text-sm font-semibold transition-all ${
                                    hasActiveFilters
                                        ? 'bg-[#e8f56e15] border-[#e8f56e50] text-[#e8f56e]'
                                        : 'bg-[#1e2130] border-[#ffffff15] text-gray-300 hover:border-[#ffffff30] hover:text-white'
                                }`}
                            >
                                <svg width="14" height="14" viewBox="0 0 14 14" fill="none">
                                    <path d="M1 3h12M3 7h8M5 11h4" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
                                </svg>
                                Filter
                                {hasActiveFilters && (
                                    <span className="absolute -top-1 -right-1 w-2 h-2 rounded-full bg-[#e8f56e]" />
                                )}
                            </button>

                            {/* Reset filters (only shown when filters are active) */}
                            {hasActiveFilters && (
                                <button
                                    onClick={() => setFilters(EMPTY_FILTERS)}
                                    className="flex items-center gap-1.5 px-3 py-2.5 rounded-xl border border-[#ffffff15] text-xs text-gray-400 hover:text-white hover:border-[#ffffff30] transition-all"
                                >
                                    <svg width="11" height="11" viewBox="0 0 11 11" fill="none">
                                        <path d="M1 1l9 9M10 1L1 10" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round" />
                                    </svg>
                                    Reset
                                </button>
                            )}

                            {/* Add game button */}
                            <button
                                onClick={() => setShowAdd(true)}
                                className="flex items-center gap-2 px-4 py-2.5 rounded-xl bg-[#e8f56e] hover:bg-[#f0f8a0] text-[#0a0f2e] text-sm font-bold transition-colors ml-auto"
                            >
                                <svg width="13" height="13" viewBox="0 0 13 13" fill="none">
                                    <path d="M6.5 1v11M1 6.5h11" stroke="#0a0f2e" strokeWidth="1.8" strokeLinecap="round" />
                                </svg>
                                Add game
                            </button>
                        </div>

                        {/* ── Games grid ── */}
                        {loading ? (
                            /* Loading skeleton */
                            <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-4">
                                {Array.from({ length: 10 }).map((_, i) => (
                                    <div key={i} className="bg-[#1e2130] border border-[#ffffff08] rounded-2xl overflow-hidden animate-pulse">
                                        <div className="aspect-[3/2] bg-[#ffffff08]" />
                                        <div className="p-4 flex flex-col gap-2">
                                            <div className="h-3 bg-[#ffffff10] rounded w-3/4" />
                                            <div className="h-2 bg-[#ffffff08] rounded w-1/2" />
                                        </div>
                                    </div>
                                ))}
                            </div>
                        ) : fetchError ? (
                            <div className="flex flex-col items-center justify-center py-24 gap-3">
                                <ErrorBanner message={fetchError} />
                                <button onClick={loadGames} className="text-xs text-[#e8f56e] underline underline-offset-4">
                                    Try again
                                </button>
                            </div>
                        ) : games.length === 0 ? (
                            /* Empty state */
                            <div className="flex flex-col items-center justify-center py-24 gap-4 text-center">
                                <div className="w-16 h-16 rounded-2xl bg-[#1e2130] border border-[#ffffff10] flex items-center justify-center">
                                    <svg width="28" height="28" viewBox="0 0 28 28" fill="none" opacity="0.5">
                                        <rect x="2" y="2" width="24" height="24" rx="4" stroke="#e8f56e" strokeWidth="1.5" />
                                        <path d="M9 14h10M14 9v10" stroke="#e8f56e" strokeWidth="1.5" strokeLinecap="round" />
                                    </svg>
                                </div>
                                <div>
                                    <p className="text-sm font-semibold text-white mb-1">No games found</p>
                                    <p className="text-xs text-gray-500">
                                        {hasActiveFilters || search ? 'Try adjusting your search or filters.' : 'Add your first game to get started.'}
                                    </p>
                                </div>
                                {!hasActiveFilters && !search && (
                                    <button
                                        onClick={() => setShowAdd(true)}
                                        className="px-5 py-2.5 rounded-xl bg-[#e8f56e] text-[#0a0f2e] text-sm font-bold hover:bg-[#f0f8a0] transition-colors"
                                    >
                                        Add game
                                    </button>
                                )}
                            </div>
                        ) : (
                            <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-4">
                                {games.map((game) => (
                                    <GameCard
                                        key={game._id}
                                        game={game}
                                        onAction={(g) => setActionGame(g)}
                                    />
                                ))}
                            </div>
                        )}
                    </div>
                )}
            </main>

            {/* ── Modals ──────────────────────────────────────── */}

            {/* Add game modal */}
            {showAdd && (
                <GameFormModal
                    initial={null}
                    onClose={() => setShowAdd(false)}
                    onSaved={loadGames}
                />
            )}

            {/* Edit game modal — opened from action modal */}
            {editGame && (
                <GameFormModal
                    initial={editGame}
                    onClose={() => { setEditGame(null); setActionGame(null); }}
                    onSaved={() => { setEditGame(null); setActionGame(null); loadGames(); }}
                />
            )}

            {/* Game options modal (edit / delete) */}
            {actionGame && !editGame && (
                <GameActionModal
                    game={actionGame}
                    onClose={() => setActionGame(null)}
                    onEdit={() => setEditGame(actionGame)}
                    onDeleted={loadGames}
                />
            )}

            {/* Filter modal */}
            {showFilter && (
                <FilterModal
                    filters={filters}
                    onChange={setFilters}
                    onClose={() => setShowFilter(false)}
                    onReset={() => setFilters(EMPTY_FILTERS)}
                />
            )}
        </div>
    );
}