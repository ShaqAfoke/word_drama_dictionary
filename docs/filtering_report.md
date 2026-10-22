# Dictionary filtering report

## Source

- Source: Wordnik game wordlist, `wordlist-20210729.txt`
- Vendored revision: `46e6215d0f90356afe9c8ba4be347e7e98cb425c`
- License: MIT, Copyright (c) 2020 Wordnik; see `licenses/WORDNIK_LICENSE`.
- Build command: `dart run tool/build_dictionary.dart`

## Counts

| Measure | Count |
| --- | ---: |
| Original source entries | 198422 |
| Accepted A-Z words (2-8 letters) | 94085 |
| Curated retain entries checked | 7 |
| Curated rejected entries | 7 |

## Exclusions

| Reason | Count |
| --- | ---: |
| `invalid_json_or_non_string` | 0 |
| `unsupported_characters` | 0 |
| `outside_2_to_8_letters` | 104335 |
| `curated_denylist` | 2 |
| `duplicate` | 0 |

## Ambiguous entries and review

The review register is `tool/curation/review_words.md`. It deliberately keeps
FLAKE, FLAKES, FLAKING, OHO, QI, ZA, and JO when present in the source.
No word is rejected for rarity, short length alone, an interjection use, or a
possible acronym/name use. The current curated denylist rejects only explicit,
reviewable entries: FBI, NASA, AARON, OHIO, QXZ, FAA, and PARIS.

Missing curated retain entries: none.

## Limitations

The source does not supply lexical labels or definitions. This filter enforces
format and length mechanically and applies only documented curated decisions;
it cannot prove that every remaining source entry is an ordinary English word
or identify every proper noun or abbreviation. Ambiguous words are retained
for review rather than automatically classified from capitalization, rarity,
or length. The generated data is suitable for offline game validation, not a
claim of exhaustive dictionary authority or guaranteed playable moves.
