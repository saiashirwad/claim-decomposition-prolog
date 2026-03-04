# NoteSync — Technical Spec

NoteSync is an offline-first note-taking app. All user data is stored exclusively on the device — nothing leaves the user's machine. The app requires no user accounts or authentication.

Notes support Markdown formatting with live preview. Each note is stored as a plain JSON file in the app's data directory.

On first launch, the app fetches the user's preferences from our cloud service to streamline onboarding. A built-in spell checker validates text against a bundled dictionary that ships with the app.

Notes can be shared with other users via unique links. The app generates a SHA-256 hash of each note's content for deduplication purposes. All note processing happens client-side with no server component.

The app targets a maximum cold start time of 200ms. To achieve this, it lazy-loads the Markdown parser, the spell-check dictionary, and the cloud preferences module at startup.
