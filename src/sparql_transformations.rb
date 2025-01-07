require 'linkeddata'

events_graph = RDF::Graph.load("output/grandtheatrequebec-events-with-concept.jsonld")

sparql_paths = [
  "./sparql/create_eventseries.sparql",
  "./sparql/copy_subevent_data_to_eventseries.sparql"
]

sparql_paths.each do |sparql_path|
  puts "Executing #{sparql_path}"
  file = File.read(sparql_path)
  events_graph.query(SPARQL.parse(file, update: true))
end

File.open("output/grandtheatrequebec-events-with-concept-and-eventseries.jsonld", 'w') do |file|
  file.puts(events_graph.dump(:jsonld))
end