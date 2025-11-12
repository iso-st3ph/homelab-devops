# Container Security Scanning with Trivy

# Security

IsoVault is built for privacy and security from the ground up.

## Encryption
- All backups are encrypted client-side before transmission.
- Optionally, use your own encryption keys.

## Token Scopes
- PBS API tokens are scoped to specific namespaces.
- Least-privilege access by default.

## Zero Trust & Firewall
- Cloudflare Zero Trust restricts access to authorized users/devices.
- Default firewall rules block all except whitelisted sources.

## Data Isolation
- Each backup is stored in a dedicated namespace or datastore.
- No cross-tenant access; strict separation.

## Backup Verification
- Restore jobs are isolated and logged.
- Regular integrity checks recommended.

### Scan Docker Compose Stack

```bash
# Extract images from docker-compose.yml
docker compose -f docker/monitoring-stack/docker-compose.yml config --images | xargs -I {} trivy image {}
```

### Scan Specific Vulnerability Types

```bash
# OS packages only
trivy image --vuln-type os grafana/grafana:latest

# Application dependencies only  
trivy image --vuln-type library grafana/grafana:latest

# Both
trivy image --vuln-type os,library grafana/grafana:latest
```

## Understanding Results

### Severity Levels

- **CRITICAL**: Immediate action required - exploitable vulnerability
- **HIGH**: Patch soon - significant security risk
- **MEDIUM**: Schedule patching - moderate risk
- **LOW**: Informational - minimal risk
- **UNKNOWN**: Not yet assessed by CVE database

### Sample Output

```
grafana/grafana:latest (debian 12.1)

Total: 45 (HIGH: 12, CRITICAL: 3)

┌──────────────────┬────────────────┬──────────┬───────────────────┬───────────────┬──────────────────────┐
│     Library      │ Vulnerability  │ Severity │ Installed Version │ Fixed Version │        Title         │
├──────────────────┼────────────────┼──────────┼───────────────────┼───────────────┼──────────────────────┤
│ openssl          │ CVE-2024-1234  │ CRITICAL │ 1.1.1n            │ 1.1.1p        │ OpenSSL security...  │
│ libcurl          │ CVE-2024-5678  │ HIGH     │ 7.68.0            │ 7.74.0        │ curl security flaw   │
└──────────────────┴────────────────┴──────────┴───────────────────┴───────────────┴──────────────────────┘
```

## Remediation Workflow

### 1. Review Scan Results

```bash
# Generate detailed report
trivy image --format json --output scan-report.json grafana/grafana:latest

# View critical vulnerabilities only
trivy image --severity CRITICAL grafana/grafana:latest
```

### 2. Check for Updates

```bash
# Pull latest image
docker pull grafana/grafana:latest

# Rescan
trivy image grafana/grafana:latest
```

### 3. Pin Specific Versions

If `latest` has critical vulnerabilities, pin to a specific version:

```yaml
# docker-compose.yml
services:
  grafana:
    image: grafana/grafana:10.2.3  # Pinned version instead of :latest
```

### 4. Track in Issues

For unfixed vulnerabilities:

1. Check if upstream project has a fix
2. Monitor CVE database for patches
3. Consider temporary workarounds
4. Document accepted risks

## CI/CD Configuration

### GitHub Actions Workflow

```yaml
security_scan:
  runs-on: ubuntu-latest
  permissions:
    contents: read
    security-events: write
  steps:
    - uses: actions/checkout@v4
    
    - name: Run Trivy Scanner
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: 'grafana/grafana:latest'
        format: 'table'
        exit-code: '0'  # Change to '1' to fail pipeline on vulnerabilities
        severity: 'CRITICAL,HIGH'
```

### Exit Code Strategy

