# VaultMesh Architecture Scaffold

Public architectural dossier for VaultMesh - a comprehensive scaffold for managing architecture documentation, operational procedures, and compliance artifacts.

## Directory Structure

```
vaultmesh-architecture-scaffold/
├── docs/               # Architecture documentation and technical specifications
├── runbooks/           # Operational runbooks and procedures
├── manifests/          # Configuration manifests and IaC definitions
├── receipts/           # Transaction receipts and audit trails
├── reports/            # Generated reports and analysis outputs
├── scripts/ops/        # Operational automation scripts
├── audits/             # Security audits and compliance documentation
└── .github/workflows/  # CI/CD guards for quality assurance
```

## CI Guards

The scaffold includes three GitHub Actions workflows to maintain quality:

- **architecture-guard.yml** - Validates architectural integrity and structure
- **folder-purity.yml** - Ensures proper folder organization and file placement
- **docs-purity.yml** - Validates documentation quality and completeness

## Makefile Targets

### Environment Setup
```bash
make env
```
Sets up the development environment and verifies required tools.

### Render Documentation
```bash
make render
```
Processes and renders documentation and manifest files.

### Reference Scanning
```bash
make refscan
```
Scans for cross-references and external dependencies.

### Revocation Management
```bash
make snapshot-revocation
```
Creates a timestamped snapshot of the current architecture state with checksums.

```bash
make verify-revocation
```
Verifies the integrity of the latest revocation snapshot.

### Clean
```bash
make clean
```
Removes generated files while preserving structure.

## Getting Started

1. **Set up environment:**
   ```bash
   make env
   ```

2. **View available commands:**
   ```bash
   make help
   ```

3. **Create a snapshot:**
   ```bash
   make snapshot-revocation
   ```

4. **Verify integrity:**
   ```bash
   make verify-revocation
   ```

## Contributing

Please ensure all contributions:
- Follow the established directory structure
- Pass all CI guard checks
- Include appropriate documentation
- Maintain folder purity standards

## License

See [LICENSE](LICENSE) file for details.