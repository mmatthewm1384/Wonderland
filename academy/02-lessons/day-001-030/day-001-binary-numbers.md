# Day 001 — Binary Numbers

## Objectives
- Understand why computers use binary.
- Convert small numbers between decimal and binary.
- Recognize how binary relates to files, memory, permissions, and machine state.

## Core Concepts
Binary is base-2. It uses only `0` and `1`.

Each binary digit is a bit.

## Lab
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
