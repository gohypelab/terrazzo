import { readFileSync } from "node:fs";
import { createRequire } from "node:module";
import React from "react";
import { renderToStaticMarkup } from "react-dom/server";
import { Provider as ReduxProvider } from "react-redux";

const require = createRequire(import.meta.url);

const expectedExports = {
  "terrazzo": sourceBarrelExports("../src/index.js"),
  "terrazzo/fields": sourceBarrelExports("../src/fields/index.js"),
  "terrazzo/ui": sourceBarrelExports("../src/ui/index.js"),
  "terrazzo/components": sourceBarrelExports("../src/components/index.js"),
  "terrazzo/pages": sourceBarrelExports("../src/pages/index.js"),
};

for (const [specifier, names] of Object.entries(expectedExports)) {
  const esmModule = await import(specifier);
  assertExports(specifier, "import", esmModule, names);

  const cjsModule = require(specifier);
  assertExports(specifier, "require", cjsModule, names);
}

const components = await import("terrazzo/components");
const fields = await import("terrazzo/fields");
const pages = await import("terrazzo/pages");
const root = await import("terrazzo");
const TestComponent = () => null;

components.registerComponent("ExportCheckComponent", TestComponent);
if (components.getComponent("ExportCheckComponent") !== TestComponent) {
  throw new Error("terrazzo/components registry did not return the registered component");
}
if (root.getComponent("ExportCheckComponent") !== TestComponent) {
  throw new Error("terrazzo root component registry did not share the registered component");
}

const RegisteredResourceTable = ({ emptyState }) =>
  React.createElement("section", { "data-export-check": "registered-resource-table" }, emptyState?.title);

components.registerComponent("ResourceTable", RegisteredResourceTable);
const markup = renderToStaticMarkup(
  React.createElement(pages.AdminCollection, {
    table: { headers: [], rows: [] },
    emptyState: { title: "Registered empty state" },
  })
);
if (!markup.includes('data-export-check="registered-resource-table"')) {
  throw new Error("terrazzo/pages did not render the registered ResourceTable component");
}
if (!markup.includes("Registered empty state")) {
  throw new Error("registered ResourceTable did not receive AdminCollection props");
}

const RegisteredLayout = ({ actions, children, title }) =>
  React.createElement("section", { "data-export-check": "registered-layout" }, title, actions, children);

root.setLayout(RegisteredLayout);
if (root.getLayout() !== RegisteredLayout) {
  throw new Error("terrazzo root layout registry did not return the registered layout");
}

const layoutMarkup = renderToStaticMarkup(
  React.createElement(
    ReduxProvider,
    { store: createSuperglueStore("/admin/export-checks", {
      table: { headers: [], rows: [] },
      searchBar: { searchTerm: "", searchPath: "/admin/export-checks" },
      filters: { active: false, allUrl: "/admin/export-checks", options: [] },
      pagination: { currentPage: 1, totalPages: 1, totalCount: 0, perPage: 10 },
      layoutActions: [],
      toolbarActions: [],
      emptyState: { title: "No export checks" },
      navigation: [],
      newResourcePath: "/admin/export-checks/new",
      resourceName: "Registered layout title",
      singularResourceName: "Export check",
    }) },
    React.createElement(pages.AdminIndex)
  )
);
if (!layoutMarkup.includes('data-export-check="registered-layout"')) {
  throw new Error("terrazzo/pages did not render the registered layout component");
}
if (!layoutMarkup.includes("Registered layout title")) {
  throw new Error("registered layout did not receive AdminIndex props");
}

const showMarkup = renderToStaticMarkup(
  React.createElement(
    ReduxProvider,
    { store: createSuperglueStore("/admin/export-checks/1", {
      pageTitle: "Registered show title",
      attributes: {},
      attributeGroups: [],
      layoutActions: [],
      editPath: "/admin/export-checks/1/edit",
      deletePath: "/admin/export-checks/1",
      indexPath: "/admin/export-checks",
      resourceName: "Export check",
      pluralResourceName: "Export checks",
      navigation: [],
    }) },
    React.createElement(pages.AdminShow)
  )
);
if (!showMarkup.includes('data-export-check="registered-layout"')) {
  throw new Error("terrazzo/pages did not render the registered layout component on AdminShow");
}
if (!showMarkup.includes('action="/admin/export-checks/1"') || !showMarkup.includes('value="delete"')) {
  throw new Error("AdminShow did not render a delete form with a Rails method override");
}
if (!showMarkup.includes('name="authenticity_token"')) {
  throw new Error("AdminShow did not render an authenticity token input");
}

