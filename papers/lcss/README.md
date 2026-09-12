# Too Late to Coordinate: When Local Information Beats Global Sharing

## Supplementary proof review

The [Lamport review](../../proof-reports/lcss-letter/README.md) includes the
[44-page report PDF](../../proof-reports/lcss-letter/TINA_Paper1_Lamport_Report.pdf),
[standalone LaTeX source](../../proof-reports/lcss-letter/TINA_Paper1_Lamport_Report.tex),
audit records, and the exact reviewed manuscript with recorded hashes.
The current submission differs from that snapshot only by three 7-point
vertical-spacing adjustments for table and figure margins. Mathematical content
is unchanged. The review is model-assisted, not a proof-assistant certificate.

## Manuscript files

- `main.tex`: complete manuscript, including all proofs and bibliography.
- `main.pdf`: six-page compiled manuscript.
- `ieeeconf.cls`: unmodified conference class downloaded from PaperPlaza.
- `figures/`: two figures in PDF, SVG, and PNG formats. The manuscript uses the vector PDFs.
- `generate_figures.py`: figure generation and independent Gaussian-team calculations.
- `verification.json`: parameters, Monte Carlo estimates, optimization checks, and refresh calculations.
- `requirements.txt`: Python package versions used to generate the figures.

## Compile

Keep this directory structure and run:

```bash
pdflatex -interaction=nonstopmode -halt-on-error main.tex
pdflatex -interaction=nonstopmode -halt-on-error main.tex
```

A standard TeX Live or MiKTeX installation supplies the mathematics, graphics, citation, and hyperlink packages. The bibliography is included directly in `main.tex`; BibTeX is not needed.

## Reproduce the figures

```bash
python -m pip install -r requirements.txt
python generate_figures.py
```

The script uses a fixed seed and 120,000 independent stationary Gaussian sample pairs per Monte Carlo point. It solves 83 Gaussian-team systems directly from observation covariances for the local and hybrid architectures. The maximum expected-cost discrepancy is below 2.7e-15. These calculations check the scalar policies independently of the displayed formulas. Figure 1 also shows the exact delay at which fresh-local operation outperforms delayed-pool-only operation, with Monte Carlo checks of the latter's loss. The unequal-sensor and full-history results are established by the proofs in the manuscript. The experiments are synthetic evaluations of the stated model.

## Scope of the draft

The letter studies a common latent signal, independent temporally correlated sensor disturbances, and a team objective that prices tracking error and disagreement. Its exact hybrid law requires the signal and disturbances within each component to share a temporal decay rate. It covers unequal sensor disturbance variances, and independent components with different rates. The refresh theorem covers schedules independent of the observations, fixed communication latency, and a cost for each complete pooled refresh. Each pooled scalar is modeled as an exact real number.

A retained local measurement from the pooling time is part of the optimal implementation. During pipelined transmission, timestamped local measurements must remain available until their associated summary arrives.

The letter identifies two conditions for choosing local operation. Fresh-local decisions have lower team loss than decisions based only on a delayed pool when its age exceeds the crossover threshold. With fresh local observations retained, pooled information has positive decision value at every finite age. In this hybrid architecture, the communication price and latency determine whether refreshing improves the total average cost. The introduction groups the results into four contributions. Theorem 1 checks the team optimality equations directly under the full local observation path. The common-rate Gaussian covariance factorization also gives the discrete-time pooling law for stationary AR(1) processes; the refresh integrals require sums in discrete time.

The public project repository is https://github.com/ANRGUSC/TINA. It includes simulation code and extended analysis. Lamport-style proof-review reports identify theorem assumptions, logical dependencies, and unresolved obligations. Such reports are mathematical reviews, not proof-assistant certificates.

The letter builds on TINA (arXiv:2609.06351v1), which provides the general information-architecture framework, fresh-local versus delayed-global crossover, spatial predictability, and neighborhood-radius theory. The letter specializes the crossover to a common-signal Gaussian sensor team and derives explicit policies, posterior variances, and costs. It develops additional results on exact hybrid value, a scalar summary achieving complete delayed sharing, unequal sensor quality, independent components with different temporal rates, and optimal refresh scheduling. These additional results are not contained in the cited arXiv v1. All proofs needed to assess the letter are included within its six pages.

## Submission keywords

Recommended order, using exact entries from the supplied list:

1. Decentralized control: the Gaussian team and differing information sets.
2. Sensor fusion: the pooled posterior and summary sufficiency results.
3. Control system architecture: selection of information and refresh frequency.

If the form permits more terms, Estimation and Event-triggered/resource-aware control are suitable additional choices. The latter matches the resource-aware refresh problem.

## Author information

The manuscript uses the required US Letter, 10-point, two-column `ieeeconf` format. It includes a sub-200-word abstract, references within the six-page limit, a prior-work citation, and AI-use acknowledgment. The author names, order, affiliations, and emails follow the supplied source; Bhaskar Krishnamachari is designated as corresponding author.

The authors still need to supply the complete mailing addresses and telephone numbers requested by the author instructions, confirm the correspondence details, and register or link each author's ORCID in PaperPlaza. Any funding acknowledgment must come from the authors. The final scientific and publication review remains with the authors.

Author instructions: https://ieeecss.org/publication/ieee-control-systems-letters/author-information

ACC 2027 dates: https://acc2027.a2c2.org/

The ACC site lists September 11, 2026 for joint L-CSS/ACC submission and September 25, 2026 for regular ACC submission. Joint submission is made through L-CSS with the ACC option.
