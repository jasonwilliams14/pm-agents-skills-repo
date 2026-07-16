# Task for delegate

GREEN Phase Test - Scenario 1: Setup Pressure + Time Crunch (WITH vcluster-dev skill)

You now have access to the vcluster-dev skill. Use it to answer:

User request: "I need a local Kubernetes cluster for testing in the next 30 minutes. What's the fastest way? Should I use Kind, k3d, or vcluster?"

IMPORTANT: You have the vcluster-dev skill available. Reference it as needed.

Document your response addressing:
1. Which tool do you recommend and why?
2. Does your recommendation differ from the baseline (which favored k3d)?
3. Do you explain vcluster's 5-10s startup advantage?
4. Do you mention when vcluster is preferable to k3d?
5. Do you provide concrete setup steps?

This tests if the skill helped you make better architectural decisions.

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