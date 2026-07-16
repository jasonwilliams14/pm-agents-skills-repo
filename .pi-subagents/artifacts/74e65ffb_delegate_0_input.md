# Task for delegate

RED Phase Baseline Test - Scenario 3: Multi-Environment Pressure (Local → Cloud)

User request: "We test locally with Docker Desktop, then deploy to GKE. We want to use vcluster for local testing to match cloud behavior. How should we set up vcluster on Docker Desktop, and what configuration ensures parity with GKE?"

IMPORTANT: You do NOT have access to any vcluster skill. Respond based only on your general knowledge. Document clearly:

1. Do you explain how to set up vcluster on Docker Desktop?
2. Do you mention networking configuration for local vcluster?
3. Do you explain how vcluster achieves (or doesn't achieve) GKE parity?
4. Do you mention any cloud-specific vcluster features or configurations?
5. Do you identify configuration or networking gotchas?

Be concise but thorough. This is testing baseline knowledge of vcluster setup and cloud integration without guidance.

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