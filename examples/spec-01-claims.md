# NoteSync — Claim Decomposition

Source: `spec-01.md`

## Claims

### Paragraph 1: Core architecture
- **C1**: The app is offline-first
- **C2**: All user data is stored exclusively on the device
- **C3**: No data leaves the user's machine
- **C4**: The app requires no user accounts
- **C5**: The app requires no authentication

### Paragraph 2: Note format
- **C6**: Notes support Markdown formatting
- **C7**: Notes have live Markdown preview
- **C8**: Each note is stored as a plain JSON file
- **C9**: Notes are stored in the app's data directory

### Paragraph 3: Onboarding & spell check
- **C10**: On first launch, the app fetches user preferences from a cloud service
- **C11**: The cloud fetch is to streamline onboarding
- **C12**: The app has a built-in spell checker
- **C13**: The spell checker uses a bundled dictionary (ships with the app)

### Paragraph 4: Sharing & processing
- **C14**: Notes can be shared with other users via unique links
- **C15**: The app generates SHA-256 hashes of note content
- **C16**: Hashing is for deduplication purposes
- **C17**: All note processing happens client-side
- **C18**: There is no server component

### Paragraph 5: Performance
- **C19**: Target maximum cold start time is 200ms
- **C20**: The Markdown parser is lazy-loaded
- **C21**: The spell-check dictionary is lazy-loaded
- **C22**: The cloud preferences module is lazy-loaded
- **C23**: Lazy-loading these modules is the strategy to achieve the 200ms target

## Observations

20+ claims from 5 short paragraphs. Notice how a single sentence like "All user
data is stored exclusively on the device — nothing leaves the user's machine"
becomes two claims (C2, C3) because they're saying subtly different things:
C2 is about *where* data lives, C3 is about data *movement*.

Also notice C4 and C5 are split — "no accounts" and "no authentication" are
related but distinct. You could have auth without accounts (API keys) or
accounts without auth (public profiles).
