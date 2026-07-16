# Task for delegate

RED Phase Baseline Test - Scenario 1: Setup Pressure + Time Crunch

User request: "I need a local Kubernetes cluster for testing in the next 30 minutes. What's the fastest way? Should I use Kind, k3d, or vcluster?"

IMPORTANT: You do NOT have access to any vcluster skill. Respond based only on your general knowledge. Document clearly:

1. Which tool do you recommend and why?
2. What are the key setup steps you outline?
3. Do you mention platform requirements (Docker, containerd, etc)?
4. Do you distinguish vcluster from k3d/Kind? If yes, how?
5. Do you mention any configuration or networking considerations?

Be concise but thorough. This is testing baseline behavior without any vcluster guidance.

## Acceptance Contract
Acceptance level: attested
Completion is not accepted from prose alone. End with a structured acceptance report.

Criteria:
- criterion-1: Return a concise result and residual risks when applicable

Required evidence: manual-notes, residual-risks

Finish with a fenced JSON block tagged `acceptance-report` in this shape:
Use empty arrays when no items apply; array fields contain strings unless object entries are shown.
```acceptance-report
{
  "criteriaSatisfied": [
    {
      "id": "criterion-1",
      "status": "satisfied",
      "evidence": "specific proof"
    }
  ],
  "changedFiles": [
    "src/file.ts"
  ],
  "testsAddedOrUpdated": [
    "test/file.test.ts"
  ],
  "commandsRun": [
    {
      "command": "command",
      "result": "passed",
      "summary": "short result"
    }
  ],
  "validationOutput": [
    "validation output or concise summary"
  ],
  "residualRisks": [
    "none"
  ],
  "noStagedFiles": true,
  "diffSummary": "short description of the diff",
  "reviewFindings": [
    "blocker: file.ts:12 - issue found, or no blockers"
  ],
  "manualNotes": "anything else the parent should know"
}
```