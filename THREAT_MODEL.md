# terraform-aws-fargate-task threat model

## Overview

Terraform module creates ECS cluster, Fargate task definition/service, execution/task roles and 30-day CloudWatch logs; desired_count defaults to zero. A separate shell helper supports manual tasks (main.tf:26, main.tf:45, variables.tf:34).

| Component | Source |
| --- | --- |
| ECS definition/service/log resources | main.tf:26; main.tf:49; main.tf:62 |
| Task JSON rendering | definition.sh:21 |
| Execution and application roles | iam.tf:1; iam.tf:48 |
| Manual task runner | run_fargate_task.sh:34 |

| Deployment or workflow | Resource or capability | Configuration and precedence | Safe effective value or location | Readers, writers, or recipients | Enforcing control | Evidence or unknowns |
| --- | --- | --- | --- | --- | --- | --- |
| service | Task container | image URL/tag + environment/secrets → definition.sh | ${image_repository_url}:${image_tag}; env values; secret references as valueFrom | Container and ECS agent | Distinct execution/task IAM; caller security groups | definition.sh:26; main.tf:33 |
| service | Logs | cluster_name + name → local.log_group_name | /aws/ecs/${cluster_name}/${name}; stream prefix ecs; retention 30 days | CloudWatch authorized readers and task/agent writers | IAM log grants; retention setting | main.tf:9; main.tf:62; definition.sh:40 |
| Terraform deployment | Service capacity/network | caller vars → ECS service | cluster ${cluster_name}, service ${name}; desired_count 0 default; CPU 256/memory 512 defaults; caller subnets/security groups | ECS/Fargate | AWS ECS APIs, IAM and VPC controls | main.tf:45; variables.tf:22 |
| run_fargate_task.sh NAME ARG | Manual task | ambient AWS identity → NAME-cluster/NAME-service → service configuration | Described task definition/network, command override; reads /aws/ecs/NAME | AWS ECS and operator terminal | Operator IAM; no Terraform role assumption implemented | run_fargate_task.sh:35; run_fargate_task.sh:46; run_fargate_task.sh:83; Helper names and log path differ from module outputs. |

## Threat Model, Trust Boundaries, and Assumptions

Protected assets: Container code, runtime environment/secrets, distinct execution/task credentials, logs, task cost and network access (main.tf:11, main.tf:33).

The module separates ECS agent execution identity from application task identity. The execution role grants ECR pull/authentication and log writes on *, while the task role grants log writes on *. Exported role IDs let a caller attach additional policies; secrets map entries only become ECS valueFrom references and do not create secret-retrieval IAM grants (iam.tf:22, iam.tf:72, definition.sh:27, outputs.tf:26).

Caller image and configuration become a single essential container. Environment contains literal values; secrets remain references in the task definition and are resolved by ECS under externally supplied permission. Task networking is caller-owned through subnets/security groups. The module defines no listener, route, load balancer or public endpoint, and creates no Cloudflare resources (definition.sh:31, main.tf:56).

Deploying the service and manually executing a task are distinct authorizations. desired_count zero prevents continuously maintained service tasks but does not disable a permitted run-task call. The helper uses ambient AWS CLI credentials and service-derived configuration. It assumes NAME-cluster/NAME-service and /aws/ecs/NAME, whereas this module names cluster from cluster_name, service from name and logs from both. That discrepancy must remain visible in operational instructions (variables.tf:34, run_fargate_task.sh:35, run_fargate_task.sh:83, main.tf:9, main.tf:45).

The supplied example uses a private subnet/NAT and a hello-world image; it does not establish production network exposure. The module supplies thirty-day log retention, but caller-controlled log content and external access policies determine confidentiality. The README recommends the manual helper and advertises secret injection; both require the caller obligations described above. No real secret, invocation policy or application authorization implementation was inspected (examples/python-hello-world/vpc.tf:14, main.tf:62, README.md:15, README.md:30).

## Attack Surface, Mitigations, and Attacker Stories

These are prioritized hypotheses for review, not confirmed vulnerabilities. Each depends on the stated actor and deployment prerequisites.

| Priority | Scenario and capability gain | Prerequisites | Impact | Existing controls | Mitigation | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| P1 | A substituted image could execute with the configured task role and injected secrets. | An attacker can publish/retag the selected image and a deployment or run resolves it. | Unauthorized workload actions or secret disclosure within granted task authority. | ECR pull uses execution role; application role is separate; image publisher IAM lies outside module. | Bind approved image artifacts and limit task/secret permissions. | definition.sh:29; main.tf:33; iam.tf:48 |
| P2 | Caller-supplied secret references could receive incorrect retrieval grants or unintended recipients. | External caller attaches execution-role policies and supplies sensitive references. | Wrong secret injection or denied startup. | Module passes valueFrom and does not grant retrieval automatically. | Match retrieval IAM and KMS permissions to approved references; avoid literal secrets in plain environment. | definition.sh:26; iam.tf:32; outputs.tf:26 |
| P2 | Manual helper naming mismatch could select an unrelated existing service or fail execution/log retrieval. | An operator invokes helper and matching legacy-named resources exist or expected resources do not. | Wrong task runs, misleading diagnostics or job interruption. | AWS IAM still controls describe/run; helper reads configuration from selected service. | Use verified module outputs and explicit target binding in operational workflow. | run_fargate_task.sh:35; run_fargate_task.sh:46; main.tf:45 |
| P3 | A principal with manual execution permission could accumulate tasks despite zero desired_count. | Actor holds run-task and necessary role/network authority outside this module. | Resource cost or workload duplication. | CPU/memory defaults and service desired_count are explicit; they are not global run-task quotas. | Constrain execution permission, concurrency and job semantics at real call sites. | variables.tf:22; variables.tf:34; run_fargate_task.sh:46 |

## Severity Calibration (Critical, High, Medium, Low)

**Critical.** Critical requires a verified deployment/secret compromise with exceptional downstream consequence. Merely defining separate ECS roles or using a mutable image tag does not establish this.

**High.** High fits image substitution reaching sensitive task credentials or a wrongly authorized manual task that can materially mutate protected systems. Task permissions and the real image/runner actor must be known.

**Medium.** Medium fits bounded secret exposure, wrong-service execution, or material job failure. The naming mismatch is a source-established operational discrepancy; security impact requires a concrete alternate target and permissions.

**Low.** Low fits missing example resources, rejected secret access or failed log lookup without material impact. desired_count zero is not advertised as a denial of all manual AWS execution.

This is an offline, source-backed architecture review. No application execution, cloud state inspection or vulnerability validation was performed.

Repository: https://github.com/mathspace/terraform-aws-fargate-task
Version: d4cd2740fcf4ff9c6d4e9a8aa049acd3e73bab80
