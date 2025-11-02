.PHONY: docs serve publish lint tf-test mon-up mon-down mon-logs security-scan

serve:     ## Run docs locally
	mkdocs serve -a 0.0.0.0:8000

publish:   ## Publish docs to gh-pages
	mkdocs gh-deploy --force

lint:      ## Run all pre-commit hooks
	pre-commit run -a

tf-test:   ## Run terraform tests for module(s)
	( cd terraform/modules/ec2_minimal && terraform init -backend=false && terraform test )

mon-up:    ## Start monitoring stack (Prometheus + Grafana)
	cd docker/monitoring-stack && cp -n .env.example .env || true && docker compose up -d

mon-down:  ## Stop monitoring stack
	cd docker/monitoring-stack && docker compose down

mon-logs:  ## View monitoring stack logs
	cd docker/monitoring-stack && docker compose logs -f

security-scan:  ## Run Trivy security scan on all Docker images
	@echo "=== Scanning Docker images for vulnerabilities ===" && \
	./scripts/trivy-scan.sh
