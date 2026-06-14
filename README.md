# BadgeAble — OutSystems Platform Detachment

Self-managed Blue Badge application detached from OutSystems 11 and running as standalone .NET applications on AWS, eliminating all platform licensing dependencies.

**For the complete case study with detailed technical analysis, see [CASE_STUDY.md](CASE_STUDY.md)**

**⚠️ Note: This is a sanitized version for portfolio purposes. All sensitive data, URLs, and identifiers have been anonymized.**

## Overview

A full Blue Badge case management application (150 modules) was detached from the OutSystems low-code platform and migrated to self-managed infrastructure on AWS. The system now runs independently with zero licensing costs or vendor dependencies.

## Architecture

```mermaid
%%{init: {'theme': 'dark', 'themeVariables': {'primaryColor': '#386193', 'primaryTextColor': '#fff', 'primaryBorderColor': '#5a8cc8', 'lineColor': '#5a8cc8', 'secondaryColor': '#1a1a2e', 'tertiaryColor': '#16213e', 'background': '#0d1117', 'mainBkg': '#0d1117', 'nodeBorder': '#5a8cc8'}, 'layout': 'elk'}}%%
flowchart TB
    Users(["Staff / Public"])

    subgraph AWS["AWS (eu-west-2)"]
        direction TB
        subgraph Network["VPC"]
            direction TB
            ALB["Application Load Balancer<br/>SSL Termination + Health Checks"]
            subgraph Compute["EC2 Instance"]
                IIS["IIS 10<br/>Web Server"]
                NET[".NET 4.8.1<br/>150 Modules"]
            end
            SQL["SQL Server 2022 Express<br/>Blue Badge Database"]
        end
    end

    subgraph IaC["Infrastructure as Code"]
        Terraform["Terraform<br/>VPC · ALB · EC2 · SGs · IAM"]
    end

    subgraph Build["Build Pipeline"]
        MSBuild["MSBuild<br/>build_all.ps1"]
        Git["Git<br/>150 module repos"]
    end

    Users -->|"HTTPS"| ALB
    ALB -->|"Forward"| IIS
    IIS --> NET
    NET -->|"Queries"| SQL
    Terraform -.->|"Provisions"| Network
    Git -.->|"Source"| MSBuild
    MSBuild -.->|"Deploys to"| IIS

    style AWS fill:#0d1117,stroke:#386193,stroke-width:3px,color:#fff
    style Network fill:#1a1a2e,stroke:#5a8cc8,stroke-width:2px,color:#fff
    style Compute fill:#16213e,stroke:#2ecc71,stroke-width:2px,color:#fff
    style IaC fill:#1a1a2e,stroke:#f39c12,stroke-width:2px,stroke-dasharray:5 5,color:#fff
    style Build fill:#1a1a2e,stroke:#9b59b6,stroke-width:2px,stroke-dasharray:5 5,color:#fff
    style Users fill:#386193,stroke:#5a8cc8,stroke-width:2px,color:#fff
    style ALB fill:#2c3e50,stroke:#3498db,stroke-width:2px,color:#fff
    style IIS fill:#2c3e50,stroke:#2ecc71,stroke-width:2px,color:#fff
    style NET fill:#2c3e50,stroke:#2ecc71,stroke-width:2px,color:#fff
    style SQL fill:#2c3e50,stroke:#e74c3c,stroke-width:2px,color:#fff
    style Terraform fill:#2c3e50,stroke:#f39c12,stroke-width:2px,color:#fff
    style MSBuild fill:#2c3e50,stroke:#9b59b6,stroke-width:2px,color:#fff
    style Git fill:#2c3e50,stroke:#9b59b6,stroke-width:2px,color:#fff

    linkStyle 0 stroke:#3498db,stroke-width:2px
    linkStyle 1 stroke:#3498db,stroke-width:2px
    linkStyle 2 stroke:#2ecc71,stroke-width:2px
    linkStyle 3 stroke:#e74c3c,stroke-width:2px
    linkStyle 4 stroke:#f39c12,stroke-width:2px,stroke-dasharray:5 5
    linkStyle 5 stroke:#9b59b6,stroke-width:2px,stroke-dasharray:5 5
    linkStyle 6 stroke:#9b59b6,stroke-width:2px,stroke-dasharray:5 5
```

## What Was Detached

- **150 .NET modules** extracted from OutSystems runtime
- **UI application** (Blue Badge customer-facing forms)
- **Case management** (staff workflows, approvals, appeals)
- **Communications** (letters, notifications)
- **Integrations** (external service lookups)

## Technology Stack

| Component | Technology |
|-----------|-----------|
| Runtime | .NET 4.8.1 |
| Web Server | IIS 10 |
| Database | SQL Server 2022 Express |
| Infrastructure | Terraform (VPC, ALB, EC2, SGs, IAM) |
| Build Tools | Visual Studio 2022 Build Tools (MSBuild) |
| Region | eu-west-2 (London) |

## Key Outcomes

- **Zero licensing dependencies** — no OutSystems licence required
- **Full source control** — all 150 modules in Git
- **Automated builds** — PowerShell batch build script
- **Infrastructure as Code** — Terraform for reproducibility
- **Comprehensive documentation** — Operations runbook + detachment summary

## Project Structure

```
├── src/                        # Detached .NET source code (150 modules)
│   ├── BlueBadge_UI/           # Main UI application
│   ├── BlueBadgeCase_CW/       # Case management
│   ├── BlueBadgeComms_CS/      # Communications
│   └── ...                     # 147 more modules
├── scripts/
│   └── build_all.ps1           # Builds all modules
├── infrastructure/
│   └── terraform/              # VPC, ALB, EC2, security groups, IAM
├── docs/
│   ├── OPERATIONS.md           # Full operations runbook
│   └── DETACHMENT_SUMMARY.md   # Manager-friendly summary
├── CASE_STUDY.md
└── README.md
```

## Building

```powershell
$msbuild = "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\MSBuild.exe"
& $msbuild src\<ModuleName>\<ModuleName>.sln /p:Configuration=Release /restore /v:minimal
```
