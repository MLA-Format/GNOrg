import { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import logo from '../assets/gnorg-logo.png';
import ErrorBanner from '../components/NewErrorBanner';
import { API_BASE as API } from '../api';

// ─── Types ────────────────────────────────────────────────────────────────────

interface Genre {
    category: string | null;
    type: string | null;
}

interface Players {
    min:   number | null;
    max:   number | null;
    exact: number[] | null;
}

interface Game {
    _id: string;
    name: string;
    players: Players | null;
    genre: Genre;
    portable: boolean | null;
    coverImage: string | null;
}

interface Filters {
    playerCount: string;
    genreCategory: string;
    portable: string; // "true" | "false" | ""
}

// ─── Constants ────────────────────────────────────────────────────────────────

const EMPTY_FILTERS: Filters = { playerCount: '', genreCategory: '', portable: '' };

const AUTH_GRADIENT = `linear-gradient(
    120deg,
    #e8f56e 0%,
    #e8f56e 70%,
    #f0f8a0 70%,
    #f0f8a0 72%,
    #f7fcd0 72%,
    #f7fcd0 74%,
    #ffffff 74%,
    #ffffff 76%,
    #c0c8d8 76%,
    #c0c8d8 78%,
    #7080a0 78%,
    #7080a0 80%,
    #0a0f2e 80%,
    #0a0f2e 100%
)`;

// ─── Helpers ──────────────────────────────────────────────────────────────────

const getToken = () => localStorage.getItem('token');

const authHeaders = () => ({
    'Content-Type': 'application/json',
    Authorization: `Bearer ${getToken()}`,
});

const apiFetch = async (input: RequestInfo, init?: RequestInit): Promise<Response> => {
    const res = await fetch(input, init);
    const refreshed = res.headers.get('X-Refreshed-Token');
    if (refreshed) localStorage.setItem('token', refreshed);
    if (res.status === 401) {
        localStorage.removeItem('token');
        window.location.href = '/login';
    }
    return res;
};

const formatPlayers = (players: Players | null): string | null => {
    if (!players) return null;
    const parts: string[] = [];
    if (players.min != null && players.max != null)
        parts.push(`${players.min}–${players.max}`);
    else if (players.min != null)
        parts.push(`${players.min}+`);
    else if (players.max != null)
        parts.push(`up to ${players.max}`);
    if (players.exact?.length)
        parts.push(players.exact.join(', '));
    return parts.length ? parts.join(' · ') : null;
};

// ─── Panel content types ──────────────────────────────────────────────────────

type PanelView =
    | { type: 'none' }
    | { type: 'action'; game: Game }
    | { type: 'edit'; game: Game }
    | { type: 'add' }
    | { type: 'filter' };

// ─── Field ────────────────────────────────────────────────────────────────────

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

// ─── Game Card ────────────────────────────────────────────────────────────────

function GameCard({ game, onAction }: { game: Game; onAction: (game: Game) => void }) {
    const playerLabel = formatPlayers(game.players);

    return (
        <div className="bg-white/70 backdrop-blur-sm border border-[#0a0f2e15] rounded-2xl overflow-hidden flex flex-col group hover:border-[#0a0f2e40] transition-all duration-200 shadow-sm">
            <div className="relative w-full aspect-[3/2] bg-[#e8f56e30] flex items-center justify-center overflow-hidden">
                {game.coverImage ? (
                    <img
                        src={game.coverImage}
                        alt={game.name}
                        className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                    />
                ) : (
                    <svg width="48" height="48" viewBox="0 0 48 48" fill="none" opacity="0.2">
                        <rect x="4" y="4" width="40" height="40" rx="4" stroke="#0a0f2e" strokeWidth="2" />
                        <line x1="4" y1="17" x2="44" y2="17" stroke="#0a0f2e" strokeWidth="1.5" />
                        <line x1="4" y1="31" x2="44" y2="31" stroke="#0a0f2e" strokeWidth="1.5" />
                        <line x1="17" y1="4" x2="17" y2="44" stroke="#0a0f2e" strokeWidth="1.5" />
                        <line x1="31" y1="4" x2="31" y2="44" stroke="#0a0f2e" strokeWidth="1.5" />
                    </svg>
                )}

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

            <div className="p-4 flex flex-col gap-2 flex-1">
                <h3 className="text-sm font-bold text-[#0a0f2e] leading-tight">{game.name}</h3>

                <div className="flex flex-wrap gap-2 mt-auto pt-2">
                    {playerLabel && (
                        <span className="flex items-center gap-1 text-xs font-medium bg-[#0a0f2e10] border border-[#0a0f2e15] rounded-md px-2 py-1 text-[#0a0f2e]">
                            <svg width="11" height="11" viewBox="0 0 11 11" fill="none">
                                <circle cx="5.5" cy="3.5" r="2" stroke="#0a0f2e" strokeWidth="1.2" />
                                <path d="M1.5 10c0-2.2 1.8-4 4-4s4 1.8 4 4" stroke="#0a0f2e" strokeWidth="1.2" strokeLinecap="round" />
                            </svg>
                            {playerLabel}
                        </span>
                    )}

                    {game.portable != null && (
                        <span className={`text-xs font-medium rounded-md px-2 py-1 border ${
                            game.portable
                                ? 'bg-[#0a0f2e] border-[#0a0f2e] text-[#e8f56e]'
                                : 'bg-[#0a0f2e10] border-[#0a0f2e15] text-[#0a0f2e80]'
                        }`}>
                            {game.portable ? '✦ Portable' : 'Not portable'}
                        </span>
                    )}
                </div>

                {(game.genre?.category || game.genre?.type) && (
                    <p className="text-xs text-[#0a0f2e60] mt-1">
                        {[game.genre.category, game.genre.type].filter(Boolean).join(' · ')}
                    </p>
                )}
            </div>
        </div>
    );
}

// ─── Panel: Game Action ───────────────────────────────────────────────────────

function ActionPanel({ game, onEdit, onDeleted, onClose }: {
    game: Game;
    onEdit: () => void;
    onDeleted: () => void;
    onClose: () => void;
}) {
    const [confirming, setConfirming] = useState(false);
    const [deleting, setDeleting] = useState(false);
    const [error, setError] = useState('');

    const handleDelete = async () => {
        setDeleting(true);
        try {
            const res = await apiFetch(`${API}/games/delete`, {
                method: 'DELETE',
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
    );
}

// ─── Panel: Game Form ─────────────────────────────────────────────────────────

function GameFormPanel({ initial, onClose, onSaved }: {
    initial: Game | null;
    onClose: () => void;
    onSaved: () => void;
}) {
    const isEdit = Boolean(initial);

    const [form, setForm] = useState({
        name:          initial?.name ?? '',
        playersMin:    initial?.players?.min?.toString()   ?? '',
        playersMax:    initial?.players?.max?.toString()   ?? '',
        playersExact:  initial?.players?.exact?.join(', ') ?? '',
        genreCategory: initial?.genre?.category ?? '',
        genreType:     initial?.genre?.type     ?? '',
        portable:      initial?.portable != null ? String(initial.portable) : '',
        coverImage:    initial?.coverImage ?? '',
    });

    const [error, setError] = useState('');
    const [saving, setSaving] = useState(false);
    const [uploading, setUploading] = useState(false);

    const set = (key: keyof typeof form) => (v: string) => setForm((f) => ({ ...f, [key]: v }));

    const handleImageUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (!file) return;
        setUploading(true);
        setError('');
        try {
            const data = new FormData();
            data.append('image', file);
            const res = await apiFetch(`${API}/games/upload-image`, {
                method: 'POST',
                headers: { Authorization: `Bearer ${getToken()}` },
                body: data,
            });
            if (!res.ok) {
                const body = await res.json();
                setError(body.error === 'FILE_TOO_LARGE' ? 'Image must be under 5 MB.' : 'Upload failed. Please try again.');
                return;
            }
            const { url } = await res.json();
            setForm((f) => ({ ...f, coverImage: url }));
        } catch {
            setError('Network error during upload.');
        } finally {
            setUploading(false);
        }
    };

    // Parse the exact field: "2, 4, 8" -> [2, 4, 8], ignoring non-numbers.
    const parseExact = (raw: string): number[] =>
        raw.split(',').map(s => Number(s.trim())).filter(n => !isNaN(n) && n > 0);

    const handleSubmit = async () => {
        if (!form.name.trim()) { setError('Name is required'); return; }

        const exact = parseExact(form.playersExact);
        const players: Record<string, unknown> = {};
        if (form.playersMin) players.min = Number(form.playersMin);
        if (form.playersMax) players.max = Number(form.playersMax);
        if (exact.length)    players.exact = exact;

        setSaving(true);
        try {
            const payload: Record<string, unknown> = {
                name: form.name,
                players: Object.keys(players).length ? players : null,
                genre: {
                    category: form.genreCategory || null,
                    type:     form.genreType     || null,
                },
                portable:   form.portable !== '' ? form.portable === 'true' : null,
                coverImage: form.coverImage || null,
            };
            if (isEdit) payload.id = initial!._id;

            const res = await apiFetch(`${API}/${isEdit ? 'games/edit' : 'games/create'}`, {
                method: isEdit ? 'PATCH' : 'POST',
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
        <div className="flex flex-col gap-4">
            <Field label="Name *" placeholder="Catan" value={form.name} onChange={set('name')} />

            <div className="grid grid-cols-2 gap-3">
                <Field label="Players min" type="number" placeholder="1" value={form.playersMin} onChange={set('playersMin')} />
                <Field label="Players max" type="number" placeholder="4" value={form.playersMax} onChange={set('playersMax')} />
            </div>

            <Field label="Exact counts (e.g. 2, 4, 8)" placeholder="2, 4, 8" value={form.playersExact} onChange={set('playersExact')} />

            <div className="grid grid-cols-2 gap-3">
                <Field label="Genre category" placeholder="Strategy" value={form.genreCategory} onChange={set('genreCategory')} />
                <Field label="Genre type"     placeholder="Eurogame"  value={form.genreType}     onChange={set('genreType')} />
            </div>

            <Field label="Portable" value={form.portable} onChange={set('portable')}>
                <option value="">— select —</option>
                <option value="true">Yes</option>
                <option value="false">No</option>
            </Field>

            {/* Cover image upload */}
            <div className="flex flex-col gap-1.5">
                <label className="text-xs font-semibold text-gray-400 uppercase tracking-wide">Cover image</label>
                {form.coverImage && (
                    <img src={form.coverImage} alt="Cover preview" className="w-full h-32 object-cover rounded-lg border border-[#ffffff15]" />
                )}
                <label className="flex items-center justify-center gap-2 w-full py-2.5 rounded-lg border border-dashed border-[#ffffff25] text-sm text-gray-400 hover:border-[#e8f56e50] hover:text-[#e8f56e] transition-all cursor-pointer">
                    {uploading ? 'Uploading…' : form.coverImage ? 'Replace image' : 'Upload image'}
                    <input
                        type="file"
                        accept="image/*"
                        className="hidden"
                        disabled={uploading}
                        onChange={handleImageUpload}
                    />
                </label>
            </div>

            {error && <ErrorBanner message={error} />}

            <button
                onClick={handleSubmit}
                disabled={saving || uploading}
                className="w-full bg-[#e8f56e] hover:bg-[#f0f8a0] disabled:opacity-50 transition-colors text-[#0a0f2e] text-sm font-bold py-3 rounded-lg cursor-pointer tracking-wide"
            >
                {saving ? 'Saving…' : isEdit ? 'Save changes' : 'Add game'}
            </button>
        </div>
    );
}

// ─── Panel: Filter ────────────────────────────────────────────────────────────

function FilterPanel({ filters, onChange, onClose }: {
    filters: Filters;
    onChange: (f: Filters) => void;
    onClose: () => void;
}) {
    const [local, setLocal] = useState<Filters>(filters);
    const set = (key: keyof Filters) => (v: string) => setLocal((f) => ({ ...f, [key]: v }));

    const apply = () => { onChange(local); onClose(); };
    const reset = () => { setLocal(EMPTY_FILTERS); onChange(EMPTY_FILTERS); onClose(); };

    return (
        <div className="flex flex-col gap-4">
            <Field label="Player count" type="number" placeholder="4" value={local.playerCount} onChange={set('playerCount')} />
            <Field label="Genre category" placeholder="Strategy" value={local.genreCategory} onChange={set('genreCategory')} />
            <Field label="Portable" value={local.portable} onChange={set('portable')}>
                <option value="">— any —</option>
                <option value="true">Yes</option>
                <option value="false">No</option>
            </Field>

            <div className="flex gap-2 pt-1">
                <button onClick={reset} className="flex-1 py-2.5 rounded-lg border border-[#ffffff15] text-sm text-gray-300 hover:border-[#ffffff30] transition-all">
                    Reset
                </button>
                <button onClick={apply} className="flex-1 py-2.5 rounded-lg bg-[#e8f56e] text-[#0a0f2e] text-sm font-bold hover:bg-[#f0f8a0] transition-colors">
                    Apply
                </button>
            </div>
        </div>
    );
}

// ─── Right Panel Shell ────────────────────────────────────────────────────────

function RightPanelShell({ title, onClose, children }: {
    title: string;
    onClose: () => void;
    children: React.ReactNode;
}) {
    return (
        <div className="flex flex-col gap-6 h-full" style={{ animation: 'fadeIn 0.2s ease both' }}>
            <div className="flex items-center justify-between">
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
            {children}
        </div>
    );
}

// ─── Mobile Modal Shell ───────────────────────────────────────────────────────

function MobileModal({ onClose, title, children }: {
    onClose: () => void;
    title: string;
    children: React.ReactNode;
}) {
    useEffect(() => {
        const handler = (e: KeyboardEvent) => { if (e.key === 'Escape') onClose(); };
        document.addEventListener('keydown', handler);
        return () => document.removeEventListener('keydown', handler);
    }, [onClose]);

    return (
        <div
            className="fixed inset-0 z-50 flex items-end justify-center sm:items-center p-4"
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

    const [games, setGames] = useState<Game[]>([]);
    // `loaded` flips true after the first fetch completes and never resets.
    // Skeleton only shows before the first load; refreshes update cards in place.
    const [loaded, setLoaded] = useState(false);
    const [fetchError, setFetchError] = useState('');

    const [search, setSearch] = useState('');
    const [filters, setFilters] = useState<Filters>(EMPTY_FILTERS);
    const [panel, setPanel] = useState<PanelView>({ type: 'none' });
    const [tab] = useState<'games'>('games');

    // Redirect if JWT is missing or expired.
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

    const loadGames = useCallback(async () => {
        setFetchError('');
        try {
            const body: Record<string, unknown> = {};
            if (search) body.name = search;
            if (filters.playerCount) body.players = { count: Number(filters.playerCount) };
            if (filters.genreCategory) body.genre = { category: filters.genreCategory };
            if (filters.portable !== '') body.portable = filters.portable === 'true';

            const res = await apiFetch(`${API}/games/get`, {
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
            setLoaded(true);
        }
    }, [search, filters]);

    useEffect(() => { loadGames(); }, [loadGames]);

    const hasActiveFilters = Object.values(filters).some(Boolean);
    const handleSignOut = () => { localStorage.removeItem('token'); navigate('/'); };
    const closePanel = () => setPanel({ type: 'none' });

    const panelTitle =
        panel.type === 'add'    ? 'Add Game' :
        panel.type === 'edit'   ? 'Edit Game' :
        panel.type === 'action' ? panel.game.name :
        panel.type === 'filter' ? 'Filter Games' : '';

    const panelContent = panel.type === 'none' ? null
        : panel.type === 'action' ? (
            <ActionPanel
                game={panel.game}
                onEdit={() => setPanel({ type: 'edit', game: panel.game })}
                onDeleted={loadGames}
                onClose={closePanel}
            />
        ) : panel.type === 'edit' ? (
            <GameFormPanel initial={panel.game} onClose={closePanel} onSaved={() => { loadGames(); closePanel(); }} />
        ) : panel.type === 'add' ? (
            <GameFormPanel initial={null} onClose={closePanel} onSaved={() => { loadGames(); closePanel(); }} />
        ) : panel.type === 'filter' ? (
            <FilterPanel filters={filters} onChange={setFilters} onClose={closePanel} />
        ) : null;

    return (
        // Gradient spans full width. Right panel is transparent so the dark
        // portion of the gradient shows through it naturally.
        <div className="h-screen overflow-hidden flex flex-col" style={{ background: AUTH_GRADIENT }}>
            <style>{`
                @keyframes fadeIn  { from { opacity: 0; } to { opacity: 1; } }
                @keyframes slideUp { from { opacity: 0; transform: translateY(12px); } to { opacity: 1; transform: translateY(0); } }
            `}</style>

            {/* ── Nav ── */}
            <nav className="shrink-0 border-b border-[#0a0f2e15] backdrop-blur-sm" style={{ background: 'rgba(232,245,110,0.85)' }}>
                <div className="flex items-center justify-between h-14 px-6">
                    <button onClick={() => navigate('/')} className="flex items-center gap-2.5 cursor-pointer bg-transparent border-0 p-0">
                        <img src={logo} alt="GNOrg" className="w-8 h-8" />
                        <span className="text-base font-bold tracking-tight text-[#0a0f2e]">
                            GN<span style={{ color: '#8aab00' }}>Org</span>
                        </span>
                    </button>
                    <button
                        onClick={handleSignOut}
                        className="text-xs font-semibold text-[#0a0f2e] hover:text-[#0a0f2e] transition-colors px-3 py-1.5 rounded-lg hover:bg-[#0a0f2e10]"
                    >
                        Sign out
                    </button>
                </div>
            </nav>

            {/* ── Two-panel layout ── */}
            <div className="flex flex-1 min-h-0">

                {/* ── Left panel: tab + toolbar fixed, grid scrolls ── */}
                <div className="flex-1 flex flex-col min-w-0 px-6 py-8">

                    {/* Tab bar — does not scroll */}
                    <div className="flex gap-1 mb-6 shrink-0">
                        {(['games'] as const).map((t) => (
                            <button
                                key={t}
                                className={`px-4 py-2 text-sm font-semibold border-b-2 transition-all capitalize ${
                                    tab === t
                                        ? 'border-[#0a0f2e] text-[#0a0f2e]'
                                        : 'border-transparent text-[#0a0f2e60] hover:text-[#0a0f2e]'
                                }`}
                            >
                                {t}
                            </button>
                        ))}
                    </div>

                    {/* Toolbar — does not scroll */}
                    <div className="flex flex-wrap items-center gap-3 mb-6 shrink-0">
                        <div className="relative flex-1 min-w-[180px]">
                            <svg className="absolute left-3 top-1/2 -translate-y-1/2 text-[#0a0f2e50]" width="15" height="15" viewBox="0 0 15 15" fill="none">
                                <circle cx="6.5" cy="6.5" r="5" stroke="currentColor" strokeWidth="1.4" />
                                <path d="M10.5 10.5l3 3" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round" />
                            </svg>
                            <input
                                type="text"
                                placeholder="Search games…"
                                value={search}
                                onChange={(e) => setSearch(e.target.value)}
                                className="w-full bg-white/60 border border-[#0a0f2e20] rounded-xl pl-9 pr-4 py-2.5 text-sm text-[#0a0f2e] placeholder-[#0a0f2e50] focus:outline-none focus:border-[#0a0f2e60] focus:ring-1 focus:ring-[#0a0f2e40] transition-all"
                            />
                        </div>

                        <button
                            onClick={() => setPanel({ type: 'filter' })}
                            className={`relative flex items-center gap-2 px-4 py-2.5 rounded-xl border text-sm font-semibold transition-all ${
                                hasActiveFilters
                                    ? 'bg-[#0a0f2e] border-[#0a0f2e] text-[#e8f56e]'
                                    : 'bg-white/60 border-[#0a0f2e20] text-[#0a0f2e] hover:border-[#0a0f2e40]'
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

                        {hasActiveFilters && (
                            <button
                                onClick={() => setFilters(EMPTY_FILTERS)}
                                className="flex items-center gap-1.5 px-3 py-2.5 rounded-xl border border-[#0a0f2e20] bg-white/60 text-xs text-[#0a0f2e60] hover:text-[#0a0f2e] hover:border-[#0a0f2e40] transition-all"
                            >
                                <svg width="11" height="11" viewBox="0 0 11 11" fill="none">
                                    <path d="M1 1l9 9M10 1L1 10" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round" />
                                </svg>
                                Reset
                            </button>
                        )}

                        <button
                            onClick={() => setPanel({ type: 'add' })}
                            className="flex items-center gap-2 px-4 py-2.5 rounded-xl bg-[#0a0f2e] hover:bg-[#1e2130] text-[#e8f56e] text-sm font-bold transition-colors ml-auto"
                        >
                            <svg width="13" height="13" viewBox="0 0 13 13" fill="none">
                                <path d="M6.5 1v11M1 6.5h11" stroke="#e8f56e" strokeWidth="1.8" strokeLinecap="round" />
                            </svg>
                            Add game
                        </button>
                    </div>

                    {/* Games grid — only this region scrolls */}
                    <div className="flex-1 overflow-y-auto min-h-0">
                        {!loaded ? (
                            <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-4">
                                {Array.from({ length: 8 }).map((_, i) => (
                                    <div key={i} className="bg-white/50 border border-[#0a0f2e10] rounded-2xl overflow-hidden animate-pulse">
                                        <div className="aspect-[3/2] bg-[#0a0f2e08]" />
                                        <div className="p-4 flex flex-col gap-2">
                                            <div className="h-3 bg-[#0a0f2e10] rounded w-3/4" />
                                            <div className="h-2 bg-[#0a0f2e08] rounded w-1/2" />
                                        </div>
                                    </div>
                                ))}
                            </div>
                        ) : fetchError ? (
                            <div className="flex flex-col items-center justify-center py-24 gap-3">
                                <ErrorBanner message={fetchError} />
                                <button onClick={loadGames} className="text-xs text-[#0a0f2e] underline underline-offset-4">
                                    Try again
                                </button>
                            </div>
                        ) : games.length === 0 ? (
                            <div className="flex flex-col items-center justify-center py-24 gap-4 text-center">
                                <div className="w-16 h-16 rounded-2xl bg-white/60 border border-[#0a0f2e15] flex items-center justify-center">
                                    <svg width="28" height="28" viewBox="0 0 28 28" fill="none" opacity="0.4">
                                        <rect x="2" y="2" width="24" height="24" rx="4" stroke="#0a0f2e" strokeWidth="1.5" />
                                        <path d="M9 14h10M14 9v10" stroke="#0a0f2e" strokeWidth="1.5" strokeLinecap="round" />
                                    </svg>
                                </div>
                                <div>
                                    <p className="text-sm font-semibold text-[#0a0f2e] mb-1">No games found</p>
                                    <p className="text-xs text-[#0a0f2e60]">
                                        {hasActiveFilters || search ? 'Try adjusting your search or filters.' : 'Add your first game to get started.'}
                                    </p>
                                </div>
                                {!hasActiveFilters && !search && (
                                    <button
                                        onClick={() => setPanel({ type: 'add' })}
                                        className="px-5 py-2.5 rounded-xl bg-[#0a0f2e] text-[#e8f56e] text-sm font-bold hover:bg-[#1e2130] transition-colors"
                                    >
                                        Add game
                                    </button>
                                )}
                            </div>
                        ) : (
                            <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-4">
                                {games.map((game) => (
                                    <GameCard
                                        key={game._id}
                                        game={game}
                                        onAction={(g) => setPanel({ type: 'action', game: g })}
                                    />
                                ))}
                            </div>
                        )}
                    </div>
                </div>

                {/* ── Right panel: dark background for contrast ── */}
                <div className="hidden lg:flex w-80 xl:w-96 shrink-0 flex-col border-l border-[#ffffff15] px-6 py-8 overflow-y-auto bg-[#0a0f2e]">
                    {panel.type !== 'none' && (
                        <RightPanelShell title={panelTitle} onClose={closePanel}>
                            {panelContent}
                        </RightPanelShell>
                    )}
                </div>
            </div>

            {/* ── Mobile modal ── */}
            {panel.type !== 'none' && (
                <div className="lg:hidden">
                    <MobileModal title={panelTitle} onClose={closePanel}>
                        {panelContent}
                    </MobileModal>
                </div>
            )}
        </div>
    );
}