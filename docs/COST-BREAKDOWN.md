# Cost Breakdown

Approximate monthly cost in `us-east-1`, assuming low traffic.

| Resource | Quantity | Unit cost | Monthly |
|---|---|---|---|
| EKS control plane | 1 | $0.10/hr | ~$73 |
| EC2 nodes (t3.medium, on-demand) | 2 | $0.0416/hr | ~$60 |
| NAT Gateway (single) | 1 | $0.045/hr | ~$32 |
| NAT data processing | varies | $0.045/GB | $5–20 |
| Application Load Balancer | 1 | $0.0225/hr + LCU | ~$16 |
| ALB LCU charges | varies | $0.008/LCU-hr | $1–10 |
| Secrets Manager | 1 secret | $0.40/secret/mo + API | ~$0.50 |
| CloudWatch Logs (control plane) | 5 GB ingest | $0.50/GB | ~$2.50 |
| ECR storage | 1 GB | $0.10/GB | ~$0.10 |
| KMS keys | 3 | $1/key | $3 |
| EBS root volumes (20 GB × 2) | 2 | $0.10/GB | ~$4 |
| **Total** | | | **~$190–215/mo** |

## Optimization tips

- **Drop NAT Gateway** if your nodes don't need outbound internet (use VPC endpoints for S3/ECR/STS only) → saves ~$32
- **Spot instances** for non-prod node groups → 60–80% off the EC2 line
- **Fargate profiles** for low-traffic workloads — no idle node cost
- **Reduce log retention** in CloudWatch to 7 days
- **Auto-scale to 0** by spinning down the node group nightly via EventBridge + Lambda
- **Single AZ** if you genuinely don't need HA (saves NAT + cross-AZ data transfer)

For dev/test, the cheapest config (Fargate + private workloads only + no NAT) runs ~$80/mo.
