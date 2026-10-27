# Internal Knowledge Matching Platform

> 🚧 **Work in progress.** This README reflects the current concept and will change as the project develops.

An internal tool that helps employees who are stuck on a problem find the right answer or the right colleague, fast. It checks the knowledge base first, and if that doesn't help, suggests the three best-matched experts who have the relevant knowledge *and* the time to help.

Group project for **Agile Digital Product Development** at IE Business School (MiM, Digital Strategy & Transformation).

## The problem

In knowledge-heavy organisations (we're currently looking at consulting and IT services firms of roughly 200–2,000 employees), people waste time figuring out "who knows X?". When they do find someone, it's usually the same few experts, who end up overloaded.

## How it works

1. An employee describes their problem in a chat box.
2. The system tries to answer from the knowledge base first.
3. If that fails, it suggests 3 colleagues, each with a short "why this person" explanation.
4. The employee picks a free slot and requests a meeting.
5. A quick rating after the meeting improves future matches.

## Design principles

- **Knowledge base before people:** protects experts from being overloaded.
- **Availability means capacity and consent:** experts opt in and set a weekly help budget; a free calendar slot alone isn't enough.
- **Skills from evidence:** skills are drawn from past work and confirmed by the employee, not only self-declared.
- **Every match is explained:** this builds trust and makes it easy to override a match.
- **Privacy by design:** opt-in, transparent about what's stored, no individual performance reporting.

## MVP scope

The first version focuses only on the **"stuck employee finds an expert"** case and runs on synthetic seed data:

- Seeded employee profiles with skill tags
- A catalogue of common problem types
- Free-text search that maps to a problem type
- A simple matching algorithm (skills + availability) returning the top 3
- Result cards with a reason for each match and a related document
- Mock availability slots and meeting request
- Thumbs up/down feedback

**Not in the MVP:** real calendar or knowledge-base integrations, profile editing, admin features, manager staffing mode, analytics, and production-grade security and GDPR controls (these are required before any real pilot).

## Tools

- Jira / Jira Product Discovery: backlog, epics and prioritisation
- Figma: prototyping

## Status & next steps

The concept, epics and feature list are drafted, and MVP scope is proposed. Up next: Product Vision, personas, riskiest assumptions as Discovery experiments, the seed data sheet, and Jira stories with acceptance criteria.

## Team

_To be added._
