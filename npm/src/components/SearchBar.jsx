import React, { useRef, useContext } from "react";
import { NavigationContext } from "@thoughtbot/superglue";

import { Input } from "terrazzo/ui";
import { Search } from "lucide-react";

export function SearchBar({ searchTerm, searchPath }) {
  const { visit } = useContext(NavigationContext);
  const inputRef = useRef(null);

  const handleSubmit = (e) => {
    e.preventDefault();
    const search = inputRef.current?.value ?? "";
    const params = new URLSearchParams();
    params.set("search", search);
    const url = `${searchPath}?${params.toString()}`;
    visit(url, {});
  };

  return (
    <form onSubmit={handleSubmit} className="max-w-sm">
      <div className="relative">
        <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
        <Input
          ref={inputRef}
          type="search"
          name="search"
          placeholder="Search..."
          defaultValue={searchTerm ?? ""}
          className="pl-8" />

      </div>
    </form>);

}
