"""
Requires a neoplasmer service to run

See README.md
"""
import sys
from pengines.Builder import PengineBuilder
from pengines.Pengine import Pengine
from prologterms import TermGenerator, PrologRenderer, Program, Var
    
P = TermGenerator()
MatchID = Var('MatchID')
Score = Var('Score')
Prefix = Var('Prefix')
R = PrologRenderer()

#terms = ['neoplasm', 'glioma', 'astrocytoma']
terms = sys.argv[1:]

for t in terms:
    q = P.term_best_match(t, MatchID, Score, Prefix)
    
    factory = PengineBuilder(urlserver="http://localhost:9055",
                             ask=R.render(q))
    pengine = Pengine(builder=factory, debug=False)
    while pengine.currentQuery.hasMore:
        pengine.doNext(pengine.currentQuery)
    for p in pengine.currentQuery.availProofs:
        print('Term: {} Match: {}  {}'.format(t, p[MatchID.name], p[Score.name]))
