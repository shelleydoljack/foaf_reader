# Following tutorial at http://blog.datagraph.org/2010/04/parsing-rdf-with-ruby

require 'rdf'
require 'sparql'
require 'net/http'
require 'openssl'
require 'linkeddata'

graph = RDF::Graph.load("foaf_files/sdoljack_foaf.rdf")
# graph = RDF::Graph.load("http://stanford.edu/~sdoljack/sdoljack_foaf.rdf")

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
SELECT DISTINCT ?interest
  WHERE { ?s foaf:interest ?interest}
"

puts "People's interests"
q_parsed = SPARQL.parse(interests_query)
q_parsed.execute(graph) do |result|
  puts result.interest
end

# 5.
