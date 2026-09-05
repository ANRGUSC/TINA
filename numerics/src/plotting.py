"""Shared publication plotting style."""
from __future__ import annotations

from pathlib import Path
import shutil
import matplotlib as mpl
import matplotlib.pyplot as plt


COLORS = ["#0072B2", "#D55E00", "#009E73", "#CC79A7", "#E69F00", "#56B4E9"]


def configure():
    mpl.rcParams.update({
        "font.family": "serif",
        "font.size": 8.5,
        "axes.labelsize": 8.5,
        "legend.fontsize": 7.2,
        "xtick.labelsize": 7.5,
        "ytick.labelsize": 7.5,
        "lines.linewidth": 1.5,
        "figure.dpi": 130,
        "savefig.bbox": "tight",
        "pdf.fonttype": 42,
        "ps.fonttype": 42,
    })


def save(fig, root, stem, paper_figures=None):
    root = Path(root)
    (root / "figures" / "pdf").mkdir(parents=True, exist_ok=True)
    (root / "figures" / "png").mkdir(parents=True, exist_ok=True)
    pdf_path = root / "figures" / "pdf" / f"{stem}.pdf"
    fig.savefig(pdf_path)
    fig.savefig(root / "figures" / "png" / f"{stem}.png", dpi=350)
    if paper_figures is not None:
        paper_figures = Path(paper_figures)
        paper_figures.mkdir(parents=True, exist_ok=True)
        # Constrained layout can move axes on successive saves.  Copy the
        # archived PDF so the manuscript uses that exact artifact.
        shutil.copy2(pdf_path, paper_figures / f"{stem}.pdf")
    plt.close(fig)