const RegisteredField = ({ value }) =>
  React.createElement("span", { "data-export-check": "registered-field" }, value);

fields.registerFieldType("export_check", { form: RegisteredField });
if (fields.getFieldComponent("export_check", "form") !== RegisteredField) {
  throw new Error("terrazzo/fields registry did not return the registered field");
}
if (root.getFieldComponent("export_check", "form") !== RegisteredField) {
  throw new Error("terrazzo root field registry did not share the registered field");
}

const formMarkup = renderToStaticMarkup(
  React.createElement(pages.AdminForm, {
    errors: [],
    form: {
      props: { action: "/admin/export-checks", method: "post" },
      extras: {},
      fields: [
        {
          attribute: "name",
          fieldType: "export_check",
          value: "Registered field value",
          input: { id: "export_check_name", name: "export_check[name]" },
        },
      ],
    },
  })
);
if (!formMarkup.includes('data-export-check="registered-field"')) {
  throw new Error("terrazzo/pages did not render the registered form field component");
}
if (!formMarkup.includes("Registered field value")) {
  throw new Error("registered form field did not receive AdminForm props");
}

const RegisteredIndexField = ({ value }) =>
  React.createElement("span", { "data-export-check": "registered-index-field" }, value);

fields.registerFieldType("export_check_index", { index: RegisteredIndexField });
const tableMarkup = renderToStaticMarkup(
  React.createElement(components.ResourceTable, {
    headers: [{ attribute: "name", label: "Name" }],
    rows: [
      {
        id: "export-check-1",
        cells: [
          {
            attribute: "name",
            fieldType: "export_check_index",
            value: "Registered index field value",
          },
        ],
      },
    ],
    emptyState: { title: "No export checks" },
    showActions: false,
  })
);
if (!tableMarkup.includes('data-export-check="registered-index-field"')) {
  throw new Error("terrazzo/components ResourceTable did not render the registered index field component");
}
if (!tableMarkup.includes("Registered index field value")) {
  throw new Error("registered index field did not receive ResourceTable cell props");
}

const toolbarActionsMarkup = renderToStaticMarkup(
  React.createElement(components.CollectionToolbarActions, {
    actions: [
      { label: "Upper GET", url: "/upper-get", method: "GET" },
      { label: "Upper POST", url: "/upper-post", method: "POST" },
      { label: "Upper DELETE", url: "/upper-delete", method: "DELETE" },
    ],
  })
);
if (!toolbarActionsMarkup.includes('href="/upper-get"')) {
  throw new Error("CollectionToolbarActions did not normalize uppercase GET to a link action");
}
if (!toolbarActionsMarkup.includes('action="/upper-post"')) {
  throw new Error("CollectionToolbarActions did not normalize uppercase POST to a form action");
}
if (!toolbarActionsMarkup.includes('action="/upper-delete"') || !toolbarActionsMarkup.includes('value="delete"')) {
  throw new Error("CollectionToolbarActions did not normalize uppercase DELETE to a Rails method override");
}
if (toolbarActionsMarkup.includes('value="DELETE"')) {
  throw new Error("CollectionToolbarActions rendered an uppercase Rails method override");
}

const cjsComponents = require("terrazzo/components");
const cjsFields = require("terrazzo/fields");
const cjsPages = require("terrazzo/pages");
const cjsRoot = require("terrazzo");
const { Provider: CjsReduxProvider } = require("react-redux");
const CjsTestComponent = () => null;

if (cjsRoot.getLayout() !== RegisteredLayout) {
  throw new Error("terrazzo root CJS layout registry did not share the ESM registered layout");
}

cjsComponents.registerComponent("CjsExportCheckComponent", CjsTestComponent);
if (cjsComponents.getComponent("CjsExportCheckComponent") !== CjsTestComponent) {
  throw new Error("terrazzo/components CJS registry did not return the registered component");
}
if (cjsRoot.getComponent("CjsExportCheckComponent") !== CjsTestComponent) {
  throw new Error("terrazzo root CJS component registry did not share the registered component");
}

