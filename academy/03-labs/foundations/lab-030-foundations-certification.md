# Lab 030 — Foundations Certification
Objective

Complete Module 1 certification project.

Estimated Time

30–60 minutes.

Safety

This lab is read-oriented unless explicitly instructed otherwise. Avoid deleting, moving, or rewriting platform files.

Steps
cd ~/Wonderland
pwd

Inspect the Academy and Wonderland context:

wl academy today
wl academy status
find academy -maxdepth 2 -type d | sort | head -40

Perform the topic-specific investigation:

echo "Lesson 030: Foundations Certification"
ls -la

For file-oriented lessons, inspect representative files:

find . -maxdepth 2 -type f | head -20
Wonderland Improvement

Add or improve one small note related to this lesson.

Suggested location:

academy/09-progress/journal/day-030.md
Verification
wl academy doctor
wl academy certify

Expected:

RESULT PASS
Rollback

If you only wrote journal/reference notes, rollback with Git if needed:

git status --short
git restore <path>
Reflection

Write 3–5 sentences:

What did I learn?
Where does this appear in Wonderland?

What still feels unclear?
