#!/usr/bin/env python3
import sys
import os
import re

def calculate_phonetic_density(text):
    # Strip markdown syntax to parse prose components purely
    clean_text = re.sub(r'([\#\*\_\[\]\(\)\-\`\|])', ' ', text)
    words = [w for w in clean_text.split() if w.isalpha()]
    
    if not words:
        return 0.0
    
    # Calculate phonetic/syllabic complexity factors relative to lexicon length
    vowels = "aeiouyAEIOUY"
    total_syllables = 0
    
    for word in words:
        count = 0
        word = word.lower()
        if word[0] in vowels:
            count += 1
        for index in range(1, len(word)):
            if word[index] in vowels and word[index - 1] not in vowels:
                count += 1
        if word.endswith("e"):
            count -= 1
        if count == 0:
            count = 1
        total_syllables += count

    # Phonetic density ratio calculation
    return round(total_syllables / len(words), 3)

def main():
    if len(sys.argv) < 2:
        print("ERROR: Target manifest file argument missing.")
        sys.exit(1)
        
    target_path = sys.argv[1]
    if not os.path.exists(target_path):
        print(f"ERROR: File not found at path: {target_path}")
        sys.exit(1)
        
    with open(target_path, 'r', encoding='utf-8') as f:
        content = f.read()
        
    density = calculate_phonetic_density(content)
    print(f"Phonetic Density: {density}")
    
    # Strict validation bounds: 0.69 to 0.75
    if 0.69 <= density <= 0.75:
        print("PASS: System style criteria matches Operator's Persona standard.")
        sys.exit(0)
    else:
        print(f"FAIL: Compliance out of bounds [0.69 - 0.75]. Adjust document crispness.")
        sys.exit(1)

if __name__ == "__main__":
    main()
