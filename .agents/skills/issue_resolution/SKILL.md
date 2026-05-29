---
name: Issue Resolution and Documentation Transition
description: A workflow for systematically implementing remediation paths for unresolved issues and transitioning them to the "Production Refinements & Technical Debt" section of the documentation.
---

# Issue Resolution Skill

This skill allows Antigravity to execute an iterative implementation plan based on the "Active Limitations & Narrative Backlog" documented in the project. It focuses on taking a user's selected remediation path, applying it to the codebase, and updating the engineering history.

## 📋 Pre-requisites
1.  Access to the target documentation file (e.g., [phase_4_cinematic_storytelling.md](file:///Users/louisye/Desktop/Louis%20Y./StoryArc/docs/phase_4_cinematic_storytelling.md)).
2.  Access to the Project's [Bug Documentation Guidelines](file:///Users/louisye/Desktop/Louis%20Y./StoryArc/.agents/skills/bug_documentation_guidelines/SKILL.md).

## 🛠 Workflow Steps

### 1. Issue Parsing & Prioritization
- Read the `## 🎬 Active Limitations & Narrative Backlog` section of the target document.
- Identify the first issue that has a value filled in for `Your selection: [Selection]`.
- If no selection is made, stop and ask the user for guidance or proceed to the next issue if others are selected.

### 2. Context Gathering
- Read the full technical context of the issue:
    - **Status**: The confirmed failure mode and location.
    - **Selection**: The specific technical path chosen by the user (Option A, B, etc.).
- Locate the relevant source files and logic blocks in the codebase.

### 3. Implementation
- Execute the technical changes required by the selected option.
- **Validation**:
    - Run existing unit/widget tests to ensure no regressions.
    - Create/run a targeted test (e.g., a scratch script or a new widget test under `test/`) to verify the fix.
- **Conflict Handling**:
    - If the selected option is technically impossible or significantly more complex than described, **do not force it**.
    - Update the documentation with a new set of refined options (Option A.1, A.2, etc.) and explain the new constraints.

### 4. Documentation Transition
- Once verified, **remove** the issue from the `## 🎬 Active Limitations & Narrative Backlog` section of the phase document.
- **ADD** the issue to the `## 🎞️ Production Refinements & Technical Debt` section.
- **REFORMAT** according to the [Bug Documentation Guidelines](file:///Users/louisye/Desktop/Louis%20Y./StoryArc/.agents/skills/bug_documentation_guidelines/SKILL.md):
    - Add the date tag: `(Finalized - Month DD)`.
    - Provide a concise `**Root Cause**` summary based on the original issue.
    - Provide a detailed `**Implementation**` summary reflecting the *actual* code changes made.

### 5. Cleanup
- Remove any temporary scratch scripts or test artifacts created during implementation.
- Ensure the file numbering in both documentation sections is sequential and correct.

## 🏁 Success Criteria
- The codebase reflects the implementation of the user's selected remediation path.
- The documentation accurately transitions the issue from "Active Limitations & Narrative Backlog" to "Production Refinements & Technical Debt".
- All formatting follows the project's strict engineering history standards.
