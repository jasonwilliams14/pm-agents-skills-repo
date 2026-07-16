# Task for delegate

RED Phase Baseline Test - Scenario 2: Architectural Decision Pressure

User request: "We're deciding between Kind, k3d, and vcluster for our team's dev workflow. Our team needs: fast cluster turnover, resource efficiency, and cloud parity (we deploy to GKE). Which should we use and why?"

IMPORTANT: You do NOT have access to any vcluster skill. Respond based only on your general knowledge. Document clearly:

1. Which tool(s) do you recommend and why?
2. Do you explain what makes vcluster unique compared to Kind and k3d?
3. Do you mention vcluster's architecture (pod-level vs VM-level isolation)?
4. Do you discuss cloud parity and how vcluster relates to GKE?
5. Do you mention any gotchas or configuration issues with your recommendation?

Be concise but thorough. This is testing baseline architectural reasoning without any vcluster guidance.

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