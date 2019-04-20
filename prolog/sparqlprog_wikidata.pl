/** <module> predicates for querying wikidata using logic predicates

  
*/

% Note: this module uses macros to generate predicates. For every pname_wid/3 and cname_wid/3, predicates will be generated 

:- module(sparqlprog_wikidata,
          [

           property_constraint_pv/4,
           
           var_drug_condition/4,
           
           enlabel/2,
           enlabelp/2,
           enlabel_any/2,
           exact_match/2

           ]).

:- use_module(library(sparqlprog)).
:- use_module(library(semweb/rdf11)).

:- sparql_endpoint( wd, 'http://query.wikidata.org/sparql').

:- rdf_register_prefix(foaf,'http://xmlns.com/foaf/0.1/').
:- rdf_register_prefix(dbont,'http://dbpedia.org/ontology/').
%:- rdf_register_prefix(dcterms,'http://purl.org/dc/terms').
:- rdf_register_prefix(wikipathways,'http://vocabularies.wikipathways.org/wp#').
:- rdf_register_prefix(obo,'http://purl.obolibrary.org/obo/').
:- rdf_register_prefix(so,'http://purl.obolibrary.org/obo/SO_').

% https://www.mediawiki.org/wiki/Wikibase/Indexing/RDF_Dump_Format#Prefixes_used
:- rdf_register_prefix(wd,'http://www.wikidata.org/entity/').
:- rdf_register_prefix(wdt,'http://www.wikidata.org/prop/direct/').
:- rdf_register_prefix(wbont,'http://wikiba.se/ontology#').

:- rdf_register_prefix(instance_of,'http://www.wikidata.org/prop/direct/P31').

:- dynamic pred_info/3.

user:term_expansion(pname_wid(Module,P,Id),
                    [(   Head :- Body),
                     (   Head_trans :- Body_trans),
                     (   Head_s :- Body_s),
                     (   Head_ps :- Body_ps),
                     (   Head_q :- Body_q),
                     (   Head_iri :- true),
                     (   Head_eiri :- true),
                     (   :- initialization(export(P_trans/2), now)),
                     (   :- initialization(export(P_s/2), now)),
                     (   :- initialization(export(P_ps/2), now)),
                     (   :- initialization(export(P_q/2), now)),
                     (   :- initialization(export(P_iri/1), now)),
                     (   :- initialization(export(P_eiri/1), now)),
                     (   :- initialization(export(P/2), now))
                    ]) :-

        % e.g. p9 ==> P9
        upcase_atom(Id,Frag),
        
        
        % Truthy assertions about the data, links entity to value directly
        % wd:Q2  wdt:P9 <http://acme.com/> ==> P9(Q2,"...")
        Head =.. [P,S,O],
        atom_concat('http://www.wikidata.org/prop/direct/',Frag,Px),
        Body = rdf(S,Px,O),
        assert(pred_info(P/2,Module,Px,'asserted triple')),

        atom_concat(P,'_transitive',P_trans),
        Head_trans =.. [P_trans,S,O],
        Body_trans = rdf_path(S,zeroOrMore(Px),O),
        assert(pred_info(P/2,Module,triple)),
        assert(pred_info(P/2,Module,Px,'inferred triple')),
        
        
        % p: Links entity to statement
        % wd:Q2 p:P9 wds:Q2-82a6e009 ==> P9_statement(Q2,wds:....)
        atom_concat(P,'_e2s',P_s),
        Head_s =.. [P_s,S,O],
        atom_concat('http://www.wikidata.org/prop/',Frag,Px_s),
        Body_s = rdf(S,Px_s,O),

        atom_concat(P,'_iri',P_iri),
        Head_iri =.. [P_iri,Px],

        atom_concat('http://www.wikidata.org/entity/',Frag,Pe),        
        atom_concat(P,'_eiri',P_eiri),
        Head_eiri =.. [P_eiri,Pe],
        
        % ps: Links value from statement
        % wds:Q3-24bf3704-4c5d-083a-9b59-1881f82b6b37 ps:P8 "-13000000000-01-01T00:00:00Z"^^xsd:dateTime
        atom_concat(P,'_s2v',P_ps),
        Head_ps =.. [P_ps,S,O],
        atom_concat('http://www.wikidata.org/prop/statement/',Frag,Px_ps),
        Body_ps = rdf(S,Px_ps,O),
        
        % pq: Links qualifier from statement node
        % wds:Q3-24bf3704-4c5d-083a-9b59-1881f82b6b37 pq:P8 "-13000000000-01-01T00:00:00Z"^^xsd:dateTime
        % => P8_q(wds:..., "..."^^...)
        atom_concat(P,'_s2q',P_q),
        Head_q =.. [P_q,S,O],
        atom_concat('http://www.wikidata.org/prop/qualifier/',Frag,Px_q),
        Body_q = rdf(S,Px_q,O).


