import React from "react";
import { fireEvent, render, screen } from "@testing-library/react";

import { CollectionItemActions } from "./CollectionItemActions";
import { CollectionToolbarActions } from "./CollectionToolbarActions";

describe("collection action components", () => {
  beforeEach(() => {
    document.head.innerHTML = '<meta name="csrf-token" content="csrf-token-value" />';
  });

  it("normalizes toolbar action methods before rendering forms", () => {
    const { container } = render(
      <CollectionToolbarActions
        actions={[
          { label: "Upper GET", url: "/upper-get", method: "GET" },
          { label: "Upper POST", url: "/upper-post", method: "POST" },
          { label: "Upper DELETE", url: "/upper-delete", method: "DELETE" },
        ]}
      />
    );

    expect(container.querySelector('a[href="/upper-get"]')).toHaveTextContent("Upper GET");

    const postForm = container.querySelector('form[action="/upper-post"]');
    expect(postForm).toBeInTheDocument();
    expect(postForm.querySelector('input[name="_method"]')).not.toBeInTheDocument();
    expect(postForm.querySelector('input[name="authenticity_token"]')).toHaveValue("csrf-token-value");

    const deleteForm = container.querySelector('form[action="/upper-delete"]');
    expect(deleteForm).toBeInTheDocument();
    expect(deleteForm.querySelector('input[name="_method"]')).toHaveValue("delete");
    expect(deleteForm.querySelector('input[value="DELETE"]')).not.toBeInTheDocument();
  });

  it("confirms toolbar form actions before submitting", () => {
    const confirmSpy = vi.spyOn(window, "confirm").mockReturnValue(false);
    const { container } = render(
      <CollectionToolbarActions
        actions={[
          { label: "Sync", url: "/sync", method: "POST", confirm: "Sync now?" },
        ]}
      />
    );

    const form = container.querySelector('form[action="/sync"]');
    const event = new Event("submit", { bubbles: true, cancelable: true });
    const allowed = form.dispatchEvent(event);

    expect(confirmSpy).toHaveBeenCalledWith("Sync now?");
    expect(allowed).toBe(false);

    confirmSpy.mockRestore();
  });

  it("applies toolbar action variants to links and forms", () => {
    const { container } = render(
      <CollectionToolbarActions
        actions={[
          { label: "Primary Link", url: "/primary-link", variant: "default" },
          { label: "Danger Form", url: "/danger-form", method: "POST", variant: "destructive" },
        ]}
      />
    );

    expect(container.querySelector('a[href="/primary-link"]')).toHaveClass("bg-primary");
    expect(container.querySelector('form[action="/danger-form"] button')).toHaveClass("bg-destructive");
  });

  it("renders selected ids for bulk toolbar form actions", () => {
    const { container } = render(
      <CollectionToolbarActions
        actions={[
          { label: "Archive", url: "/archive", method: "POST" },
          { label: "Export", url: "/export", method: "GET", param_name: "selected_ids[]" },
        ]}
        selectedIds={["order-1", "order-2"]}
      />
    );

    const archiveForm = container.querySelector('form[action="/archive"]');
    expect(archiveForm).toHaveAttribute("method", "post");
    expect(archiveForm.querySelectorAll('input[name="ids[]"]')).toHaveLength(2);
    expect(archiveForm.querySelector('input[name="authenticity_token"]')).toHaveValue("csrf-token-value");

    const exportForm = container.querySelector('form[action="/export"]');
    expect(exportForm).toHaveAttribute("method", "get");
    expect(exportForm.querySelectorAll('input[name="selected_ids[]"]')).toHaveLength(2);
    expect(exportForm.querySelector('input[name="authenticity_token"]')).not.toBeInTheDocument();
  });

  it("normalizes row action methods before rendering dropdown forms", async () => {
    render(
      <CollectionItemActions
        actions={[
          { label: "Upper GET", url: "/row-upper-get", method: "GET" },
          { label: "Upper POST", url: "/row-upper-post", method: "POST" },
          { label: "Upper DELETE", url: "/row-upper-delete", method: "DELETE" },
        ]}
      />
    );

    const trigger = screen.getByLabelText("Open row actions");
    trigger.focus();
    fireEvent.keyDown(trigger, { key: "Enter", code: "Enter" });

    expect(await screen.findByText("Upper GET")).toHaveAttribute("href", "/row-upper-get");

    const postButton = screen.getByText("Upper POST");
    const postForm = postButton.closest("form");
    expect(postForm).toHaveAttribute("action", "/row-upper-post");
    expect(postForm.querySelector('input[name="_method"]')).not.toBeInTheDocument();
    expect(postForm.querySelector('input[name="authenticity_token"]')).toHaveValue("csrf-token-value");

    const deleteButton = screen.getByText("Upper DELETE");
    const deleteForm = deleteButton.closest("form");
    expect(deleteForm).toHaveAttribute("action", "/row-upper-delete");
    expect(deleteForm.querySelector('input[name="_method"]')).toHaveValue("delete");
    expect(deleteForm.querySelector('input[value="DELETE"]')).not.toBeInTheDocument();
  });
});
