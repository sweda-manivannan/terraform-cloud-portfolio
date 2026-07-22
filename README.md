\# Resilient Cloud Infrastructure for a Lab Data Platform



Infrastructure-as-Code project simulating a real-world problem: replacing a

small biotech/pharma lab's fragile, single-server internal data-tracking

setup with a resilient, cost-optimized, auto-scaling AWS architecture.





\## About This Project



This is a self-directed portfolio project modeled on a realistic operational

problem, not a client engagement. Small biotech/pharma labs frequently run

internal tools (sample tracking, experiment logging, results dashboards) on

a single fragile server with no backups, no scaling, and no monitoring —

a genuine failure risk when active experiment data is on the line.



I designed and built this infrastructure to solve that scenario using

production-grade practices: least-privilege IAM, network isolation,

automated backups, and cost-aware resource choices.



\## Problem → Solution



| Problem (typical small-lab setup) | Solution in this project |

|---|---|

| Single server, no redundancy | Auto Scaling Group across multiple instances |

| No traffic handling for usage spikes | Application Load Balancer distributing traffic |

| Data loss risk (no backups) | RDS with automated backups, isolated in a private subnet |

| No visibility if system goes down | CloudWatch monitoring and alerting |

| Manual, error-prone deployments | Infrastructure fully defined and deployed via Terraform |

| Unpredictable or wasteful cloud costs | Right-sized resources + S3 lifecycle policies for cost control |



\## Status: In Progress



\- \[x] Terraform pipeline validated (init/plan/apply/destroy)

\- \[ ] VPC with public and private subnets

\- \[ ] Compute layer (Auto Scaling Group + Application Load Balancer)

\- \[ ] Database layer (RDS in private subnet, automated backups)

\- \[ ] Monitoring and alerting (CloudWatch)

\- \[ ] CI/CD pipeline (GitHub Actions running Terraform plan/apply)



\## Tech Stack

Terraform · AWS (VPC, EC2, RDS, S3, CloudWatch) · GitHub Actions (planned)



\## Author

Sweda Manivannan

