# Day 001 — Binary Numbers

## Learning Objectives
- Understand why computers use binary.
- Convert small numbers between decimal and binary.
- Recognize how binary relates to files, memory, permissions, and machine state.

## Core Concepts
Binary is base-2. It uses only `0` and `1`.

Each binary digit is a bit.

## Hands-On Lab
Inspect a file as bytes:

```bash
cd ~/Wonderland
printf "Wonderland\n" > /tmp/wl-binary-demo.txt
xxd -b /tmp/wl-binary-demo.txt
xxd /tmp/wl-binary-demo.txt
Wonderland Integration

Binary-style state appears in:

File permissions
Exit codes
Flags
Configuration states
Machine-level data
Verification

You should be able to explain why the letter W appears as a byte value.

Quiz
What base is binary?
How many values can one bit represent?
What is 1010 in decimal?
Why do computers use binary?
Where does Wonderland use binary-like state?
Reflection

Write 3–5 sentences in your learning journal.

## Lesson Overview
This lesson introduces the topic and explains how it connects to Wonderland.

## Prerequisites
- Access to `~/Wonderland`
- Basic terminal access

## Why This Matters
Reliable engineering depends on accurate mental models. This concept helps explain how Wonderland behaves under real operating conditions.

## Technical Deep Dive
Start with the machine-level behavior, then connect it to the human-facing abstraction used by engineers.

## Real-World Example
`wl doctor` converts low-level system facts into understandable PASS/FAIL output.

## Wonderland Integration
Identify one place in Wonderland where this concept appears and document it in your journal.

## Verification Checklist
- [ ] I can explain the concept.
- [ ] I completed the lab.
- [ ] I connected the concept to Wonderland.
- [ ] I recorded notes in my journal.

## Knowledge Check
See the matching quiz file under `academy/07-quizzes/daily/`.

## Optional Challenge
Find one additional Wonderland subsystem that uses this concept indirectly.

## Summary
This lesson strengthens the foundation needed to debug, design, operate, and improve Wonderland.

## Further Reading
- `academy/05-reference/glossary/FOUNDATIONS.md`
- `academy/05-reference/cheat-sheets/FOUNDATIONS.md`

## Next Lesson Preview
The next lesson builds on this concept and connects it to the next layer of the computing stack.
