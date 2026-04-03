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
      { text: "Documentation", link: "/getting-started" },
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

    sidebar: [
      {
        text: "Documentation",
        items: [
          { text: "What is Terrazzo?", link: "/what-is-terrazzo" },
          { text: "Getting Started", link: "/getting-started" },
          { text: "Customizing Dashboards", link: "/customizing-dashboards" },
          { text: "Customizing Page Views", link: "/customizing-page-views" },
          { text: "Customizing Fields", link: "/customizing-fields" },
          { text: "Customizing Controller Actions", link: "/customizing-controller-actions" },
          { text: "Authentication", link: "/authentication" },
          { text: "Authorization", link: "/authorization" },
          { text: "Generators", link: "/generators" },
        ],
      },
    ],

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
