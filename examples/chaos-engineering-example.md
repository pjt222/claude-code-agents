# Chaos Engineering Example 💥

Demonstrates using the `chaos-engineer` agent to design and execute resilience experiments.

## Scenario

You're preparing for a chaos engineering gameday to test your e-commerce platform's resilience. You need to design experiments that validate the system can handle various failure scenarios.

## Initial Prompt

```
Design a chaos experiment to test our checkout service's resilience.
The service runs on Kubernetes with 5 replicas and connects to:
- PostgreSQL database (RDS Multi-AZ)
- Redis cache cluster
- Payment gateway API (third-party)

I want to know what happens when we lose 50% of our pods.
```

## Expected Behavior

The chaos-engineer agent will:

1. **Define** a clear hypothesis about expected behavior
2. **Identify** steady state metrics to measure
3. **Design** the failure injection approach
4. **Create** abort conditions for safety
5. **Provide** experiment configuration (Litmus/Chaos Toolkit)

## Sample Output

```markdown
## Chaos Experiment: Checkout Service Pod Failure 🎯

### Hypothesis

**Given**: Checkout service processes ~500 req/s with p99 latency < 200ms
**When**: 50% of checkout-service pods are terminated (2-3 of 5 pods)
**Then**: Service maintains > 95% success rate with p99 latency < 1s until HPA scales up replacements (< 60s)

### Steady State Definition

| Metric | Normal Value | Acceptable During Chaos |
|--------|--------------|------------------------|
| Request Success Rate | > 99.5% | > 95% |
| P99 Latency | < 200ms | < 1000ms |
| Pod Count | 5 | >= 2 |
| Error Rate | < 0.5% | < 5% |

### Blast Radius

- **Affected**: checkout-service pods only
- **Protected**: Database, Redis, Payment Gateway unchanged
- **Duration**: 5 minutes maximum
- **Environment**: Staging (recommend production after staging success)

### Litmus Chaos Experiment

```yaml
apiVersion: litmuschaos.io/v1alpha1
kind: ChaosEngine
metadata:
  name: checkout-pod-failure
  namespace: staging
spec:
  engineState: 'active'
  appinfo:
    appns: 'staging'
    applabel: 'app=checkout-service'
    appkind: 'deployment'
  chaosServiceAccount: litmus-admin
  experiments:
    - name: pod-delete
      spec:
        components:
          env:
            - name: TOTAL_CHAOS_DURATION
              value: '300'        # 5 minutes
            - name: CHAOS_INTERVAL
              value: '60'         # Kill pods every 60s
            - name: FORCE
              value: 'false'      # Graceful termination
            - name: PODS_AFFECTED_PERC
              value: '50'
        probe:
          - name: checkout-health
            type: httpProbe
            httpProbe/inputs:
              url: http://checkout-service/health
              expectedResponseCode: "200"
            mode: Continuous
            runProperties:
              probeTimeout: 5
              interval: 5
```

### Abort Conditions (Auto-Rollback)

Experiment automatically stops if:
- Error rate exceeds 10% for 30 seconds
- P99 latency exceeds 2 seconds
- Pod count drops below 2
- Health probe fails 3 consecutive times

### Pre-Experiment Checklist

- [ ] Staging environment mirrors production configuration
- [ ] Monitoring dashboards open and visible
- [ ] On-call engineer aware and available
- [ ] Rollback procedure documented and tested
- [ ] Slack channel #chaos-experiments notified
- [ ] HPA (Horizontal Pod Autoscaler) configured and working

### Expected Observations

**0-30 seconds**:
- 2-3 pods terminated
- Brief latency spike as connections redistribute
- HPA detects reduced capacity

**30-60 seconds**:
- HPA triggers scale-up
- New pods starting (ContainerCreating)
- Latency stabilizing at elevated level

**60-120 seconds**:
- New pods become Ready
- Traffic rebalances across all pods
- Metrics returning to steady state

### Success Criteria

✅ **Pass** if:
- No user-facing errors (checkout failures)
- Recovery time < 90 seconds
- Data consistency maintained (no duplicate orders)
- Alerts fired appropriately

❌ **Fail** if:
- Cascading failures to other services
- Data corruption or lost transactions
- Recovery time > 3 minutes
- No alerts triggered despite degradation

### Post-Experiment Actions

1. **Document findings** in chaos experiment log
2. **Create tickets** for any discovered weaknesses
3. **Update runbooks** if recovery procedure was unclear
4. **Schedule follow-up** experiment after fixes
```

## Tips for Chaos Engineering

1. **Start in Staging**: Always validate experiments in non-production first
2. **Small Blast Radius**: Begin with minimal impact, expand gradually
3. **Have Abort Triggers**: Automated rollback prevents extended outages
4. **Communicate Widely**: Everyone should know an experiment is running
5. **Learn from Failures**: The goal is to find weaknesses, not prove resilience

## Chaos Engineering Maturity Levels

| Level | Description | This Experiment |
|-------|-------------|-----------------|
| 1 | Manual experiments in staging | ✅ Starting here |
| 2 | Automated experiments in staging | Next step |
| 3 | Automated experiments in production | After validation |
| 4 | Continuous chaos in production | Advanced goal |

## Related Agents

- [code-reviewer](../.claude/agents/code-reviewer.md) - For reviewing chaos experiment code
- [security-analyst](../.claude/agents/security-analyst.md) - For security implications
