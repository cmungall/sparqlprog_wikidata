[![DOI](https://zenodo.org/badge/13996//sparqlprog_wikidata.svg)](https://zenodo.org/badge/latestdoi/13996//sparqlprog_wikidata)

# Query wikidata using logic predicates

This is a module for
[sparqlprog](https://github.com/cmungall/sparqlprog) that provides
convenience predicates for making sparql queries over wikidata using
logic programming terms. It allows you to define reusable query
predicates, and to integrate programming constructs with queries in a
declarative way.

## Examples (command line):

All cities over a certain population size together with their continents:

```
pq-wikidata -C -l -L enlabel "city(City),part_of_continent(City,Continent),population(City,Pop),Pop>10000000"
```

yields:

|City|Continent|Population|City Name|Continent Name||
|---|---|---|---|---|---|
|wd:Q174|wd:Q18|12106920|São Paulo|South America|$null$
|wd:Q649|wd:Q46|12500123|Moscow|Europe|$null$
|wd:Q1355|wd:Q48|10535000|Bangalore|Asia|$null$
|wd:Q1156|wd:Q48|12442373|Mumbai|Asia|$null$
|wd:Q406|wd:Q48|14657434|Istanbul|Asia|$null$
|wd:Q406|wd:Q46|14657434|Istanbul|Europe|$null$
|wd:Q85|wd:Q15|19500000|Cairo|Africa|$null$
|wd:Q15174|wd:Q48|11908400|Shenzhen|Asia|$null$
|wd:Q956|wd:Q48|21710000|Beijing|Asia|$null$
|wd:Q1353|wd:Q48|26495000|Delhi|Asia|$null$


Create a file `city_ontology.pro` with a single line:

```
big_city(City) :- city(City),population(City,Pop),Pop>10000000.
```

Now the `big_city/1` predicate can be reused in queries:

```
pq-wikidata -c city_ontology.pro -C -l -L enlabel "big_city(City),part_of_continent(City,Continent)"
```

yields:

|city|continent|city label|continent label|
|---|---|---|---|
|wd:Q956|wd:Q48|Beijing|Asia|
|wd:Q15174|wd:Q48|Shenzhen|Asia|
|wd:Q1353|wd:Q48|Delhi|Asia|
|wd:Q649|wd:Q46|Moscow|Europe|
|wd:Q406|wd:Q48|Istanbul|Asia|
|wd:Q406|wd:Q46|Istanbul|Europe|
|wd:Q1156|wd:Q48|Mumbai|Asia|
|wd:Q85|wd:Q15|Cairo|Africa|
|wd:Q1355|wd:Q48|Bangalore|Asia|
|wd:Q174|wd:Q18|São Paulo|South America|


## Installation

### Docker

To run queries on the command line:

`alias pq-wikidata="docker run cmungall/sparqlprog_wikidata pq-wikidata`

To run a service:

`docker run -p 9083:9083 cmungall/sparqlprog_wikidata`



### Within SWI Environment

Install SWI-Prolog from http://www.swi-prolog.org

    pack_install(sparqlprog_wikidata)

## How it works

For each class in the defined subset, for example [Country](http://www.wikidata.org/entity/Q551), multiple predicates will be defined:

 * `city/1` - any instance of City, or its subclasses
 * `city_direct/1` - any instance of City (ignoring subclasses)
 * `city_iri/1` - IRI for City in WikiData

For example, the query

`city(City)`

will be expanded to:

```
SELECT ?city WHERE {
  ?city (<http://www.wikidata.org/prop/direct/P31>/<http://www.wikidata.org/prop/direct/P279>*) <http://www.wikidata.org/entity/Q515>
}
```

For each predicate in the defined subset, for example, [regulates (molecular biology)](http://www.wikidata.org/prop/direct/P128), the following predicates will be defined:

 * `regulates/2` - direct assertion between regulator and regulated
 * `regulates_transitive/`2 - transitive version of above
 * `regulates_iri/1` - IRI for regulates

Further predicates will be defined that utilize the wikidata reification model. 

 * `<predicate>_eiri/1` - Entity IRI for predicate
 * `<predicate>_e2s` - links entity to statement
 * `<predicate>_s2v` - links value from statement
 * `<predicate>_s2q` - links qualifier statement

To illustrate consider the definition of the following 3-ary predicate, based on the [positive therapeutic predictor](http://www.wikidata.org/prop/direct/P3354) predicate in wikidata. These triples can be qualified by [medical condition treated](http://www.wikidata.org/prop/direct/P2175).

```
positive_therapeutic_predictor_for_condition(V,D,C) :-
        positive_therapeutic_predictor_e2s(V,S),
        medical_condition_treated_s2q(S,C),
        positive_therapeutic_predictor_s2v(S,D).
```


The following query:

```
pq-wikidata -C "positive_therapeutic_predictor_for_condition(Var,Drug,Condition)"
```

will be translated to:

```
SELECT ?var ?drug ?condition WHERE {
  ?var <http://www.wikidata.org/prop/P3354> ?v0 .
  ?v0 <http://www.wikidata.org/prop/qualifier/P2175> ?condition .
  ?v0 <http://www.wikidata.org/prop/statement/P3354> ?drug
}
```

## Other Queries

Location of San Francisco:

```
$ pq-wikidata -l -L enlabel  "geolocation(wd:'Q62',Lat,Long,Precision,Globe)"
37.766667,-122.433333,1.0E-6,wd:Q2,$null$,$null$,$null$,Earth
```

