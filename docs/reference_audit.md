# Reference audit record

The bibliography is maintained in `references.bib` and compiled with
`IEEEtran.bst`. The submission audit applies these checks:

- every active `\cite{...}` key exists exactly once;
- every bibliography database named by the manuscript exists locally;
- protected capitalization is used for proper names and abbreviations that
  BibTeX would otherwise lowercase (including Gaussian, Gaussian Markov, AoI,
  LEGT, OU, and part II);
- author order, title, venue, year, volume/issue, and pages are checked against a
  DOI landing page when a DOI is available, otherwise against the publisher or
  proceedings record;
- preprints and forthcoming papers are identified as such rather than assigned
  unsupported final publication metadata; and
- the software citation resolves to the immutable tagged repository release.

`python scripts/audit_sources.py` automates the local key/closure portion and
the clean BibTeX build checks syntax. The remaining publication-metadata review
is a human-readable source audit; no claim in the manuscript depends on a title
inference from an unverified web search. The release URL is checked during
publication; the signed repository tag is the immutable identifier for the
audited source closure.

Release target: `https://github.com/ANRGUSC/TINA/releases/tag/v1.0.0-submission`.
