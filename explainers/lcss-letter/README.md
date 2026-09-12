# Interactive reading guide for the L-CSS letter

**Publication status:** This is an L-CSS submission manuscript. It has not been accepted for publication.


[**Open the guide**](https://anrgusc.github.io/TINA/lcss-letter/)

This guide explains **Too Late to Coordinate: When Local Information Beats
Global Sharing**, by Scott Moeller and Bhaskar Krishnamachari. It does not explain
the full TINA arXiv manuscript. It covers the
notation, seven formal results, and all 73 proof steps, with 260 worked substeps
and plain-English explanations. Readers can adjust text from 14 to 40 px,
use Back/Next buttons or keyboard arrows, and jump through the chapter menu.
Detailed derivations can be collapsed. Mathematics, fonts, figures, and PDFs
are bundled locally, so the guide also works offline by opening `dist/index.html`.

## Which manuscript does this explain?

The guide explains the manuscript at repository commit
[`61f68b2b4c9340df44d3ee5bbc56d8fad9e5b6c3`](https://github.com/ANRGUSC/TINA/tree/61f68b2b4c9340df44d3ee5bbc56d8fad9e5b6c3/papers/lcss).

- [Editable manuscript and simulations](../../papers/lcss/)
- [Exact submission PDF](../../submissions/lcss/lcss-paper.pdf)
- [Lamport proof report](../../proof-reports/lcss-letter/)
- [Recorded source and PDF hashes](manuscript.json)

The PDFs in `papers/lcss/main.pdf`, `submissions/lcss/lcss-paper.pdf`, and the
guide's `dist/paper.pdf` are identical. The report's archived manuscript predates
three vertical-spacing adjustments. Its mathematical statements and proofs
are unchanged. The guide adds explanatory calculations to make those proofs
easier to follow. The report and guide are mathematical review and teaching
materials, rather than proof-assistant certificates.

## Edit and build

- `build_content.py`: assembles the 14 chapters and 136 reading steps.
- `content/formal_results.json`: formal claims and source-mapped proof steps.
- `content/proof_explanations.txt`: short plain-English explanations.
- `content/detailed_explanations.py`: intermediate calculations and reasoning.
- `dist/app.js`, `dist/styles.css`, `dist/index.html`: accessible reading interface.
- `dist/vendor/`: KaTeX 0.16.22 and its MIT license. Other repository content
  follows the repository's [BSD 3-Clause license](../../LICENSE).

From the repository root, with Python 3 and Node.js installed:

```bash
python3 explainers/lcss-letter/build_pages.py
```

This verifies the manuscript and PDF fingerprints, regenerates the lessons,
checks every mathematical expression and local asset reference, and assembles
the publishable site under `_site/`. No npm or pip installation is needed.

The GitHub Pages workflow publishes changes on `main` that affect the guide,
its manuscript resources, or the workflow. The manifest deliberately pins the
explained manuscript. If its source changes, review the guide for correspondence
before updating `manuscript.json`; the build will otherwise stop with a clear
fingerprint mismatch. To update a report snapshot, copy its PDF into `dist/`
and update the corresponding report hash after checking the relationship.

## Enable GitHub Pages

In the repository's **Settings → Pages → Build and deployment**, choose
**GitHub Actions** as the source. Then run **Publish reading guide** from the
Actions tab if an earlier attempt occurred before Pages was enabled.

The workflow uses the repository's automatic `GITHUB_TOKEN`, with
`contents: read`, `pages: write`, and `id-token: write` for deployment.
It needs no personal access token or custom secret. The `github-pages`
environment provides GitHub's standard deployment controls.

## Corrections

Open an issue or pull request with the reading step's link (including its
`#proof-...` fragment), the disputed calculation, and the proposed correction.
These stable step links make discussions easy to locate.
