[![DOI](https://zenodo.org/badge/13996//sparqlprog_wikidata.svg)](https://zenodo.org/badge/latestdoi/13996//sparqlprog_wikidata)

# Query wikidata using logic predicates

This is a module for
[sparqlprog](https://github.com/cmungall/sparqlprog) that provides
convenience predicates for making queries over the [wikidata sparql endpoint](https://query.wikidata.org/) using
logic programming terms. It allows you to define reusable query
predicates, and to integrate programming constructs with queries in a
declarative way.

It can be used via the command line, via [Python](https://github.com/cmungall/sparqlprog-python), or within prolog programs.

## Examples (command line):

All cities over a certain population size together with their continents:

```
pq-wikidata -l -L enlabel "city(City),part_of_continent(City,Continent),population(City,Pop),Pop>10000000"
```

yields:

|City|Continent|Population|City Name|Continent Name|Pop Name|
|---|---|---|---|---|---|
|wd:Q174|wd:Q18|12106920|São Paulo|South America|$null$|
|wd:Q649|wd:Q46|12500123|Moscow|Europe|$null$|
|wd:Q1355|wd:Q48|10535000|Bangalore|Asia|$null$|
|wd:Q1156|wd:Q48|12442373|Mumbai|Asia|$null$|
|wd:Q406|wd:Q48|14657434|Istanbul|Asia|$null$|
|wd:Q406|wd:Q46|14657434|Istanbul|Europe|$null$|
|wd:Q85|wd:Q15|19500000|Cairo|Africa|$null$|
|wd:Q15174|wd:Q48|11908400|Shenzhen|Asia|$null$|
|wd:Q956|wd:Q48|21710000|Beijing|Asia|$null$|
|wd:Q1353|wd:Q48|26495000|Delhi|Asia|$null$|

The `-l` argument auto-adds labels for every column (this is meaningless for the population column but this is included for consistency)

The unary predicate `city/1` is mapped to [Q515](http://www.wikidata.org/entity/Q515), and `part_of_continent` to [P30](http://www.wikidata.org/prop/direct/P30).

We can also define our own predicates. Create a file `city_ontology.pro` with a single line:

```
big_city(City) :- city(City),population(City,Pop),Pop>10000000.
```

Now the `big_city/1` predicate can be reused in queries:

```
pq-wikidata --consult city_ontology.pro -l -L enlabel "big_city(City),part_of_continent(City,Continent)"
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

Qualified properties may be represented by n-ary predicates, such as `population_at/3`: 

```
$ pq-wikidata -f tsv --consult tests/city_ontology.pro -l -L enlabel 'big_city(City),population_at(City,Pop,At),in_time_interval("2010-01-01"^^xsd:dateTime,"2013-01-01"^^xsd:dateTime,At)' | tbl2ghwiki 
```

|City|Pop|Time|City Name|---|---|
|---|---|---|---|---|---|
|wd:Q1353|16787941|2011-01-01T00:00:00Z|Delhi|$null$|$null$|
|wd:Q406|13624240|2011-01-01T00:00:00Z|Istanbul|$null$|$null$|
|wd:Q649|11856578|2012-01-01T00:00:00Z|Moscow|$null$|$null$|
|wd:Q3630|9607787|2010-01-01T00:00:00Z|Jakarta|$null$|$null$|
|wd:Q404763|12010000|2011-01-01T00:00:00Z|Nanyang|$null$|$null$|
|wd:Q649|11979529|2013-01-01T00:00:00Z|Moscow|$null$|$null$|
|wd:Q649|11503501|2010-01-01T00:00:00Z|Moscow|$null$|$null$|
|wd:Q11746|10220000|2013-01-01T00:00:00Z|Wuhan|$null$|$null$|
|wd:Q406|14160467|2013-01-01T00:00:00Z|Istanbul|$null$|$null$|
|wd:Q649|11776764|2011-01-01T00:00:00Z|Moscow|$null$|$null$|
|wd:Q42622|10465994|2010-01-01T00:00:00Z|Suzhou|$null$|$null$|
|wd:Q174|11316149|2011-01-01T00:00:00Z|São Paulo|$null$|$null$|
|wd:Q406|13255685|2010-01-01T00:00:00Z|Istanbul|$null$|$null$|
|wd:Q406|13854740|2012-01-01T00:00:00Z|Istanbul|$null$|$null$|
|wd:Q1355|8425970|2011-01-01T00:00:00Z|Bangalore|$null$|$null$|
|wd:Q174|11253503|2010-01-01T00:00:00Z|São Paulo|$null$|$null$|
|wd:Q1490|13159388|2010-01-01T00:00:00Z|Tokyo|$null$|$null$|
|wd:Q15174|10628900|2013-01-01T00:00:00Z|Shenzhen|$null$|$null$|
|wd:Q3838|9464000|2012-01-01T00:00:00Z|Kinshasa|$null$|$null$|
|wd:Q373346|10820000|2011-01-01T00:00:00Z|Linyi|$null$|$null$|
|wd:Q1352|4646732|2011-01-01T00:00:00Z|Chennai|$null$|$null$|
|wd:Q11739|7129629|2010-01-01T00:00:00Z|Lahore|$null$|$null$|
|wd:Q1156|12442373|2011-01-01T00:00:00Z|Mumbai|$null$|$null$|


Location queries:

Find all forests around San Francisco in a 100 mile radius
```
$ pq-wikidata -l -L enlabel  -f tsv "coordinate_location(wd:'Q62',Loc),geolocation_around(Loc,100,X),forest(X)"
```

The [entity_search/2](https://www.swi-prolog.org/pack/file_details/sparqlprog_wikidata/prolog/sparqlprog_wikidata.pl#entity_search/2) predicate provides access to the Wikibase EntitySearch function. The following example finds all subclasses of a symptom by name:

```
$ pq-wikidata -l -L enlabel "entity_search(vomiting,Match),subclass_of_transitive(Symptom,Match)"
```

|Match|Symptom|Match Label|Symptom Label|
|---|---|---|---|
|wd:Q127076|wd:Q127076|vomiting|vomiting|
|wd:Q127076|wd:Q2635499|vomiting|Projectile vomiting|
|wd:Q127076|wd:Q21993813|vomiting|chronic vomiting|
|wd:Q127076|wd:Q23012213|vomiting|glowing vomit|
|wd:Q127076|wd:Q5140942|vomiting|coffee ground vomiting|
|wd:Q127076|wd:Q54974197|vomiting|anticipatory vomiting|
|...|...|...|...|


Note that affixing `_transitive` to a predicate will always translate to the reflexive transitive version of that predicate (equivalent to affixing a `*` in SPARQL). Here we find all known causes of different kinds of vomiting in Wikidata, using the reflexive transitive closure of the wikidata `subClassOf` predicate.


```
$ pq-wikidata -l -L enlabel "subclass_of_transitive(S,wd:'Q127076'),has_cause(S,C)" 
```


|S|C|S Label|C Label|
|---|---|---|---|
|wd:Q1570161|wd:Q1495657|hematemesis|gastrointestinal bleeding|
|wd:Q1938763|wd:Q16244733|fecal vomiting|intestinal obstruction|
|wd:Q5140942|wd:Q1883970|coffee ground vomiting|upper gastrointestinal bleeding|
|wd:Q127076|wd:Q133823|vomiting|migraine|
|wd:Q127076|wd:Q121041|vomiting|appendicitis|
|wd:Q127076|wd:Q164778|vomiting|rotavirus|
|wd:Q127076|wd:Q943897|vomiting|gastroparesis|
|wd:Q127076|wd:Q974135|vomiting|chemotherapy|

## Installation

### Docker

To run queries on the command line:

```
alias pq-wikidata="docker run cmungall/sparqlprog_wikidata pq-wikidata
```

To run a service:

```
docker run -p 9083:9083 cmungall/sparqlprog_wikidata
```

There is currently a [Python library](https://pypi.org/project/sparqlprog/) for connecting to a sparqlprog service.

You can find examples of Jupyter notebooks such as [this
one](https://nbviewer.jupyter.org/github/cmungall/sparqlprog-python/blob/master/Notebook_02_Programs.ipynb)
(which uses the dbpedia endpoint, but can easily be adapted)


### Within SWI Environment

Install SWI-Prolog from http://www.swi-prolog.org

    pack_install(sparqlprog_wikidata)

## How it works

For each class in the defined subset, for example [City](http://www.wikidata.org/entity/Q515), multiple predicates will be defined:

 * `city/1` - any instance of City, or its subclasses
 * `city_direct/1` - any instance of City (no inference - ignores subclasses)
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
 * `regulates_transitive/2` - transitive version of above
 * `regulates_iri/1` - IRI for regulates

Further predicates will be defined that utilize the wikidata reification model. 

 * `$predicate_eiri/1` - Entity IRI for predicate
 * `$predicate_e2s` - links entity to statement
 * `$predicate_s2v` - links value from statement
 * `$predicate_s2q` - links qualifier statement

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

(use `-C` to generate the SPARQL without executing it)

## Other Queries

Location of San Francisco:

```
$ pq-wikidata -l -L enlabel  "geolocation(wd:'Q62',Lat,Long,Precision,Globe)"
37.766667,-122.433333,1.0E-6,wd:Q2,$null$,$null$,$null$,Earth
```

## Supported subsets of Wikidata

Currently on a small subset of the overall Wikidata schema is exposed,
mostly a subset focused around life science and geoscience/geographic
use cases. More can be added on request. It is also very to easy for
you to do this locally, and pull requests are welcome. Just edit the file [sparqlprog_wikidata.pl](https://www.swi-prolog.org/pack/file_details/sparqlprog_wikidata/prolog/sparqlprog_wikidata.pl)

In future we may translate the entire Wikidata model (i.e. all classes
and properties) into sparqlprog predicates.

## More examples

See [bin/wikidata-examples.sh](bin/wikidata-examples.sh)


## TODO

Document API calls, search, etc

## Uses

See: [environments2wikidata](https://github.com/cmungall/environments2wikidata)
