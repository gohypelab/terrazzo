import { defineConfig } from "vitepress";
import { readFileSync } from "fs";

const { version } = JSON.parse(
  readFileSync(new URL("../../npm/package.json", import.meta.url), "utf-8")
);

export default defineConfig({
  title: "Terrazzo",
  description:
    "A Rails admin framework powered by Superglue and React",
  base: "/terrazzo/",

  head: [
    ["link", { rel: "icon", type: "image/svg+xml", href: "/terrazzo/logo.svg" }],
  ],

  themeConfig: {
    nav: [
      { text: "Guide", link: "/guide/getting-started" },
      { text: "Reference", link: "/reference/dashboards" },
      {
        text: version,
        items: [
          {
            text: "Changelog",
            link: "https://github.com/gohypelab/terrazzo/releases",
          },
        ],
      },
    ],

    sidebar: {
      "/guide/": [
        {
          text: "Introduction",
          items: [
            { text: "What is Terrazzo?", link: "/guide/what-is-terrazzo" },
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
      { icon: "github", link: "https://github.com/gohypelab/terrazzo" },
    ],

    search: {
      provider: "local",
    },

    footer: {
      message: "Released under the MIT License.",
    },
  },
});
