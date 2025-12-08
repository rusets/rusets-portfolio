# **Architecture Overview — rusets-portfolio**

This document describes the architecture of the **Ruslan AWS portfolio website**, deployed on a secure, automated AWS stack using Terraform and GitHub Actions OIDC.  
The goal of this project is to demonstrate production-grade infrastructure patterns applied to a lightweight static site, with an emphasis on clear design, security, and cost efficiency.

---

## **Project Structure**

---

```text
rusets-portfolio/
├── .github/
│   └── workflows/
│       ├── portfolio.yml        # Deploy site/ → S3 + CloudFront invalidation
│       ├── plan.yml             # Terraform plan for infra/ (manual)
│       └── apply.yml            # Terraform apply for infra/ (manual)
├── docs/
│   ├── architecture.md          # High-level architecture overview
│   └── screenshots/
│       ├── 01-home-hero.png
│       ├── 02-projects-grid.png
│       ├── 03-github-actions-workflows.png
│       └── 04-cloudfront-distribution.png
├── infra/
│   ├── .checkov.yml             # checkov policy exceptions for infra
│   ├── backend.tf               # Remote backend (S3 + DynamoDB lock)
│   ├── dns.tf                   # Route53 hosted zone + records
│   ├── github_oidc.tf           # IAM role/policy for GitHub Actions OIDC
│   ├── locals.tf                # Global locals (names, tags, bucket names)
│   ├── outputs.tf               # CloudFront domain, zone IDs, etc.
│   ├── providers.tf             # AWS providers (default + us-east-1 for ACM)
│   ├── site_s3_cloudfront.tf    # S3 site bucket + CloudFront + OAC + errors
│   └── variables.tf             # Input variables (domain name, tags)
├── infra-bootstrap/
│   ├── .checkov.yml             # checkov config for bootstrap-only resources
│   ├── locals.tf                # Tags and naming for backend resources
│   ├── outputs.tf               # State bucket name, DynamoDB table
│   ├── providers.tf             # AWS provider
│   ├── state_storage.tf         # S3 state bucket + DynamoDB lock table
│   └── variables.tf             # Backend naming config
├── site/
│   ├── index.html               # Main portfolio page (hero, projects, skills)
│   ├── error.html               # Styled error page (/error.html)
│   ├── styles.css               # Neon/glassmorphism + starfield styling
│   ├── script.js                # Skills chips + animated stars background
│   └── assets/
│       ├── badges/              # Certification badge PNGs
│       ├── cv/                  # Ruslan_AWS_DevOps_Engineer.pdf
│       └── icons/               # AWS/Terraform/infra icons
├── .gitignore                   # macOS, Terraform, editors, build output
├── .tflint.hcl                  # tflint configuration
├── LICENSE                      # MIT License
└── README.md                    # Main documentation (overview, usage, screenshots)
```

---

## **Core Components**

### **Static Hosting**
- Private S3 bucket used as the origin (no public access)
- CloudFront CDN with Origin Access Control (OAC)
- Custom domain **rusets.com**
- TLS termination via AWS ACM (DNS validation, us-east-1)

---

### **Terraform IaC (Two-Stage Architecture)**

#### **1. `infra-bootstrap/`**
Creates the remote backend used by Terraform:
- S3 bucket for state  
- DynamoDB table for state locking  

Required because Terraform cannot create and consume its backend at the same time.

#### **2. `infra/`**
Deploys the main infrastructure:
- S3 website bucket  
- CloudFront distribution with error pages  
- Route53 hosted zone and DNS records  
- ACM certificate  
- IAM role for GitHub Actions OIDC  
- S3 bucket policy granting CloudFront access  

---

## **GitHub Actions OIDC**

CI/CD uses GitHub → AWS OIDC flow, which removes the need for long-lived AWS access keys.

The IAM role assumed by GitHub Actions allows:
- Uploading new site files to S3  
- Invalidating the CloudFront cache  
- Reading Terraform backend state  

This results in a secure, keyless, fully automated deployment pipeline.

---

## **Security Model**

- The S3 bucket is **fully private**
- CloudFront is the only service allowed to read objects (via OAC)
- No ACLs or public bucket policies
- HTTPS enforced for all traffic
- DNS validation for ACM certificates
- IAM follows least-privilege (after initial debugging stage)
- Infrastructure validated with **checkov**, **tfsec**, and **tflint**

---

## **Request Flow**

### When a user opens rusets.com:
1. Browser sends HTTPS request
2. CloudFront receives the request
3. CloudFront pulls the file from private S3 using OAC
4. The neon starfield portfolio UI is rendered in the browser

### Error Handling
CloudFront serves `/error.html` for:
- 403  
- 404  
- 500  
- 502  

---

## **CI/CD Flow**

### On every push to `main`:
1. GitHub Actions authenticates using OIDC  
2. Files from `site/` sync to S3  
3. CloudFront cache invalidation runs  
4. Updated site becomes globally available within minutes  

---

## **Why Two Terraform Folders?**

- **infra-bootstrap/**  
  Creates the Terraform backend (S3 state + DynamoDB lock). Required once.

- **infra/**  
  Deploys the actual infrastructure: S3 + CloudFront + Route53 + IAM OIDC, error pages, and security configuration.

This pattern ensures a consistent, production-ready Terraform workflow.

---

## **Linting & Validation**

The project is validated using:
- checkov  
- tfsec  
- tflint  

### Some rules are intentionally skipped:
- S3 versioning & access logging (unnecessary for a static site; adds cost)
- DynamoDB PITR & KMS CMK (lock table stores no sensitive data)
- S3 lifecycle policies (not needed for low-volume content)
- CloudFront access logging (extra S3 cost, no debugging value here)

All skipped checks are safe for this project and can be enabled later if needed.

---

## Future Enhancements
- Optional CloudFront access logs  
- Lighthouse performance monitoring  
- Per-branch preview deployments  
- WAF rate-limiting  
- Analytics integrations (CloudWatch, Grafana)

---