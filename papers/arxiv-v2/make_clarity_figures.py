"""Generate the two explanatory vector figures requested in clarifyTINA2.md."""
from pathlib import Path
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

OUT=Path(__file__).resolve().parent/'figures'
plt.rcParams.update({'font.family':'serif','font.size':11,'pdf.fonttype':42})
fig,ax=plt.subplots(figsize=(8.2,2.15))
ax.set(xlim=(0,10),ylim=(-1.25,1.05))
ax.axis('off')
ax.annotate('',xy=(9.8,.35),xytext=(.25,.35),arrowprops={'arrowstyle':'->','lw':1.25})
ax.text(.15,.6,'time',ha='left')
for x,t,lines in [
 (1.7,r'$t-\tau(r_2)$','Snapshot of $\\mathcal{N}_{r_2}(i)$\nWider, older'),
 (5.,r'$t-\tau(r_1)$','Snapshot of $\\mathcal{N}_{r_1}(i)$\nNarrower, fresher'),
 (8.5,r'$t$','Agent $i$ acts: $x_{i,t}$\nCost depends on $\\theta_t$')]:
 ax.plot([x,x],[.22,.47],color='black',lw=1.25)
 ax.text(x,.65,t,ha='center')
 ax.text(x,-.2,lines,ha='center',va='top',linespacing=1.5)
fig.tight_layout(pad=.25)
fig.savefig(OUT/'snapshot_timing.pdf',bbox_inches='tight')
plt.close(fig)

radius=np.linspace(0,1.3,500)
eta=.5*np.exp(-2*radius) # ell_c=1, ell_s=.5
gain=2*eta/(1-eta)
fig,ax=plt.subplots(figsize=(7.5,3.7))
ax.plot(radius,gain,color='#173f67',lw=2,label=r'$m_S(r)$')
for length,color,style in [(2,'#986327','--'),(4,'#a33938','-'),(8,'#437c63',':')]:
 rate=2/length
 optimum=.5*np.log((1+length)/2)
 ax.axhline(rate,color=color,ls=style,lw=1.4)
 ax.plot(optimum,rate,'o',color=color,ms=5)
 ax.plot([optimum,optimum],[0,rate],color=color,ls=':',lw=.9)
 ax.text(1.31,rate,rf'$L_T={length}$',ha='left',va='center',color=color)
 ax.text(optimum,-.09,rf'${optimum:.2f}$',ha='center',va='top',fontsize=9,color=color)
middle=.5*np.log(2.5)
ax.annotate(r'$r^\star$',xy=(middle,.5),xytext=(middle+.18,.85),arrowprops={'arrowstyle':'->'},fontsize=12)
ax.text(.06,1.55,'Expand radius\n'+r'($m_S>m_T$, $L_T=4$)',fontsize=10)
ax.text(.74,1.45,'Shrink radius\n'+r'($m_S<m_T$, $L_T=4$)',fontsize=10)
ax.set(xlim=(0,1.3),ylim=(0,2.1),xlabel=r'Radius $r/\ell_c$',ylabel='Marginal rate (inverse length)')
ax.legend(loc='upper right',frameon=False)
ax.spines[['top','right']].set_visible(False)
ax.grid(alpha=.15)
fig.subplots_adjust(left=.12,right=.84,bottom=.21,top=.96)
fig.savefig(OUT/'marginal_balance.pdf',bbox_inches='tight')
plt.close(fig)
print('Created snapshot_timing.pdf and marginal_balance.pdf')
