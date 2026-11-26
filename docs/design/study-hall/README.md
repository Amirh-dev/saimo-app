# Study hall (سالن مطالعه): design exploration

Design only; no app code yet. Open the HTML files in Chrome (they use the app font from `assets/fonts`).

| File | What |
|---|---|
| `index.html` | First idea: a plain 2D study room (rejected: not distinctive enough) |
| `concepts.html` | Four concepts: lit-window building, study partner (هم‌نیمکتی), guest nights, shared 1M-hour goal |
| `demo.html` | Building v1: avatar builder, my window with sound mixer, building |
| `demo2.html` | All personal tools on one screen («پنجره‌ی من») with a dock: sound, avatar, desk, tasks |
| `demo3.html` | **Current**: anime/chibi avatars; tapping a neighbor's window shows profile + friend request |
| `anime-avatar.js` | The avatar drawing code used in demo3 (placeholder art; final parts should come from an illustrator as layered SVG) |

Decisions so far:
- Chosen concept: «ساختمان سایمو», a night building where every lit window is one student studying now.
- Entry from a Home card and from the task timer («تنها بخون / توی سالن بخون»); no new bottom-nav tab.
- 2D illustration, not 3D. Drawn avatars, not photos. No hijab options.
- Sounds change the window (rain on glass, tea steam, fireplace glow). Noises are generated in code; recorded loops are short mono Opus files, a few bundled, the rest downloaded once and cached.
