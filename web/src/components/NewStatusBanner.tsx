type StatusBannerType = "success" | "loading";

const config = {
    success: {
        bg: "bg-[#e8f56e]/10",
        border: "border-[#e8f56e]/20",
        textColor: "text-[#e8f56e]",
        icon: (
            <svg width="14" height="14" viewBox="0 0 14 14" fill="none" className="shrink-0">
                <circle cx="7" cy="7" r="6" stroke="#e8f56e" strokeWidth="1.5"/>
                <path d="M4.5 7l2 2 3-3" stroke="#e8f56e" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
            </svg>
        ),
    },
    loading: {
        bg: "bg-[#ffffff08]",
        border: "border-[#ffffff15]",
        textColor: "text-gray-300",
        icon: (
            <svg className="animate-spin shrink-0" width="14" height="14" viewBox="0 0 14 14" fill="none">
                <circle cx="7" cy="7" r="5.5" stroke="#ffffff30" strokeWidth="1.5"/>
                <path d="M7 1.5A5.5 5.5 0 0 1 12.5 7" stroke="#e8f56e" strokeWidth="1.5" strokeLinecap="round"/>
            </svg>
        ),
    },
};

export default function StatusBanner({ type, message }: { type: StatusBannerType; message: string }) {
    const { bg, border, textColor, icon } = config[type];
    return (
        <div className={`flex items-center gap-2 ${bg} border ${border} rounded-lg px-4 py-3`}>
            {icon}
            <p className={`${textColor} text-xs`}>{message}</p>
        </div>
    );
}