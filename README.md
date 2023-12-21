# Grand Théâtre de Québec Website data pipelines
https://grandtheatre.qc.ca

## Input to Artsdata

This website is crawled by an agent on the [Artsdata Huginn platform](https://huginn-staging.herokuapp.com/scenarios/26/diagram).

It also has a taxonomy [gtq-event-type-mapping.ttl](https://github.com/culturecreates/artsdata-planet-gtq/blob/main/gtq-event-type-mapping.ttl) to map strings from the original website to Artsdata event types. To push the taxonomy to Artsdata use the Github workflow in this repo.

Here is the summary of the GTQ pipeline in Huginn:
1. Crawl events listed on https://grandtheatre.qc.ca/programmation/
2. Extract JSON-LD from each webpage
3. Transform with the following SPARQLs
  'remove-blanks',
  'fix-schemaorg-https-objects',
  'fix-wikidata-uri',
  'add-artsdata-uri-using-wikidata-bridge',
  'fix-schemaorg-date-datatype',
  'create-eventseries',
  'copy-subevent-data-to-eventseries',
  'fix-isni',
  'add-artsdata-uri-using-isni-bridge',
  'collapse_duplicate_contact_point_blanknodes'
1. Load graph into Artsdata using Artsdata Databus API


### Compare event images between original website and Artsdata
https://api.artsdata.ca/events?source=http://kg.artsdata.ca/culture-creates/huginn/derived-grandtheatre-qc-ca

https://grandtheatre.qc.ca/programmation/


## Output from Artsdata

Nothing is outputed from Artsdata for use by GTQ at this time.
