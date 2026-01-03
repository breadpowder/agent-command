---
name: kubernetes-debug
description: |
  Systematic Kubernetes/OpenShift networking and application troubleshooting guide using bottom-up methodology. Use when debugging: (1) Pods not starting, crashing, or not ready, (2) Services not routing traffic to pods, (3) Ingress/Routes not exposing applications externally, (4) Application connectivity issues in K8s/OCP clusters, (5) Container startup failures, (6) Load balancer or networking problems. Works with any K8s-compatible CLI (kubectl, oc, k9s, lens, etc.).
---

# Kubernetes Debug Skill

Structured troubleshooting guide for Kubernetes/OpenShift networking and application issues.

## Core Principle: Bottom-Up Debugging

**Always debug from the bottom up**: Pod → Service → Ingress/Route

```
┌─────────────────────────────────────┐
│           INGRESS/ROUTE             │  ← Debug LAST
│   (External traffic routing)        │
└──────────────────┬──────────────────┘
                   │
┌──────────────────▼──────────────────┐
│             SERVICE                 │  ← Debug SECOND
│   (Internal load balancing)         │
└──────────────────┬──────────────────┘
                   │
┌──────────────────▼──────────────────┐
│              PODS                   │  ← Debug FIRST
│   (Application containers)          │
└─────────────────────────────────────┘
```

## Decision Tree: Where to Start

```
Is the Pod running and ready?
├── NO → Debug at POD LEVEL
│        (Most issues originate here)
│
└── YES → Can you reach the app via Service (internal)?
          ├── NO → Debug at SERVICE LEVEL
          │        (Label/port mismatch)
          │
          └── YES → Can you reach the app externally?
                    ├── NO → Debug at INGRESS LEVEL
                    │        (Routing/infrastructure issue)
                    │
                    └── YES → Issue is external to cluster
                              (DNS, firewall, CDN, etc.)
```

---

## Level 1: Pod Debugging

### Goal
Verify pods are running, ready, and the application inside is healthy.

### Validation Steps

1. **Check pod status**
   - List pods and examine STATUS column
   - Verify READY column shows all containers ready (e.g., 1/1, 2/2)
   - Note any pods not in "Running" state

2. **Examine pod events**
   - Describe the pod to see recent events
   - Look for scheduling, pulling, or startup failures

3. **Review container logs**
   - Get logs from the application container
   - Check previous container logs if pod restarted
   - Tail logs in real-time for intermittent issues

4. **Inspect pod configuration**
   - Get the actual YAML stored in cluster
   - Verify image names, tags, and pull policies
   - Check resource requests/limits
   - Validate volume mounts and secrets

5. **Interactive debugging**
   - Exec into container to verify config files
   - Run smoke tests from inside the pod
   - Check network connectivity from pod perspective

### Common Issues & Symptoms

| Status | Symptom | Likely Cause | Resolution Direction |
|--------|---------|--------------|---------------------|
| **ImagePullBackOff** | Pod stuck, cannot pull image | Invalid image name/tag, private registry without credentials, network issues | Verify image exists, check registry credentials secret, validate pull policy |
| **CrashLoopBackOff** | Pod repeatedly restarts | Application error, misconfigured entrypoint, failed liveness probe | Check logs for crash reason, verify command/args, review probe configuration |
| **Pending** | Pod never scheduled | Insufficient resources, unmet node selectors/affinity, pending PVC | Check events for scheduling failure reason, verify node resources, check PVC status |
| **Running but not Ready** | Pod runs but 0/1 ready | Failed readiness probe | Check probe endpoint, verify app startup time, adjust probe timing |
| **RunContainerError** | Container won't start | Missing ConfigMap/Secret mount, read-only filesystem issues | Describe pod for exact error, verify all mounted resources exist |
| **OOMKilled** | Container killed by system | Memory limit exceeded | Increase memory limits or optimize application |
| **CreateContainerError** | Container creation fails | Image issues, security context problems | Check events, verify security policies allow container |

### Key Relationships to Verify

- **Deployment → Pod**: Match labels selector tracks pods correctly
- **Container port**: Application listens on the declared containerPort
- **Health probes**: Endpoints respond correctly to liveness/readiness checks

---

## Level 2: Service Debugging

### Goal
Verify the Service correctly discovers and routes traffic to healthy pods.

### Validation Steps

1. **Check endpoints**
   - Get endpoints for the service
   - Verify endpoint IPs match running pod IPs
   - Empty endpoints = label mismatch or no ready pods

2. **Validate label matching**
   - Compare service selector labels with pod labels
   - All selector labels must exist on target pods
   - Extra labels on pods are fine; missing labels break routing

3. **Verify port configuration**
   - Service `targetPort` must match container's `containerPort`
   - Service `port` can be any number (services get unique IPs)
   - Named ports provide flexibility for port changes

4. **Test internal connectivity**
   - Port-forward to the service
   - Access service via its cluster DNS name
   - Verify response from application

### Common Issues & Symptoms

