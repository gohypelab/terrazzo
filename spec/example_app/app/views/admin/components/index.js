// Re-export all components from the terrazzo package.
// To customize, run: rails g terrazzo:eject components/<component_name>
export * from "terrazzo/components";

// Layout - ejected
import { setLayout } from "terrazzo";
import { Layout } from "./Layout";

setLayout(Layout);

export { Layout };

// SearchBar - ejected
import { registerComponent as registerSearchBarComponent } from "terrazzo/components";
import { SearchBar } from "./SearchBar";

registerSearchBarComponent("SearchBar", SearchBar);

export { SearchBar } from "./SearchBar";
