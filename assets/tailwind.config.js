const Color = require("color")
const defaultTheme = require("tailwindcss/defaultTheme")

const lighten = (clr, val) => Color.default(clr).lighten(val).rgb().string()
const darken = (clr, val) => Color.default(clr).darken(val).rgb().string()

/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./js/**/*.{tsx,ts}", "../lib/demo_web/**/*"],
  theme: {
    extend: {
      colors: {
        "beanie-gold": {
          50: lighten("#FEBD3B", 0.6),
          100: lighten("#FEBD3B", 0.5),
          200: lighten("#FEBD3B", 0.4),
          300: lighten("#FEBD3B", 0.3),
          600: "#FEBD3B",
          900: darken("#FEBD3B", 0.6)
        },
        cobalt: {
          100: "#D9E9EF",
          200: darken("#D9E9EF", 0.2),
          300: lighten("#006E97", 0.3),
          600: "#006E97",
          700: darken("#006E97", 0.1),
          800: darken("#006E97", 0.2),
          900: darken("#006E97", 0.3)
        },
        pink: {
          600: "#e5097f"
        }
      }
    }
  },
  plugins: [require("@tailwindcss/forms"), require("@tailwindcss/typography")]
}
