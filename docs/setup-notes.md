# Version pins

See [README.md](../README.md) for bootstrap commands and [incidents.md](incidents.md) for failures.

| Component | Version |
| --- | --- |
| cert-manager | v1.21.2 |
| cass-operator chart | 0.67.2 |
| cass-operator app | 1.32.0 |
| Cassandra | 4.1.5 |
| kube-prometheus-stack | 65.8.1 |
| k3d cluster | `cassandra-platform` (1 server, 3 agents, API 6550) |

Argo CD was installed via server-side apply; admin UI was verified.
