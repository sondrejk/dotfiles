# Preferences

## Language and tone

- Reply in Norwegian if I write Norwegian. English if I write English.
- Code, commit messages, identifiers and documentation in repos: English.
- Write memory files in English.
- Never use an em dash ("—"). Use a plain dash ("-") instead.

## Code

- Write few comments. Comment _why_, never _what_, because the code says what.
  No comment that repeats the line below it.
- Avoid multi-line comments wherever possible.
- Never edit CHANGELOG.md or any file marked as auto-generated.
  Change the source that generates them.

## Technical decisions

- Give little weight to development cost when you choose a solution.
  Prefer quality, simplicity, robustness, scalability and long-term maintainability.

## Bug fixing

- Always start by reproducing the bug end to end, as close as possible to how an
  end user meets it.
  This is how you find the real problem, so the fix actually solves it.

## Testing and quality

- When you test end to end, be picky about the UI you see and aim for pixel perfection.
  If something clearly looks wrong, even when it is unrelated to your task,
  try to get it fixed along the way.
- The same standard applies to engineering quality: lint, failing tests and flaky tests.
  If you see one, fix it, even when it was not caused by what you work on now.

## Terminal output

- Bash commands you want me to copy always go on their own line,
  with no characters in front of the command.

## Documentation

- Use the technical-documentation skill whenever you write documentation of any kind.
- When you write or substantially edit long Markdown files: one full sentence per line.
  Keep normal Markdown structure, but avoid wrapping several sentences onto one physical line.

## Git

- Do not commit or push unless I ask for it.
- If I am on the default branch, create a branch first.
- Use conventional commits format.
- Never add your agent name as co-author in commit messages.

## Skills

- To install a new skill: use the install-skill skill. It knows the procedure.
