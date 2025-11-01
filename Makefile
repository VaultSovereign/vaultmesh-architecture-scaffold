.PHONY: help env render refscan snapshot-revocation verify-revocation clean

# Default target
help:
	@echo "VaultMesh Architecture Scaffold - Available Targets:"
	@echo ""
	@echo "  make env                    - Set up the development environment"
	@echo "  make render                 - Render documentation and manifests"
	@echo "  make refscan                - Scan for references and dependencies"
	@echo "  make snapshot-revocation    - Create revocation snapshot"
	@echo "  make verify-revocation      - Verify revocation status"
	@echo "  make clean                  - Clean generated files"
	@echo ""

# Environment setup target
env:
	@echo "Setting up VaultMesh Architecture environment..."
	@echo "Checking required directories..."
	@mkdir -p docs runbooks manifests receipts reports scripts/ops audits
	@echo "✓ Directory structure verified"
	@echo "Checking for required tools..."
	@command -v git >/dev/null 2>&1 || { echo "❌ git is required but not installed"; exit 1; }
	@echo "✓ git found"
	@command -v make >/dev/null 2>&1 || { echo "❌ make is required but not installed"; exit 1; }
	@echo "✓ make found"
	@echo "Environment setup complete!"

# Render documentation and manifests
render:
	@echo "Rendering VaultMesh Architecture documentation..."
	@echo "Processing documentation files..."
	@if [ -d "docs" ]; then \
		echo "✓ Documentation directory found"; \
		find docs -name "*.md" -exec echo "  - {}" \; ; \
	fi
	@echo "Processing manifest files..."
	@if [ -d "manifests" ]; then \
		echo "✓ Manifests directory found"; \
		find manifests -type f \( -name "*.yaml" -o -name "*.yml" -o -name "*.json" \) -exec echo "  - {}" \; 2>/dev/null || true; \
	fi
	@echo "Render complete!"

# Reference scanning
refscan:
	@echo "Scanning VaultMesh Architecture for references..."
	@echo "Scanning documentation for cross-references..."
	@find docs -name "*.md" -type f -exec grep -l "\[.*\](.*)" {} \; 2>/dev/null | while read file; do \
		echo "  References found in: $$file"; \
	done || true
	@echo "Scanning manifests for resource references..."
	@find manifests -type f \( -name "*.yaml" -o -name "*.yml" \) -exec grep -l "ref:" {} \; 2>/dev/null | while read file; do \
		echo "  References found in: $$file"; \
	done || true
	@echo "Scanning for external dependencies..."
	@if [ -f "package.json" ]; then echo "  Found: package.json"; fi
	@if [ -f "requirements.txt" ]; then echo "  Found: requirements.txt"; fi
	@if [ -f "go.mod" ]; then echo "  Found: go.mod"; fi
	@echo "Reference scan complete!"

# Snapshot revocation
snapshot-revocation:
	@echo "Creating revocation snapshot for VaultMesh Architecture..."
	@timestamp=$$(date +%Y%m%d-%H%M%S); \
	snapshot_dir="receipts/revocations/$$timestamp"; \
	mkdir -p "$$snapshot_dir"; \
	echo "Creating snapshot at: $$snapshot_dir"; \
	echo "# Revocation Snapshot" > "$$snapshot_dir/snapshot.md"; \
	echo "Generated: $$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$$snapshot_dir/snapshot.md"; \
	echo "" >> "$$snapshot_dir/snapshot.md"; \
	echo "## Architecture State" >> "$$snapshot_dir/snapshot.md"; \
	git rev-parse HEAD >> "$$snapshot_dir/snapshot.md" 2>/dev/null || echo "Not in git repository" >> "$$snapshot_dir/snapshot.md"; \
	echo "" >> "$$snapshot_dir/snapshot.md"; \
	echo "## File Checksums" >> "$$snapshot_dir/snapshot.md"; \
	find docs manifests runbooks -type f -exec sha256sum {} \; >> "$$snapshot_dir/checksums.txt" 2>/dev/null || true; \
	echo "✓ Snapshot created: $$snapshot_dir"
	@echo "Snapshot revocation complete!"

# Verify revocation
verify-revocation:
	@echo "Verifying revocation status for VaultMesh Architecture..."
	@if [ ! -d "receipts/revocations" ]; then \
		echo "⚠️  No revocation snapshots found"; \
		exit 0; \
	fi
	@latest_snapshot=$$(find receipts/revocations -name "snapshot.md" -type f | sort -r | head -n 1); \
	if [ -n "$$latest_snapshot" ]; then \
		snapshot_dir=$$(dirname "$$latest_snapshot"); \
		echo "Latest snapshot: $$snapshot_dir"; \
		if [ -f "$$snapshot_dir/snapshot.md" ]; then \
			echo "Snapshot details:"; \
			cat "$$snapshot_dir/snapshot.md"; \
		fi; \
		if [ -f "$$snapshot_dir/checksums.txt" ]; then \
			echo ""; \
			echo "Verifying checksums..."; \
			cd "$$(git rev-parse --show-toplevel 2>/dev/null || echo .)" && \
			while IFS= read -r line; do \
				checksum=$$(echo "$$line" | awk '{print $$1}'); \
				filepath=$$(echo "$$line" | awk '{print $$2}'); \
				if [ -f "$$filepath" ]; then \
					current=$$(sha256sum "$$filepath" | awk '{print $$1}'); \
					if [ "$$checksum" != "$$current" ]; then \
						echo "⚠️  Modified: $$filepath"; \
					fi; \
				else \
					echo "⚠️  Missing: $$filepath"; \
				fi; \
			done < "$$snapshot_dir/checksums.txt" || true; \
		fi; \
		echo "✓ Verification complete"; \
	else \
		echo "No snapshots to verify"; \
	fi

# Clean generated files
clean:
	@echo "Cleaning generated files..."
	@find reports -type f -not -name "README.md" -not -name ".gitkeep" -delete 2>/dev/null || true
	@echo "✓ Clean complete!"
