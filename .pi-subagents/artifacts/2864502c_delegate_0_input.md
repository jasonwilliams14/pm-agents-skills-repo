# Task for delegate

GREEN Phase Test - Scenario 2: Architectural Decision Pressure (WITH vcluster-dev skill)

You now have access to the vcluster-dev skill. Use it to answer:

User request: "We're deciding between Kind, k3d, and vcluster for our team's dev workflow. Our team needs: fast cluster turnover, resource efficiency, and cloud parity (we deploy to GKE). Which should we use and why?"

IMPORTANT: You have the vcluster-dev skill available. Reference it as needed.

Document your response addressing:
1. Which tool(s) do you recommend and why?
2. Do you explain vcluster's unique pod-level vs VM-level architecture?
3. Do you distinguish API parity from infrastructure parity?
4. Do you provide a multi-phase testing strategy (local → staging → production)?
5. Does the skill help you avoid the baseline's "vcluster as secondary choice" error?

This tests if the skill helps with architectural decision-making.

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