const CjsRegisteredResourceTable = ({ emptyState }) =>
  React.createElement("section", { "data-export-check": "cjs-registered-resource-table" }, emptyState?.title);

cjsComponents.registerComponent("ResourceTable", CjsRegisteredResourceTable);
const cjsMarkup = renderToStaticMarkup(
  React.createElement(cjsPages.AdminCollection, {
    table: { headers: [], rows: [] },
    emptyState: { title: "CJS registered empty state" },
  })
);
if (!cjsMarkup.includes('data-export-check="cjs-registered-resource-table"')) {
  throw new Error("terrazzo/pages CJS did not render the registered ResourceTable component");
}
if (!cjsMarkup.includes("CJS registered empty state")) {
  throw new Error("registered CJS ResourceTable did not receive AdminCollection props");
}

const CjsRegisteredLayout = ({ actions, children, title }) =>
  React.createElement("section", { "data-export-check": "cjs-registered-layout" }, title, actions, children);

cjsRoot.setLayout(CjsRegisteredLayout);
if (cjsRoot.getLayout() !== CjsRegisteredLayout) {
  throw new Error("terrazzo root CJS layout registry did not return the registered layout");
}
if (root.getLayout() !== CjsRegisteredLayout) {
  throw new Error("terrazzo root ESM layout registry did not share the CJS registered layout");
}

const cjsLayoutMarkup = renderToStaticMarkup(
  React.createElement(
    CjsReduxProvider,
    { store: createSuperglueStore("/admin/cjs-export-checks", {
      table: { headers: [], rows: [] },
      searchBar: { searchTerm: "", searchPath: "/admin/cjs-export-checks" },
      filters: { active: false, allUrl: "/admin/cjs-export-checks", options: [] },
      pagination: { currentPage: 1, totalPages: 1, totalCount: 0, perPage: 10 },
      layoutActions: [],
      toolbarActions: [],
      emptyState: { title: "No CJS export checks" },
      navigation: [],
      newResourcePath: "/admin/cjs-export-checks/new",
      resourceName: "CJS registered layout title",
      singularResourceName: "CJS export check",
    }) },
    React.createElement(cjsPages.AdminIndex)
  )
);
if (!cjsLayoutMarkup.includes('data-export-check="cjs-registered-layout"')) {
  throw new Error("terrazzo/pages CJS did not render the registered layout component");
}
if (!cjsLayoutMarkup.includes("CJS registered layout title")) {
  throw new Error("registered CJS layout did not receive AdminIndex props");
}

const cjsShowMarkup = renderToStaticMarkup(
  React.createElement(
    CjsReduxProvider,
    { store: createSuperglueStore("/admin/cjs-export-checks/1", {
      pageTitle: "CJS registered show title",
      attributes: {},
      attributeGroups: [],
      layoutActions: [],
      editPath: "/admin/cjs-export-checks/1/edit",
      deletePath: "/admin/cjs-export-checks/1",
      indexPath: "/admin/cjs-export-checks",
      resourceName: "CJS export check",
      pluralResourceName: "CJS export checks",
      navigation: [],
    }) },
    React.createElement(cjsPages.AdminShow)
  )
);
if (!cjsShowMarkup.includes('data-export-check="cjs-registered-layout"')) {
  throw new Error("terrazzo/pages CJS did not render the registered layout component on AdminShow");
}
if (!cjsShowMarkup.includes('action="/admin/cjs-export-checks/1"') || !cjsShowMarkup.includes('value="delete"')) {
  throw new Error("AdminShow CJS did not render a delete form with a Rails method override");
}
if (!cjsShowMarkup.includes('name="authenticity_token"')) {
  throw new Error("AdminShow CJS did not render an authenticity token input");
}

const CjsRegisteredField = ({ value }) =>
  React.createElement("span", { "data-export-check": "cjs-registered-field" }, value);

cjsFields.registerFieldType("cjs_export_check", { form: CjsRegisteredField });
if (cjsFields.getFieldComponent("cjs_export_check", "form") !== CjsRegisteredField) {
  throw new Error("terrazzo/fields CJS registry did not return the registered field");
}
if (cjsRoot.getFieldComponent("cjs_export_check", "form") !== CjsRegisteredField) {
  throw new Error("terrazzo root CJS field registry did not share the registered field");
}

