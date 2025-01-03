# Projects

This directory tracks active initiatives and development efforts in the Domainic ecosystem. Projects are how we organize
and track major development efforts, serving as:

1. Collection of related epics/stories for a specific initiative
2. Iteration planning and scheduling
3. Progress and milestone tracking

Each project directory contains detailed documentation about goals, progress updates, and significant changes. Projects
are linked to [Github project boards](https://github.com/domainic/domainic/projects) for task management.

## Active Projects

* [domainic v0.1.0](./domainic-v0.1.0/README.md)

## Related Documentation

For milestone-specific documentation, see the [milestones](../milestones) directory.

## Quick Actions

### New Project Documentation

To create documentation for a new project:

```bash
bin/dev generate project_doc <PROJECT_NAME> <PROJECT_GITHUB_ID>
```

### Project Updates

To create a new project update:

```bash
bin/dev generate project_update_doc <PROJECT_NAME>
```

> [!NOTE]
> After generating a project update, you must manually add it as an item in the corresponding GitHub project board.
