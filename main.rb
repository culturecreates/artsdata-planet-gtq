require 'linkeddata'
require 'nokogiri'
require 'open-uri'

# Initialize the RDF vocabularies
SCHEMA = RDF::Vocab::SCHEMA
PROV = RDF::Vocab::PROV
SKOS = RDF::Vocab::SKOS

def get_event_concept_from_web_page(event_page_url)
  main_page_html_text = URI.open(event_page_url).read
  main_doc = Nokogiri::HTML(main_page_html_text)
  event_concept = main_doc.css('div.show-category').first.text.strip
  puts "Event concept: #{event_concept}"
  event_concept
end

def fetch_concept_uri_from_concept_graph(event_concept, concept_graph)
  object = RDF::Literal.new(event_concept, language: :fr)
  concept = concept_graph.query([nil, SKOS.prefLabel, object]).first&.subject
  if concept
    puts "Concept URI: #{concept}"
    concept
  else
    nil
  end
end

def insert_concept_uri_to_event_graph(event, concept_uri, events_graph)
  events_graph.insert([event.subject, SCHEMA.additionalType, concept_uri])
  puts "Event concept added to graph\n\n"
end

# Load the events graph and the concept graph
events_graph = RDF::Graph.load("output/grandtheatrequebec-events.jsonld")
concept_graph = RDF::Graph.load("gtq-event-type-mapping.ttl")

events = events_graph.query([nil, RDF.type, SCHEMA.Event]) +
         events_graph.query([nil, RDF.type, SCHEMA.EventSeries])

puts "Total events found: #{events.count}"

# For each event, extract the event concept from the event page
events.each do |event|
  retry_count = 0
  max_retries = 3
  begin
    # Extract the URL of the event page
    page_url = events_graph.query([event.subject, PROV.wasDerivedFrom, nil]).first.object
    puts "Processing #{page_url}"

    # Extract the event concept from the event page
    event_concept = get_event_concept_from_web_page(page_url)
    
    if event_concept
      concept_uri = fetch_concept_uri_from_concept_graph(event_concept, concept_graph)
      if concept_uri
        insert_concept_uri_to_event_graph(event, concept_uri, events_graph)
      else
        puts "Concept URI not found in the concept graph"
      end
    else
      puts "No event concept found"
    end
  rescue StandardError => e
    puts "An error occurred while processing #{page_url}: #{e.message}"
    retry_count += 1
    if retry_count < max_retries
      # Retry after 1 second
      puts "Retrying..."
      sleep 1
      retry
    else
      puts "Max retries reached. Skipping..."
    end
  end
end

sparql_paths = [
  "./sparql/create_eventseries.sparql",
  "./sparql/copy_subevent_data_to_eventseries.sparql"
]

sparql_paths.each do |sparql_path|
  puts "Executing #{sparql_path}"
  file = File.read(sparql_path)
  events_graph.query(SPARQL.parse(file, update: true))
end

# Save the updated events graph
File.open("output/grandtheatrequebec-events-with-concept.jsonld", 'w') do |file|
  file.puts(events_graph.dump(:jsonld))
end
