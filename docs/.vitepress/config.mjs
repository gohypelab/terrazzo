import { defineConfig } from "vitepress";

export default defineConfig({
  title: "SuperAdmin",
  description:
    "A Rails admin framework powered by Superglue and React",
  base: "/super-admin/",

  head: [
    ["link", { rel: "icon", type: "image/svg+xml", href: "/super-admin/logo.svg" }],
  ],

  themeConfig: {
    nav: [
      { text: "Guide", link: "/guide/getting-started" },
      { text: "Reference", link: "/reference/dashboards" },
      {
        text: "0.1.0",
        items: [
          {
            text: "Changelog",
            link: "https://github.com/super-admin/super_admin/releases",
          },
        ],
      },
    ],

    sidebar: {
      "/guide/": [
        {
          text: "Introduction",
          items: [
            { text: "What is SuperAdmin?", link: "/guide/what-is-super-admin" },
            { text: "Getting Started", link: "/guide/getting-started" },
          ],
        },
        {
          text: "Essentials",
          items: [
            { text: "Dashboards", link: "/guide/dashboards" },
            { text: "Fields", link: "/guide/fields" },
            { text: "Controllers", link: "/guide/controllers" },
            { text: "Views & Components", link: "/guide/views" },
          ],
        },
      ],
      "/reference/": [
        {
          text: "Reference",
          items: [
            { text: "Dashboard DSL", link: "/reference/dashboards" },
            { text: "Field Types", link: "/reference/field-types" },
            { text: "Generators", link: "/reference/generators" },
          ],
        },
      ],
    },

    socialLinks: [
      { icon: "github", link: "https://github.com/super-admin/super_admin" },
    ],

    search: {
      provider: "local",
    },

    footer: {
      message: "Released under the MIT License.",
    },
  },
});
