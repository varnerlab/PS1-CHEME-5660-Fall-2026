# PS1 grading rubric

Every problem set in CHEME 5660 is worth the same maximum ordinary score: **4**. Students are responsible only for the requirements of their selected track. The unselected track may retain its starter code and response placeholders.

You may switch between Standard and Advanced before submitting or on an eligible revision. Each submission is graded only on the track selected in `TRACK.txt`. If you change tracks, update `TRACK.txt`, complete that track's code and response files, and rerun the checker. You may reuse your own valuation code, but the discussion questions differ between tracks. We keep your highest score across all submissions, even if you change tracks.

Standard contains **13 public checks**; Advanced contains **16**. Each check is evaluated independently. Standard has three bill checks, five note checks, four independent repricing checks, and one complete-workflow check. Advanced reuses all 13 valuation checks and adds three funding-comparison checks. Independent checks use supplied inputs so unfinished upstream tasks do not erase credit for other work. A check that cannot run counts as failed.

| Score | Standard | Advanced |
|:---:|:---|:---|
| 0 | The grading harness could not execute checks, or 0 of 13 passed. | The grading harness could not execute checks, or 0 of 16 passed. |
| 1 | 1–6 of 13 checks passed. | 1–8 of 16 checks passed. |
| 2 | 7–12 of 13 checks passed. | 9–15 of 16 checks passed. |
| 3 | All 13 passed, but at least one applicable completion requirement was missing or not acceptable. | All 16 passed, but at least one applicable completion requirement was missing or not acceptable. |
| 4 | All 13 passed and every applicable completion requirement was accepted. | All 16 passed and every applicable completion requirement was accepted. |

Only the track selected in `TRACK.txt` is graded. If you select Advanced and pass the 13 valuation checks but fail the three funding checks, your score is **2**. We do not automatically grade that submission as Standard.

An accepted Advanced score of 4 earns **one Magic Point**, including a 4 earned through an eligible revision. The bonus is awarded once for PS1 and does not change its maximum ordinary score of 4.

## Official test procedure

The output from `check_submission.jl` is feedback, not the official grade. For grading, the teaching team starts with a clean copy of the tagged assignment release, copies the student's selected track source file and any student-created helpers under `src`, and copies `TRACK.txt` and the selected response file under `responses`. Instructor-owned support code, reports, tests, checker, and data are retained. Student modifications to these supplied files are ignored. This keeps the same grading target for every student and every revision.

Keep the supplied function names, arguments, and return types in your selected track file, and load any separate helper files it uses. A source syntax or load error can prevent the track's checks from running. Ordinary calculation errors are caught separately for each check, allowing other tasks to receive credit. Missing or invalid track selection must be corrected before the checker can select a suite.

## Completion review

To earn a 4, the selected track must meet all of these requirements:

- All requested functions are implemented with the specified interfaces. Both tracks use the course package to build and price their securities and to reprice the note. Advanced also calls the supplied comparison function for the four specified strategies.
- Public functions document their purpose, inputs, outputs, and relevant errors. Preserve the supplied docstrings and update them if your implementation needs additional explanation.
- Any helper function briefly describes its purpose, inputs, and outputs. Comments explain logic that would otherwise be difficult to follow.
- No unresolved starter TODO, placeholder error, or knowingly incomplete task remains in the selected solution. Remove or update TODO comments when their tasks are complete.
- Answers to all three discussion questions for the selected track address the questions, explain the reasoning, and include the requested numerical results with clear units.

The local checker detects missing docstrings and empty, missing, or unfinished marked answer blocks. However, these mechanical checks do not assess the substance of the work.

If all numerical checks pass but completion review is still needed, the result is **pending review**, not a provisional score of 3. The final score becomes 4 when all applicable requirements are accepted; it becomes 3 only when at least one requirement is actually found incomplete or unacceptable.

## Initial submissions and revisions

A qualifying initial submission is a readable assignment ZIP containing attempted work, submitted by **Sunday, September 20, 2026 at 11:59 PM ET**. Incomplete work or failing tests can still qualify. An empty placeholder or unreadable archive does not. A missing qualifying submission receives a Frozen Zero and is ineligible for revision or Magic Points.

After the initial deadline, eligible students may revise as many times as they like until **December 19, 2026 at 11:59 PM ET**, the last day of academic activity. Use **New Attempt on the same PS1 Canvas assignment**, following the ZIP procedure in [README.md](README.md). Canvas's late label on these revisions creates no penalty under this policy. Each revision is graded, and the highest score earned is retained.

The reference solution will be released after the initial deadline. Students may use it to understand mistakes and debug their own work, but may not copy it. Copying the reference solution results in a locked score of 0 for the assignment. The independent-work policy also applies to revisions.
