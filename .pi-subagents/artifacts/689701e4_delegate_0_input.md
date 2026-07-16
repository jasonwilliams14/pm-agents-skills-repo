# Task for delegate

GREEN Phase Test - Scenario 3: Multi-Environment Pressure (WITH vcluster-dev skill)

You now have access to the vcluster-dev skill. Use it to answer:

User request: "We test locally with Docker Desktop, then deploy to GKE. We want to use vcluster for local testing to match cloud behavior. How should we set up vcluster on Docker Desktop, and what configuration ensures parity with GKE?"

IMPORTANT: You have the vcluster-dev skill available. Reference it as needed.

Document your response addressing:
1. Do you provide clear Docker Desktop setup instructions?
2. Do you explain networking configuration for local vcluster?
3. Do you clearly distinguish what HAS parity (APIs) vs what DOESN'T (GCP services)?
4. Do you provide a practical workflow (manifest → local vcluster → GKE)?
5. Does the skill help you avoid the baseline's "configuration gotchas without strategy" problem?

This tests if the skill provides actionable guidance for real-world multi-environment workflows.

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