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

# Security
.PHONY: security-scan
security-scan:
	@echo "Running Trivy security scan..."
	./scripts/trivy-scan.sh

# Grafana Dashboards
.PHONY: grafana-dashboards
grafana-dashboards:
	@echo "Importing Grafana dashboards..."
	./scripts/import-grafana-dashboards.sh

# Kubernetes
.PHONY: k8s-deploy k8s-status k8s-logs k8s-clean
k8s-deploy:  ## Deploy monitoring stack to Kubernetes
	cd kubernetes/monitoring && ./deploy.sh

k8s-status:  ## Check Kubernetes monitoring stack status
	export KUBECONFIG=~/.kube/config && kubectl get all -n monitoring

k8s-logs:    ## View Kubernetes pod logs
	@export KUBECONFIG=~/.kube/config && \
	echo "Available pods:" && kubectl get pods -n monitoring && \
	read -p "Enter pod name: " pod && \
	kubectl logs -f $$pod -n monitoring

k8s-clean:   ## Remove monitoring stack from Kubernetes
	@export KUBECONFIG=~/.kube/config && \
	kubectl delete -f kubernetes/monitoring/ || true
