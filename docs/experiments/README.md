# Domainic Experiments Documentation

Welcome to the Domainic Experiments documentation! This directory contains comprehensive documentation for our
experimental releases - gems that are pushing the boundaries of what's possible with domain-driven design in Ruby. Think
of this space as the laboratory notebook where we document our explorations, gather feedback, and evolve our
understanding of what makes great domain-driven design tools.

## What are Experiments

Unlike traditional alpha or beta releases, experiments represent ideas and implementations that are in an early,
exploratory phase. We release these as gems with alpha versioning, but we treat them as experiments to emphasize their
evolving nature. Each experiment might change significantly based on community feedback, real-world usage patterns, and
our growing understanding of developer needs.

Each experimental release is:

* **Exploratory** - Testing new approaches and ideas
* **Iterative** - Evolving based on feedback and learnings
* **Collaborative** - Shaped by community input and real-world usage
* **Focused** - Targeting specific aspects of domain-driven design

## Current Experiments

### Domainic::Type v0.1.0 Alpha

**Status:** Active  
**Started:** December 2024  
**Gem:** `domainic-type`

A flexible type validation system for Ruby, offering composable, readable type constraints with elegant error messages.
This experiment explores how we can bring powerful yet developer-friendly type validation to Ruby while maintaining the
language's expressiveness and elegance.

[Learn more about Domainic::Type v0.1.0 Alpha](./domainic-type-v0.1.0-alpha/README.md)

## Documentation Structure

Each experiment's documentation follows this structure:

```markdown
experiments/
├── README.md                 # This file
└── {experiment_name}/        # e.g., type/
    ├── README.md             # Experiment overview and installation
    ├── KNOWN_ISSUES.md       # Current limitations and known issues
    ├── CHANGELOG.md          # Changes between versions
    ├── TROUBLESHOOTING.md    # Common issues and solutions
    └── EXAMPLES.md           # Detailed usage guides
```

## Important Notes

* Documentation here covers experimental gem releases
* APIs may evolve or be completely redesigned based on feedback
* Documentation will be frequently updated
* Your feedback is essential and valued!

## Versioning

Our experimental gems use alpha versioning with this pattern:

* Target version with alpha tag and build numbers: `{target}-alpha.{alpha}.{build}`
* Alpha versions increment: `-alpha.1.0.0` → `-alpha.2.0.0`
* Experiment completes at target version without tags
* Released versions follow [BreakVer](https://www.taoensso.com/break-versioning)

Example for 0.1.0:

```ruby
'0.1.0-alpha.1.0.0' # First alpha
'0.1.0-alpha.2.0.0' # Second alpha
'0.1.0'             # Completed experiment
```

## Get Involved

We'd love to hear your thoughts, ideas, and experiences with these experiments! Here's how you can get involved:

1. Install the experimental gems you're interested in
2. Try them out in non-production projects
3. Join discussions in our issue tracker
4. Share your use cases and requirements
5. Provide feedback on what works and what doesn't

Remember, there are no "wrong" answers in experiments * every piece of feedback helps us learn and improve!

## Historical Experiments

> [!NOTE]
> This section will be populated as experiments graduate from experimental status or are archived.

## Feedback Guidelines

When providing feedback on experiments, consider:

* What worked well?
* What was confusing or unclear?
* Are error messages helpful and clear?
* What features are missing?
* What would make the gem more useful?
* Are there specific use cases not well supported?

Please include code examples when possible to illustrate your points.
