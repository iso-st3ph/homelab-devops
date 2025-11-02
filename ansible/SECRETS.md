# Secrets Management with Ansible Vault

This repository uses Ansible Vault to encrypt sensitive data like passwords, API keys, and webhook URLs.

## Quick Start

### 1. Create Vault Password File

```bash
# Copy the example and set your own password
cp ansible/.vault_pass.example ansible/.vault_pass
echo "your-secure-password-here" > ansible/.vault_pass
chmod 600 ansible/.vault_pass
```

**Important**: Never commit `.vault_pass` to git. It's in `.gitignore`.

### 2. View Encrypted Secrets

```bash
cd ansible
ansible-vault view group_vars/all/vault.yml --vault-password-file .vault_pass
```

### 3. Edit Encrypted Secrets

```bash
cd ansible
ansible-vault edit group_vars/all/vault.yml --vault-password-file .vault_pass
```

## Encrypted Variables

Located in `ansible/group_vars/all/vault.yml` (encrypted):

- `vault_grafana_admin_password` - Grafana admin UI password
- `vault_slack_webhook_url` - AlertManager Slack webhook
- `vault_prometheus_admin_password` - Future Prometheus basic auth

These are referenced in `ansible/group_vars/all/vars.yml` (plaintext):

```yaml
grafana_admin_password: "{{ vault_grafana_admin_password }}"
alertmanager_slack_webhook: "{{ vault_slack_webhook_url }}"
```

## Running Playbooks with Vault

### Method 1: Vault Password File (Recommended for local dev)

```bash
# Configure ansible.cfg to use vault password file
cd ansible
ansible-playbook playbooks/deploy-monitoring.yml --vault-password-file .vault_pass
```

### Method 2: Prompt for Password

```bash
cd ansible
ansible-playbook playbooks/deploy-monitoring.yml --ask-vault-pass
```

### Method 3: Environment Variable (CI/CD)

```bash
export ANSIBLE_VAULT_PASSWORD_FILE=.vault_pass
ansible-playbook playbooks/deploy-monitoring.yml
```

## Managing Vault Files

### Encrypt a New File

```bash
ansible-vault encrypt group_vars/all/vault.yml --vault-password-file .vault_pass
```

### Decrypt Temporarily (Don't commit!)

```bash
ansible-vault decrypt group_vars/all/vault.yml --vault-password-file .vault_pass
# Edit the file
ansible-vault encrypt group_vars/all/vault.yml --vault-password-file .vault_pass
```

### Re-key (Change Vault Password)

```bash
ansible-vault rekey group_vars/all/vault.yml \
  --vault-password-file .vault_pass \
  --new-vault-password-file .new_vault_pass
```

### Check if File is Encrypted

```bash
head -1 group_vars/all/vault.yml
# Should show: $ANSIBLE_VAULT;1.1;AES256
```

## CI/CD Integration

### GitHub Actions

Store vault password as GitHub Secret:

```yaml
- name: Run Ansible Playbook
  env:
    ANSIBLE_VAULT_PASSWORD: ${{ secrets.ANSIBLE_VAULT_PASSWORD }}
  run: |
    echo "$ANSIBLE_VAULT_PASSWORD" > ansible/.vault_pass
    ansible-playbook ansible/playbooks/deploy-monitoring.yml \
      --vault-password-file ansible/.vault_pass
```

### GitLab CI

```yaml
deploy:
  script:
    - echo "$VAULT_PASSWORD" > .vault_pass
    - ansible-playbook playbooks/deploy-monitoring.yml --vault-password-file .vault_pass
  variables:
    VAULT_PASSWORD:
      value: ""
      description: "Ansible Vault password"
  only:
    - main
```

## Best Practices

### ✅ DO

- Use separate vault files per environment (dev/staging/prod)
- Rotate vault passwords regularly
- Use strong, random passwords for vault
- Store vault password in password manager
- Use vault password files for local development
- Encrypt entire variable files, not individual values
- Keep vault.yml and vars.yml separate
- Document which secrets are in vault

### ❌ DON'T

- Commit `.vault_pass` to version control
- Use weak/guessable vault passwords
- Decrypt files and leave them decrypted
- Store vault password in playbooks
- Share vault passwords via chat/email
- Use the same password for all environments
- Mix encrypted and plaintext in same file

## Multi-Environment Setup

```bash
# Directory structure
group_vars/
  all/
    vars.yml           # Common variables
    vault.yml          # Common secrets (encrypted)
  production/
    vars.yml           # Prod-specific variables
    vault.yml          # Prod secrets (encrypted)
  staging/
    vars.yml           # Staging-specific variables
    vault.yml          # Staging secrets (encrypted)
```

## Troubleshooting

### Error: "Vault password was not found"

```bash
# Ensure vault password file exists
ls -la ansible/.vault_pass

# Or set in ansible.cfg
echo "vault_password_file = .vault_pass" >> ansible/ansible.cfg
```

### Error: "Decryption failed"

```bash
# Wrong password in .vault_pass
# Verify the password or use --ask-vault-pass to enter manually
```

### Error: "Vault data format is invalid"

```bash
# File may be corrupted or partially encrypted
# Restore from git backup:
git checkout ansible/group_vars/all/vault.yml
```

## Rotation Strategy

### Monthly Rotation (Production)

1. Generate new vault password
2. Re-key vault files: `ansible-vault rekey`
3. Update password in CI/CD secrets
4. Update team password manager
5. Test playbooks before committing

### Credential Rotation (Inside Vault)

1. `ansible-vault edit group_vars/all/vault.yml`
2. Update password values
3. Run playbook to apply changes
4. Verify services using new credentials

## Example: Adding New Secret

```bash
# Edit vault file
ansible-vault edit group_vars/all/vault.yml --vault-password-file .vault_pass

# Add new variable
vault_postgres_password: super-secret-password

# Reference in vars.yml
echo "postgres_password: \"{{ vault_postgres_password }}\"" >> group_vars/all/vars.yml

# Use in playbook
- name: Configure PostgreSQL
  community.postgresql.postgresql_user:
    password: "{{ postgres_password }}"
```

## Security Checklist

- [ ] Vault password is stored in password manager
- [ ] `.vault_pass` is in `.gitignore`
- [ ] All sensitive values are in `vault.yml`
- [ ] Vault file is encrypted (check with `head -1`)
- [ ] CI/CD uses secrets management (not hardcoded passwords)
- [ ] Team members have access to vault password
- [ ] Rotation schedule is documented
- [ ] Backup of vault password exists (securely)
- [ ] Different passwords for each environment

## References

- [Ansible Vault Documentation](https://docs.ansible.com/ansible/latest/vault_guide/index.html)
- [Best Practices for Variables and Vaults](https://docs.ansible.com/ansible/latest/tips_tricks/ansible_tips_tricks.html#tip-for-variables-and-vaults)
- [Encrypting Content with Ansible Vault](https://docs.ansible.com/ansible/latest/vault_guide/vault_encrypting_content.html)