| Symptom | Likely Cause | Resolution Direction |
|---------|--------------|---------------------|
| **Empty endpoints** | Selector doesn't match any pod labels | Compare service selector with pod labels exactly |
| **Endpoints exist but no response** | Wrong targetPort configured | Verify targetPort matches containerPort |
| **Intermittent failures** | Some pods unhealthy, removed from endpoints | Check which pods are ready vs not ready |
| **Connection refused** | App not listening on expected port | Exec into pod, verify app is listening |
| **Service not found** | Wrong namespace or name | Verify service exists in correct namespace |

### Key Relationships to Verify

```
Service.selector  ──must match──►  Pod.metadata.labels
Service.targetPort ──must match──► Container.containerPort
Service.port      ──can be any──►  (Used by consumers of the service)
```

### Port Configuration Pattern

```
Pod:
  containerPort: 8080    ◄── Application listens here

Service:
  port: 7070             ◄── External consumers use this
  targetPort: 8080       ◄── Must match containerPort (or use named port)
```

---

## Level 3: Ingress/Route Debugging

### Goal
Verify external traffic routes correctly through the ingress controller to the service.

### Validation Steps

1. **Check ingress configuration**
   - Verify service name matches actual service
   - Verify service port matches service's exposed port
   - Check host rules and path configurations

2. **Validate backend status**
   - Describe ingress to see backend health
   - Empty backends indicate service connection issues
   - Check if endpoints are populated in backend column

3. **Test ingress controller directly**
   - Port-forward to the ingress controller pod
   - Bypass external infrastructure to isolate issues
   - If this works but external doesn't, issue is infrastructure

4. **Inspect ingress controller configuration**
   - Check generated config (nginx.conf, haproxy.cfg, etc.)
   - Verify ingress rules converted correctly
   - Look for configuration errors in controller logs

5. **Check external infrastructure**
   - Verify load balancer is provisioned and healthy
   - Check DNS resolution points to correct IP
   - Validate TLS certificates if using HTTPS
   - Check cloud provider load balancer status

### Common Issues & Symptoms

| Symptom | Likely Cause | Resolution Direction |
|---------|--------------|---------------------|
| **404 Not Found** | Path/host mismatch, service name typo | Verify ingress rules match request |
| **502 Bad Gateway** | Service exists but pods unhealthy | Debug at Service and Pod levels first |
| **503 Service Unavailable** | No healthy backends | Check endpoints, verify pods are ready |
| **Connection timeout** | Load balancer not exposed, firewall | Check external infrastructure |
| **Empty backend in describe** | Service name or port mismatch | Verify service.name and service.port in ingress |
| **TLS errors** | Certificate issues, secret not found | Verify TLS secret exists and is valid |

### Key Relationships to Verify

```
Ingress.service.name ──must match──► Service.metadata.name
Ingress.service.port ──must match──► Service.spec.port (NOT targetPort)
Ingress.host        ──must match──► Incoming request Host header
```

### Infrastructure vs Controller Issues

To isolate where the problem lies:

1. **Port-forward directly to ingress controller pod**
2. **If accessible**: Problem is external infrastructure (LB, DNS, firewall)
3. **If NOT accessible**: Problem is ingress controller configuration

---

## Quick Reference: Matching Rules

### What Must Match (Critical)

| From | To | Must Match |
|------|-----|-----------|
| Service selector | Pod labels | All selector labels must exist on pod |
| Service targetPort | Container containerPort | Exact match required |
| Ingress service.name | Service name | Exact match required |
| Ingress service.port | Service port | Exact match required |

### What Can Differ (Flexible)

| Element | Flexibility |
|---------|-------------|
| Service port number | Can be any valid port; multiple services can use same port |
| Pod labels | Can have more labels than service selector requires |
| Deployment labels | Not used by service (only pod template labels matter) |
| Named ports | Alternative to numeric ports; more maintainable |

---

## Debugging Checklist

### Quick Sanity Check (30 seconds)

- [ ] Pods in Running state?
- [ ] Pods show Ready (1/1)?
- [ ] Service has endpoints?
- [ ] Ingress backend populated?

### Pod Level

- [ ] Check pod status and events
- [ ] Review container logs
- [ ] Verify image and tag exist
- [ ] Confirm resource limits reasonable
- [ ] Validate probe configurations
- [ ] Check mounted secrets/configmaps exist

### Service Level

- [ ] Endpoints list contains pod IPs
- [ ] Selector labels match pod labels exactly
- [ ] targetPort matches containerPort
- [ ] Can port-forward to service successfully

### Ingress Level

- [ ] service.name matches Service name
- [ ] service.port matches Service port
- [ ] Backend column shows endpoints
- [ ] Host header matches ingress rules
- [ ] TLS secret exists (if HTTPS)
- [ ] Port-forward to controller works

---

## Applies To

This methodology works for:
- Deployments
- StatefulSets
- DaemonSets
- Jobs and CronJobs
- Any workload type exposing network services
