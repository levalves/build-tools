# Init Template

This library helps to do a initial setup in a project created from github's template repository.

Available methods:
- [set_default_values](#set_default_values)

<a name="set_default_values"></a>

## set_default_values

This lib uses a configuration file (`init_template.csv`) to do string replacements on target files.
Add a `init_template.csv` file at build.sh's directory and you're good to go.

### Configuration File Format

|Pattern|Replacement|Target Files Path|
|-------|-----------|----------|
|__DEFAULT_AWS_ACCOUNT;|000000000001;|build.sh terraform/variables.tf|

Notes:
- The separator field is a semicolon.
- The field for `Target Files Path` accepts multiple values, separated by empty spaces.

Sample `init_template.csv`:

```
__DEFAULT_AWS_ACCOUNT;000000000001;build.sh terraform/variables.tf
__DEFAULT_APP_NAME;dummy-app;build.sh terraform/variables.tf
```

### Inputs

None.
### Outputs

None.

### Example

```bash
f_init() {
  set_default_values
}
```
