import React from "react";
import { render, screen } from "@testing-library/react";

import { registerComponent } from "../componentRegistry";
import { Layout } from "./Layout";

const originalMatchMedia = window.matchMedia;

function resetComponentRegistry() {
  Object.keys(globalThis.__terrazzoComponentRegistry || {}).forEach((key) => {
    delete globalThis.__terrazzoComponentRegistry[key];
  });
}

describe("Layout", () => {
  beforeEach(() => {
    window.matchMedia = vi.fn().mockImplementation((query) => ({
      matches: false,
      media: query,
      onchange: null,
      addListener: vi.fn(),
      removeListener: vi.fn(),
      addEventListener: vi.fn(),
      removeEventListener: vi.fn(),
      dispatchEvent: vi.fn(),
    }));
    resetComponentRegistry();
  });

  afterEach(() => {
    if (originalMatchMedia) {
      window.matchMedia = originalMatchMedia;
    } else {
      delete window.matchMedia;
    }
    resetComponentRegistry();
  });

  it("renders registered nested layout components", () => {
    function CustomAppSidebar({ navigation, variant }) {
      return (
        <aside data-testid="custom-sidebar">
          {variant}:{navigation[0].label}
        </aside>
      );
    }

    function CustomSiteHeader({ title, actions }) {
      return (
        <header data-testid="custom-header">
          {title}
          {actions}
        </header>
      );
    }

    function CustomFlashMessages() {
      return <div data-testid="custom-flash">Flash override</div>;
    }

    registerComponent("AppSidebar", CustomAppSidebar);
    registerComponent("SiteHeader", CustomSiteHeader);
    registerComponent("FlashMessages", CustomFlashMessages);

    render(
      <Layout
        navigation={[{ label: "Orders", items: [] }]}
        title="Edit Order"
        actions={<span>Save draft</span>}
      >
        <p>Page body</p>
      </Layout>
    );

    expect(screen.getByTestId("custom-sidebar")).toHaveTextContent("inset:Orders");
    expect(screen.getByTestId("custom-header")).toHaveTextContent("Edit Order");
    expect(screen.getByTestId("custom-header")).toHaveTextContent("Save draft");
    expect(screen.getByTestId("custom-flash")).toHaveTextContent("Flash override");
    expect(screen.getByText("Page body")).toBeInTheDocument();
  });
});