user:term_expansion(cname_wid(Module,C,Id),
                    [Rule,
                     %RuleInf,
                     RuleDirect,
                     RuleIsa,
                     (   Head_iri :- true),
                     (:- initialization(export(C_direct/1), now)),
                     %(:- initialization(export(InfC/1), now)),
                     (:- initialization(export(SubC/1), now)),
                     (:- initialization(export(C_iri/1), now)),
                     (:- initialization(export(C/1), now))
                     ]) :-
        upcase_atom(Id,Frag),
        atom_concat('http://www.wikidata.org/entity/',Frag,Cx),
        
        Head =.. [C,I],
        Body = rdf(I,('http://www.wikidata.org/prop/direct/P31'/zeroOrMore('http://www.wikidata.org/prop/direct/P279')),Cx),
        Rule = (Head :- Body),
        assert(pred_info(C/1, Module, instance)),

        atom_concat(C,'_direct',C_direct),
        HeadD =.. [C_direct,I],
        BodyD = rdf(I,'http://www.wikidata.org/prop/direct/P31',Cx),
        RuleDirect = (HeadD :- BodyD),

        atom_concat(C,'_iri',C_iri),
        Head_iri =.. [C_iri,Cx],
        
        %atom_concat(C,'_inf',InfC),
        %Head2 =.. [InfC,I],
        %Body2 = rdf(I,('http://www.wikidata.org/prop/direct/P31'/zeroOrMore('http://www.wikidata.org/prop/direct/P279')),Cx),
        %RuleInf = (Head2 :- Body2),
        
        atom_concat('isa_',C,SubC),
        Head3 =.. [SubC,I],
        Body3 = rdf(I,zeroOrMore('http://www.wikidata.org/prop/direct/P279'),Cx),
        RuleIsa = (Head3 :- Body3).


enlabel(E,N) :- label(E,N),lang(N)="en".
enlabelp(E,N) :- rdf(X,wbont:directClaim,E),enlabel(X,N).
enlabel_any(E,N) :- enlabel(E,N).
enlabel_any(E,N) :- enlabelp(E,N).



% --------------------
% classes
% --------------------

% geography


% --------------------
% predicates
% --------------------

% PROPS

% meta
pname_wid(meta,instance_of, p31).
pname_wid(meta,subclass_of, p279).
pname_wid(meta,subproperty_of, p1647).
pname_wid(meta,equivalent_property, p1628).
pname_wid(meta,property_constraint, p2302).
pname_wid(meta,properties_for_this_type, p1963).

property_constraint_pv(P,C,PP,V) :-
        property_constraint_e2s(P,S),
        rdf(S,PP,V),
        property_constraint_s2v(S,C).

% general
pname_wid(meta,author, p50).
pname_wid(meta,exact_match, p2888).

% geo
pname_wid(geo,coordinate_location, p625).

% bio

