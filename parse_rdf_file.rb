# Following tutorial at http://blog.datagraph.org/2010/04/parsing-rdf-with-ruby

require 'rdf'
require 'sparql'
require 'net/http'
require 'openssl'
require 'linkeddata'

# 5. method to get the abstract from a person's interest
def info_for(interest)
  abs_query = "PREFIX foaf: <http://xmlns.com/foaf/0.1/>
    PREFIX dbo: <http://dbpedia.org/ontology/>
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
    SELECT ?label ?abs
      WHERE { ?s dbo:abstract ?abs;
              rdfs:label ?label
        FILTER (lang(?abs) = 'en')
        FILTER (lang(?label) = 'en')}"
  abs_graph = RDF::Graph.load(interest)
  sparql_abstracts_query = SPARQL.parse(abs_query)
  sparql_abstracts_query.execute(abs_graph) do |result|
    puts result.label
    puts result.abs
  end
end

# abstract_for('http://dbpedia.org/resource/Quilting')

graph = RDF::Graph.load("foaf_files/sdoljack_foaf.rdf")
# graph = RDF::Graph.load("http://stanford.edu/~sdoljack/sdoljack_foaf.rdf")

# after creating an RDF::Graph object, check what type of object it is with .inspect
puts graph.inspect

# 2. Find everyone I know

query = "
PREFIX foaf: <http://xmlns.com/foaf/0.1/>
SELECT DISTINCT ?o
  WHERE { ?s foaf:knows ?o }
"

# 3. Load all of their FOAF files into the same graph as mine

puts "before loading"
sse = SPARQL.parse(query)
sse.execute(graph) do |result|
  puts result.o
  graph.load(result.o) # graph should now contain the contents of the foaf files of people I know
end

# 4. What are the interests of people I know
interests_query = "
PREFIX foaf: <http://xmlns.com/foaf/0.1/>
SELECT DISTINCT ?interest ?name
  WHERE { ?s foaf:interest ?interest;
            foaf:name ?name}
"

puts "People's interests"
q_parsed = SPARQL.parse(interests_query)
q_parsed.execute(graph) do |result|
  puts result.name
  # puts result.interest
  info_for(result.interest)
end
