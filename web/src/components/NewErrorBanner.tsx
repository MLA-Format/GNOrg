export default function ErrorBanner({ message }: { message: string }) {
    return (
        <div className="flex items-center gap-2 bg-red-500/10 border border-red-500/20 rounded-lg px-4 py-3">
            <svg width="14" height="14" viewBox="0 0 14 14" fill="none" className="shrink-0">
                <circle cx="7" cy="7" r="6" stroke="#f87171" strokeWidth="1.5"/>
                <path d="M7 4v3M7 9.5v.5" stroke="#f87171" strokeWidth="1.5" strokeLinecap="round"/>
            </svg>
            <p className="text-red-400 text-xs">{message}</p>
        </div>
    );
}