% IDs
pname_wid(bio,hp_id, p3841).
pname_wid(bio,envo_id, p3859).
pname_wid(bio,doid_id, p699).
pname_wid(bio,chebi_id, p683).
pname_wid(bio,uniprot_id, p352).
pname_wid(bio,ncbigene_id, p351).
pname_wid(bio,ipr_id, p2926).
pname_wid(bio,civic_id, p3329).
pname_wid(bio,ro_id, p3590).
pname_wid(bio,mesh_id, p486).
pname_wid(bio,go_id, p686).
pname_wid(bio,ncbitaxon_id, p685).
pname_wid(bio,uberon_id, p1554).
pname_wid(bio,umls_id, p2892).
pname_wid(bio,drugbank_id, p715).

% bio rels
pname_wid(bio,encodes, p688).
pname_wid(bio,genetic_association, p2293).
pname_wid(bio,treated_by_drug, p2176).
pname_wid(bio,symptoms, p780).
pname_wid(bio,pathogen_transmission_process, p1060).
pname_wid(bio,has_cause, p828).
pname_wid(bio,biological_variant_of, p3433).
pname_wid(bio,has_part, p527).

% https://www.wikidata.org/wiki/Wikidata:SPARQL_query_service/queries/examples#Get_known_variants_reported_in_CIViC_database_(Q27612411)_of_genes_reported_in_a_Wikipathways_pathway:_Bladder_Cancer_(Q30230812)
pname_wid(bio,positive_therapeutic_predictor, p3354).
pname_wid(bio,negative_therapeutic_predictor, p3355).
pname_wid(bio,positive_diagnostic_predictor, p3356).
pname_wid(bio,negative_diagnostic_predictor, p3357).
pname_wid(bio,positive_prognostic_predictor, p3358).
pname_wid(bio,negative_prognostic_predictor, p3359).
pname_wid(bio,medical_condition_treated, p2175).

% beacon
pname_wid(bio,physically_interacts_with, p129).
pname_wid(bio,location, p276).
pname_wid(bio,manifestation_of, p1557).
pname_wid(bio,part_of, p361).
pname_wid(bio,followed_by, p156).
pname_wid(bio,product_or_material_produced, p1056).
pname_wid(bio,uses, p2283).
pname_wid(bio,has_effect, p1542).
pname_wid(bio,drug_used_for_treatment, p2176).
pname_wid(bio,found_in_taxon, p703).
pname_wid(bio,ortholog, p684).
pname_wid(bio,biological_process, p682).
pname_wid(bio,cell_component, p681).
pname_wid(bio,molecular_function, p680).
pname_wid(bio,has_quality, p1552).
pname_wid(bio,regulates, p128).


    
% CLASSES

% geo
cname_wid(geo,geographic_entity, q27096213).
cname_wid(geo,continent, q5107).
cname_wid(geo,country, q6256).
cname_wid(geo,city, q515).
pname_wid(geo,population, p1082).
pname_wid(geo,part_of_continent, p30).

% chem
cname_wid(chem,chemical_property, q21294996).
pname_wid(chem,median_lethal_dose, p2240).


% bio
cname_wid(bio,bioproperty, q22988603).

cname_wid(bio,cancer, q12078).
cname_wid(bio,disease, q12136).
cname_wid(bio,infectious_disease, q18123741).

cname_wid(bio,chemical_compound, q11173).
cname_wid(bio,chemical_element, q11344).
cname_wid(bio,drug, q12140).

cname_wid(bio,symptom, q169872).
cname_wid(bio,medical_finding, q639907).
cname_wid(bio,trait, q1211967).
cname_wid(bio,pathway, q4915012).
cname_wid(bio,macromolecular_complex, qQ22325163).
cname_wid(bio,gene, qQ7187).
cname_wid(bio,gene_product, qQ424689).
cname_wid(bio,sequence_variant, qQ15304597).

cname_wid(bio,therapy, q179661).
cname_wid(bio,medical_procedure, qQ796194).


% random
cname_wid(geo,power_station, q159719).

% TODO
%nary(ptp_var_drug_condition, positive_therapeutic_predictor, medical_condition_treated).



var_drug_condition(V,D,C,positive_therapeutic_predictor) :-
        positive_therapeutic_predictor_e2s(V,S),
        medical_condition_treated_s2q(S,C),
        positive_therapeutic_predictor_s2v(S,D).



