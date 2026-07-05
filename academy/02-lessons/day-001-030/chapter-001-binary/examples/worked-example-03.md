
Worked Example 03 — Exit Codes

Run:

true
echo $?

Expected:

0

Run:

false
echo $?

Expected:

1

Interpretation:

Exit code 0 conventionally means success. A nonzero exit code means failure or exceptional condition.