const cjsFormMarkup = renderToStaticMarkup(
  React.createElement(cjsPages.AdminForm, {
    errors: [],
    form: {
      props: { action: "/admin/export-checks", method: "post" },
      extras: {},
      fields: [
        {
          attribute: "name",
          fieldType: "cjs_export_check",
          value: "CJS registered field value",
          input: { id: "cjs_export_check_name", name: "export_check[name]" },
        },
      ],
    },
  })
);
if (!cjsFormMarkup.includes('data-export-check="cjs-registered-field"')) {
  throw new Error("terrazzo/pages CJS did not render the registered form field component");
}
if (!cjsFormMarkup.includes("CJS registered field value")) {
  throw new Error("registered CJS form field did not receive AdminForm props");
}

const CjsRegisteredIndexField = ({ value }) =>
  React.createElement("span", { "data-export-check": "cjs-registered-index-field" }, value);

cjsFields.registerFieldType("cjs_export_check_index", { index: CjsRegisteredIndexField });
const cjsTableMarkup = renderToStaticMarkup(
  React.createElement(cjsComponents.ResourceTable, {
    headers: [{ attribute: "name", label: "Name" }],
    rows: [
      {
        id: "cjs-export-check-1",
        cells: [
          {
            attribute: "name",
            fieldType: "cjs_export_check_index",
            value: "CJS registered index field value",
          },
        ],
      },
    ],
    emptyState: { title: "No CJS export checks" },
    showActions: false,
  })
);
if (!cjsTableMarkup.includes('data-export-check="cjs-registered-index-field"')) {
  throw new Error("terrazzo/components CJS ResourceTable did not render the registered index field component");
}
if (!cjsTableMarkup.includes("CJS registered index field value")) {
  throw new Error("registered CJS index field did not receive ResourceTable cell props");
}

const cjsToolbarActionsMarkup = renderToStaticMarkup(
  React.createElement(cjsComponents.CollectionToolbarActions, {
    actions: [
      { label: "CJS Upper GET", url: "/cjs-upper-get", method: "GET" },
      { label: "CJS Upper POST", url: "/cjs-upper-post", method: "POST" },
      { label: "CJS Upper DELETE", url: "/cjs-upper-delete", method: "DELETE" },
    ],
  })
);
if (!cjsToolbarActionsMarkup.includes('href="/cjs-upper-get"')) {
  throw new Error("CollectionToolbarActions CJS did not normalize uppercase GET to a link action");
}
if (!cjsToolbarActionsMarkup.includes('action="/cjs-upper-post"')) {
  throw new Error("CollectionToolbarActions CJS did not normalize uppercase POST to a form action");
}
if (!cjsToolbarActionsMarkup.includes('action="/cjs-upper-delete"') || !cjsToolbarActionsMarkup.includes('value="delete"')) {
  throw new Error("CollectionToolbarActions CJS did not normalize uppercase DELETE to a Rails method override");
}
if (cjsToolbarActionsMarkup.includes('value="DELETE"')) {
  throw new Error("CollectionToolbarActions CJS rendered an uppercase Rails method override");
}

function assertExports(specifier, mode, mod, names) {
  const missing = names.filter((name) => !(name in mod));
  if (missing.length > 0) {
    throw new Error(`${specifier} ${mode} is missing exports: ${missing.join(", ")}`);
  }
}

function sourceBarrelExports(relativePath) {
  const source = readFileSync(new URL(relativePath, import.meta.url), "utf8");
  const names = [];
  const exportPattern = /export\s*\{(?<exports>[^}]*)\}\s*from\s*["'][^"']+["'];?/gm;

  for (const match of source.matchAll(exportPattern)) {
    names.push(
      ...match.groups.exports
        .split(",")
        .map((name) => name.trim())
        .filter(Boolean)
        .map((name) => name.split(/\s+as\s+/).pop().trim())
    );
  }

  if (names.length === 0) {
    throw new Error(`${relativePath} did not define any named exports`);
  }

  return [...new Set(names)].sort();
}

function createSuperglueStore(pageKey, data) {
  const state = {
    superglue: { currentPageKey: pageKey, search: {}, assets: [] },
    pages: { [pageKey]: { data } },
  };

  return {
    getState: () => state,
    subscribe: () => () => {},
    dispatch: () => {},
  };
}
