interface NewLineEntryProps {
    title: string;
    type?: string;
    value: string;
    onChange: (e: React.ChangeEvent<HTMLInputElement>) => void;
}

export default function NewLineEntry({ title, type = "text", value, onChange }: NewLineEntryProps) {
    return (
        <input 
            name={title}
            type={type}
            value={value}
            onChange={onChange}
        />
    );
}