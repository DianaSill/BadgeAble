# Case Study: OutSystems Platform Detachment

## Project Overview

**Challenge**: A critical Blue Badge application was locked into OutSystems 11, a licensed low-code platform. The organisation needed to eliminate the ongoing licensing cost while maintaining full application functionality.

**Solution**: Detach all 150 modules from the OutSystems runtime, convert to standalone .NET applications, and deploy on self-managed AWS infrastructure with Terraform.

**Impact**: Complete elimination of platform licensing dependencies, full source code ownership, and a documented path for long-term maintenance.

## Business Requirements

- Eliminate OutSystems licensing costs
- Maintain all existing application functionality
- No disruption to Blue Badge service users
- Full source code ownership and version control
- Documented operations for future maintainers
- Infrastructure reproducible via code

## Technical Challenges & Solutions

### Challenge 1: Module Extraction (150 Modules)

**Problem**: OutSystems compiles applications into its own runtime format. The source needs to be extracted and converted to standard .NET projects that can build independently.

**Solution**:
- Exported all 150 modules from OutSystems Service Studio
- Converted each to standard .NET 4.8.1 solutions
- Resolved inter-module dependencies manually
- Created batch build script to compile all modules in correct order

**Result**: All modules build successfully with standard MSBuild tooling.

### Challenge 2: Database Migration

**Problem**: OutSystems manages its own database schema with platform-specific metadata tables and naming conventions.

**Solution**:
- Exported database schema from OutSystems platform database
- Migrated to SQL Server 2022 Express (free, no licensing)
- Fixed entity references that depended on OutSystems internal IDs
- Documented all schema relationships in operations runbook

**Result**: Clean database running on SQL Server Express with zero platform dependencies.

### Challenge 3: Infrastructure Provisioning

**Problem**: Needed reproducible infrastructure that could be rebuilt if the server failed, without relying on manual console clicks.

**Solution**:
- Terraform modules for: VPC, subnets, ALB, EC2 instance, security groups, IAM roles
- EC2 user data script installs .NET runtime, IIS features, and SQL Server Express
- ALB health checks ensure traffic only routes to healthy instances

**Result**: Entire infrastructure can be destroyed and recreated in ~15 minutes.

### Challenge 4: Build Automation

**Problem**: 150 modules with interdependencies need to build in the correct order without manual intervention.

**Solution**:
- PowerShell script (`build_all.ps1`) that:
  - Resolves dependency order automatically
  - Builds each module with MSBuild in Release configuration
  - Reports failures clearly with module name and error
  - Continues past non-critical failures

**Result**: Single-command build of the entire application stack.

### Challenge 5: Knowledge Transfer

**Problem**: The system is complex and was previously managed by OutSystems specialists. Future maintainers may not have that background.

**Solution**:
- **OPERATIONS.md**: Full runbook covering credentials, database access, common fixes, deployment checklists, and architecture
- **DETACHMENT_SUMMARY.md**: Manager-friendly overview of what was done and why
- Both documents written assuming no prior OutSystems knowledge

**Result**: Any .NET developer can pick up and maintain the system.

## Architecture Decisions

| Decision | Rationale |
|----------|-----------|
| .NET 4.8.1 (not .NET 8) | Modules were built for .NET Framework; migration to modern .NET would require rewriting |
| SQL Server Express (not RDS) | Co-located on same EC2 for simplicity; database is small enough |
| Terraform (not CloudFormation) | Team preference; works across providers if needed later |
| Single EC2 (not ECS/Fargate) | IIS + .NET Framework requires Windows; containers add complexity without benefit here |
| ALB (not direct access) | SSL termination, health checks, future scalability |

## Results

| Metric | Before | After |
|--------|--------|-------|
| Platform licensing | £XX,000/year | £0 |
| Source code ownership | Vendor-locked | Full Git history |
| Infrastructure reproducibility | Manual | Terraform (15 min rebuild) |
| Build process | OutSystems Service Studio | Single PowerShell command |
| Documentation | Platform-specific | Standard .NET operations runbook |
| Deployment dependency | OutSystems cloud | Self-managed AWS |
