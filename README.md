# Kubernetes Monitoring Stack

This repository contains a Terraform configuration to deploy a complete monitoring stack on Kubernetes in AWS, focused on the eu-north-1 region. The stack includes:

- Prometheus
- Grafana
- Node Exporter
- Kube State Metrics
- AWS CloudWatch Exporter
- Alertmanager

## Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform installed (version 1.0+)
- kubectl installed and configured to connect to your Kubernetes cluster
- Helm 3 installed

## Deployment Instructions

1. Clone this repository:
```
git clone https://github.com/pooyanazad/k8s-monitoring-stack.git
cd k8s-monitoring-stack
```

2. Initialize Terraform:
```
terraform init
```

3. Review the Terraform plan:
```
terraform plan
```

4. Apply the configuration:
```
terraform apply
```

5. Access Grafana:
```
# Get the Grafana admin password
kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode

# Port-forward to access Grafana
kubectl port-forward --namespace monitoring svc/grafana 3000:80
```

Then open your browser and navigate to http://localhost:3000

## Customization

- Update the `cloudwatch-exporter-config.yml` file to monitor additional AWS services
- Modify the `alertmanager.yml` file to configure different notification channels
- Add or modify dashboard configurations in `grafana-dashboards.yaml`
- Update alert rules in `prometheus-rules.yml`

## File Structure

- `main.tf`: Main Terraform configuration file
- `cloudwatch-exporter-config.yml`: Configuration for AWS CloudWatch metrics to collect
- `alertmanager.yml`: Alertmanager configuration with notification settings
- `grafana-dashboards.yaml`: Grafana dashboard configurations
- `prometheus-rules.yml`: Prometheus alerting rules

## Important Notes

- The default Grafana admin password is set to `admin` in the Terraform code. Change this for production use.
- Update the Slack webhook URL in `alertmanager.yml` before deploying.
- Make sure your AWS credentials have permissions to read CloudWatch metrics.
