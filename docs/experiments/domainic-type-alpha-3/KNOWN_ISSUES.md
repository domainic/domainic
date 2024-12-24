# Known Issues

This document tracks known issues in the domainic-type alpha 3 experiment. Issues will be added as they're discovered
through testing and feedback.

## Current Issues

### Verbose Error Messages Display All Constraint Failures

**Description**: When a type fails validation, the error message shows failures for ALL constraints, even those that
actually passed. This can make error messages unnecessarily verbose and potentially confusing.

**Steps to Reproduce**:

```ruby
username = _String
  .being_lowercase
  .being_alphanumeric
  .having_size_between(3, 20)
  .not_matching(/^admin/i)

username.validate!('admin01')
# => TypeError: Expected String(being lower case, being only alphanumeric 
# characters, matching /^admin/i, having size greater than or equal to 3 
# and less than or equal to 20), but got String(being not lower case, 
# being non-alphanumeric characters, does not match /^admin/i, having size 7)
```

**Expected Behavior**: Error message should only show the constraints that actually failed.

* **Status**: investigating
* **Reported**: 2023-12-23
* **Related Issues**: 
  * initially reported in [#132](https://github.com/domainic/domainic/issues/132#issuecomment-2560546327)
  * tracked in [#138](https://github.com/domainic/domainic/issues/138)