- `exit-code: 0` - Informational (doesn't fail build)
- `exit-code: 1` - Fail build if vulnerabilities found (strict mode)

**Current Setup**: Informational mode (`0`) for visibility without blocking deployments.

**Production Recommendation**: Use `exit-code: 1` for production branches.

## Automation

### Pre-commit Hook

Add to `.pre-commit-config.yaml`:

```yaml
- repo: local
  hooks:
    - id: trivy-scan
      name: Trivy Security Scan
      entry: ./scripts/trivy-scan.sh
      language: script
      pass_filenames: false
```

### Scheduled Scans

Add to GitHub Actions for weekly scans:

```yaml
on:
  schedule:
    - cron: '0 0 * * 0'  # Weekly on Sunday
```

## Best Practices

### ✅ DO

- Scan images regularly (weekly minimum)
- Pin image versions in production
- Monitor upstream security advisories
- Update base images promptly for critical CVEs
- Use minimal base images (alpine, distroless)
- Scan before and after deployment
- Document accepted risks for unfixed vulnerabilities

### ❌ DON'T

- Use `:latest` tags in production
- Ignore CRITICAL vulnerabilities
- Assume vendor images are secure
- Skip scans for "trusted" images
- Deploy without knowing vulnerability status

## Advanced Usage

### Scan Local Dockerfile

```bash
trivy config Dockerfile
```

### Scan Filesystem

```bash
trivy fs /path/to/directory
```

### Scan Kubernetes Manifests

```bash
trivy config k8s-deployment.yaml
```

### Scan Terraform Code

```bash
trivy config terraform/
```

### Custom Policy

Create `.trivyignore` to suppress specific CVEs:

```
# .trivyignore
# Suppress known false positive
CVE-2024-1234

# Suppress until fix available (document why)
CVE-2024-5678  # No fix available, mitigated by network policy
```

## Integration with Security Tools

### SARIF Output for GitHub Security Tab

```yaml
- name: Run Trivy Scanner
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: 'grafana/grafana:latest'
    format: 'sarif'
    output: 'trivy-results.sarif'

- name: Upload to GitHub Security
  uses: github/codeql-action/upload-sarif@v2
  with:
    sarif_file: 'trivy-results.sarif'
```

### Slack Notifications

```bash
# Scan and send results to Slack
trivy image grafana/grafana:latest --format json | \
  jq -r '.Results[] | select(.Vulnerabilities != null) | .Vulnerabilities[] | select(.Severity == "CRITICAL")' | \
  wc -l | \
  xargs -I {} curl -X POST $SLACK_WEBHOOK_URL -d '{"text":"Found {} critical vulnerabilities"}'
```

## Metrics and Reporting

### Track Vulnerability Trends

```bash
# Generate monthly reports
mkdir -p security-reports/$(date +%Y-%m)
trivy image --format json \
  --output security-reports/$(date +%Y-%m)/scan-$(date +%Y-%m-%d).json \
  grafana/grafana:latest
```

### Dashboard Metrics

Track in Prometheus:

- Number of images scanned
- Critical vulnerabilities count
- Mean time to remediation (MTTR)
- Scan frequency

## Resources

- [Trivy Documentation](https://aquasecurity.github.io/trivy/)
- [Trivy GitHub Repository](https://github.com/aquasecurity/trivy)
- [CVE Database](https://cve.mitre.org/)
- [National Vulnerability Database](https://nvd.nist.gov/)
- [Trivy Operator for Kubernetes](https://github.com/aquasecurity/trivy-operator)

## Troubleshooting

### Scan Taking Too Long

```bash
# Skip database update if recent
trivy image --skip-db-update grafana/grafana:latest

# Use cache
trivy image --cache-dir ~/.cache/trivy grafana/grafana:latest
```

### Database Update Fails

```bash
# Manual database update
trivy image --download-db-only

# Clear cache and retry
trivy image --clear-cache
```

### False Positives

1. Verify vulnerability applies to your usage
2. Check if already patched in latest version
3. Add to `.trivyignore` with documentation
4. Report to Trivy if incorrect

## Security Scanning Checklist

- [ ] Trivy installed locally
- [ ] CI/CD integration configured
- [ ] All images scanned before deployment
- [ ] Critical vulnerabilities documented
- [ ] `.trivyignore` file maintained
- [ ] Scan results reviewed weekly
- [ ] Update schedule established
- [ ] Team notified of critical findings
- [ ] Remediation tracked in issues

---

**Remember**: Security scanning is ongoing, not one-time. Regularly update and rescan images as new vulnerabilities are discovered.
