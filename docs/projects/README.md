# Projects

This directory contains documentation for all Domainic [Github projects](https://github.com/domainic/domainic/projects)
and their development updates. Each project directory includes detailed information about project goals, progress, and
significant changes.

## Active Projects

* [domainic v0.1.0](./domainic-v0.1.0)
  * **December 12, 2024**
    * [domainic-attributer v0.1.0 Released](./domainic-v0.1.0/updates/2024-12-12-01.md)
    * [domainic-attributer v0.2.0 Development Started](./domainic-v0.1.0/updates/2024-12-12-02.md)

## Related Documentation

For milestone-specific documentation, see the [milestones](../milestones) directory.

## Creating Documentation

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

> Note: After generating a project update, you must manually add it as an item in the corresponding GitHub project
> board.
