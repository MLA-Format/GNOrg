interface NewLineEntryProps {
    title: string;
    type?: string;
    value: string;
    placeholder?: string;
    className?: string;
    maxLength?: number;
    onChange: (e: React.ChangeEvent<HTMLInputElement>) => void;
}

export default function NewLineEntry({ title, type = "text", value, placeholder, className, maxLength, onChange }: NewLineEntryProps) {
    return (
        <input
            name={title}
            type={type}
            value={value}
            placeholder={placeholder}
            className={className}
            maxLength={maxLength}
            onChange={onChange}
        />
    );
}