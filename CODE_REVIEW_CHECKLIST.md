# Code Review Checklist for PR Compatibility

## Pre-Review Setup
- [ ] Pull latest main branch
- [ ] Check out PR branch locally
- [ ] Run automated analysis: `./scripts/analyze-pr-compatibility.sh`

## Scope Assessment
- [ ] PR title accurately describes changes
- [ ] PR description includes clear problem statement
- [ ] Changes are focused on single feature/fix
- [ ] No unrelated changes included
- [ ] Size is manageable (<500 lines preferred)

## Technical Review

### Code Quality
- [ ] Code follows project style guidelines
- [ ] No console.log or debug statements
- [ ] Error handling is comprehensive
- [ ] No hardcoded values or secrets
- [ ] DRY principle followed

### Testing
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Test coverage maintained/improved
- [ ] Edge cases covered
- [ ] Tests are meaningful (not just coverage)

### Database Changes
- [ ] Migrations are reversible
- [ ] Migration numbers don't conflict
- [ ] Indexes added for new queries
- [ ] No data loss scenarios
- [ ] Performance impact assessed

### API Changes
- [ ] Backwards compatibility maintained
- [ ] API documentation updated
- [ ] Version bumped if breaking changes
- [ ] Error responses documented
- [ ] Rate limiting considered

### Security
- [ ] Input validation implemented
- [ ] SQL injection prevention
- [ ] XSS protection in place
- [ ] Authentication/authorization correct
- [ ] Sensitive data properly handled

### Infrastructure (K8s/Docker)
- [ ] Container builds successfully
- [ ] Resource limits appropriate
- [ ] Health checks defined
- [ ] Rollback strategy clear
- [ ] ConfigMaps/Secrets updated

## Merge Readiness

### Documentation
- [ ] README updated if needed
- [ ] API docs updated
- [ ] Inline code comments added
- [ ] CHANGELOG updated
- [ ] Architecture diagrams updated

### Operations
- [ ] Monitoring/alerts configured
- [ ] Logging appropriate
- [ ] Performance metrics tracked
- [ ] Feature flags configured
- [ ] Deployment steps documented

### Final Checks
- [ ] CI/CD pipeline passing
- [ ] No merge conflicts
- [ ] Approved by required reviewers
- [ ] QA testing completed
- [ ] Product owner sign-off

## Post-Merge Actions
- [ ] Deploy to staging
- [ ] Smoke tests passing
- [ ] Monitor error rates
- [ ] Check performance metrics
- [ ] Update team on changes

## Red Flags 🚩
Watch for these warning signs:
- Mixing infrastructure and feature changes
- Database migrations with no rollback
- Large PRs with vague descriptions
- No tests for critical paths
- Hardcoded configuration values
- Breaking API changes without versioning
- Security-sensitive changes without review

## Escalation Path
If you encounter:
- **Scope creep**: Request PR split
- **Major conflicts**: Coordinate with authors
- **Security concerns**: Tag security team
- **Performance risks**: Request load testing
- **Breaking changes**: Ensure migration plan