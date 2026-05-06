# Week 5 - Bristle POC and MVP

## What I Did

### Session 1 - Building from Zero

Starting point: no development environment, no GitHub account, no coding background. By end of session:

- Installed Claude Code and configured it with VS Code
- Installed Flutter SDK and the full Android toolchain
- Set up an Android emulator (Medium Phone, Android 15)
- Created a GitHub account and initialized the Bristle repo
- Built and ran the first Bristle POC on the emulator

The POC: a Flutter Android app with a toothbrush mascot named Bristle that gives random cybersecurity tips on button tap. Simple, but it runs, and it was great to go from nothing to a working app in one session.

### Session 2 - V2 Improvements

Came back the next night and did a full content and UX review before adding features. Changes made:

- Added tip categories (Passwords, Phishing, Mobile, Physical Security) with 6 tips each
- Replaced the single tip button with forward/back navigation and a tip counter 
- Fixed UI jitter. The button area now stays anchored regardless of tip length
- Replaced the toothbrush emoji mascot with an AI-generated PNG character. Went through several iterations before landing on something that actually looked right
- Reviewed all tip content and cleaned it up: removed em dashes, fixed American English spelling, cahnged tip wording (changed "urgency is a red flag" to "urgency is often a red flag", changed "be cautious about unexpected USB drives" to "never plug in an unexpected USB drive")

## Why I Did It This Way

**Flutter over React Native or Kotlin/Java** -- beginner friendliness and strong AI tooling support. With zero prior coding experience, I needed a framework where Claude Code could help me move, not one where I would be fighting syntax constantly.

**POC before features** -- wanted a working proof of concept first. Get something running, then build on it. Adding features to broken scaffolding is harder than adding features to working scaffolding.

**GitHub from day one** -- version control is needed when other students will eventually be scanning projects for vulnerabilities. A clean commit history also documents the development process.

**AI tools used throughout** -- Claude for planning and architecture decisions, Claude Code for code generation. The manager/tech team dynamic feels real. I reviewed what Claude Code built before approving it, made scope decisions, and flagged content issues rather than just accepting whatever was generated.

**Content review before feature creep** -- before adding anything new in Session 2, I read through every tip and flagged problems: overly absolute language, British English, em dashes, ambiguous advice. A cybersecurity awareness app with bad or misleading tips defeats its own purpose.

## Connection to Learning Objectives

**Unit 1 - Security Plan** -- starting with version control, a defined tech stack, and a documented project scope is the beginning of a security posture. The decisions made now (what to build, how to host it, who can access it) are the foundation the SSP will document later. The EC2 decision is also tied to this, thinking about enterprise-grade infrastructure at the start rather than retrofitting later.


## What I Learned

The toolchain setup is the hard part for a beginner. Flutter, Android Studio, PATH variables, emulator configuration. None of it is obvious without guidance. Once the environment works though, going from zero to a running app is surprisingly fast with AI assistance.

The more interesting lesson was from Session 2 -- content quality matters as much as code quality. It is easy to let AI generate tip text and use it without review. Reading through it carefully found some issues: some tips were too absolute, British spellings, em dashes that read as AI-generated, and one tip that said "be cautious" about something that should have been a hard "never." That review process felt more like actual security work than the coding did.

Also learned the basic Git workflow: add, commit, push. Using it every session now.