# monitoring module

Creates one private EC2 instance for a basic monitoring stack:
- Grafana (`:3000`)
- Prometheus (`:9090`)
- Loki (`:3100`)

The default user data installs Docker and runs all three containers.
Provide `prometheus_scrape_targets` to add extra scrape endpoints.
