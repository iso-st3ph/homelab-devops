.PHONY: docs serve publish lint tf-test
serve:     ## Run docs locally
	mkdocs serve -a 0.0.0.0:8000
publish:   ## Publish docs to gh-pages
	mkdocs gh-deploy --force
lint:      ## Run all pre-commit hooks
	pre-commit run -a
tf-test:   ## Run terraform tests for module(s)
	( cd terraform/modules/ec2_minimal && terraform init -backend=false && terraform test )
