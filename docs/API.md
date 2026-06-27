
Wonderland API

Base URL:

http://127.0.0.1:9105/api/v1
Endpoints
GET /version
GET /ready
GET /status
GET /state
GET /services
GET /events
GET /timeline
GET /drift
GET /schema
GET /config
GET /plugins
GET /metrics
GET /openapi.json
GET /stream
Examples
curl -s http://127.0.0.1:9105/api/v1/ready | jq
curl -s http://127.0.0.1:9105/api/v1/state | jq '.controller.version'
curl -s http://127.0.0.1:9105/api/v1/drift | jq
curl -N http://127.0.0.1:9105/api/v1/stream

The OpenAPI contract is available at:

docs/api/openapi.json

