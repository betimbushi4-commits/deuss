# Deuss Studio — Massage CRM

## IMPORTANT: how to upload to GitHub so Vercel works

Your repo must contain ALL 6 of these files. The most reliable way is to upload
them ONE AT A TIME (or select all 6 at once) — there are NO folders to worry about.

The 6 files:
- App.jsx
- main.jsx
- index.html
- package.json
- vite.config.js
- .gitignore

### Steps
1. Go to https://github.com/Nazimi1/deuss
2. Delete the old `deuss-massage-crm (1).jsx` (open it → trash icon → Commit changes).
3. Click **Add file → Upload files**.
4. Drag in ALL 6 files from this folder (select them all together).
5. BEFORE committing, check the list — you should see all 6 names.
6. Click **Commit changes**.
7. Vercel will auto-redeploy and succeed.

### Verify your repo looks right
After committing, github.com/Nazimi1/deuss should list exactly:
App.jsx · main.jsx · index.html · package.json · vite.config.js · .gitignore

(No `src` folder — everything is flat. That's intentional and correct.)

---

## Run locally (optional)
```
npm install
npm run dev
```

## Note on data
Data is stored in your browser (localStorage). It persists per-browser but is not
shared across devices. Ask Claude for the Supabase version when you want shared,
permanent storage with a team login.
