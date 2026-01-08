# COMPLIANCE — Release & Contribution Checklist

## Licensing
- [ ] LICENSE contains full AGPL-3.0 text (not a stub)
- [ ] NOTICE present and preserved
- [ ] CITATION.cff present

## Third-party
- [ ] Dependency licenses reviewed and compatible with AGPL
- [ ] Models/datasets provenance documented

## Privacy (biometrics)
- [ ] No raw frames uploaded by default
- [ ] No sensitive logs (frames/embeddings/masks)

## Security
- [ ] No secrets committed
- [ ] Least-privilege rules for any backend

## Build hygiene
- [ ] CI runs checks
- [ ] Deterministic-enough builds (pinned deps where feasible)
