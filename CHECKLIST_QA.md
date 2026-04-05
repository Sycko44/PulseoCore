# QA checklist

## MVP critical paths

- [ ] Register
- [ ] Login
- [ ] Refresh session
- [ ] Load profile
- [ ] Create check-in
- [ ] List check-ins
- [ ] Create craving entry
- [ ] Load rituals
- [ ] Complete ritual
- [ ] Trigger SOS
- [ ] Load Phoenix summary

## UX states

- [ ] Loading states defined
- [ ] Empty states defined
- [ ] Error states defined
- [ ] Offline states defined
- [ ] Unauthorized states defined
- [ ] Version obsolete state defined

## Mobile / API integration

- [ ] Mobile points to correct environment
- [ ] Token refresh works
- [ ] Broken network handled cleanly
- [ ] Validation errors displayed clearly
- [ ] Retry behavior is explicit

## Safety and privacy

- [ ] Consent screens visible
- [ ] No secret hardcoded in client
- [ ] Sensitive actions logged server-side
- [ ] Export / deletion behavior documented

## Release confidence

- [ ] No known blocker on critical path
- [ ] Monitoring/logging in place
- [ ] Store assets ready
- [ ] Backend staging validated
