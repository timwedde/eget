# eget

A tiny helper to access scoped environment variables.

`eget` uses a format string to dynamically construct calls to environment variables based on other environment variables. The most common use case for this is a situation where you may have environment variables prefixed or suffixed with environment names, i.e. `VAR_STAGING` and `VAR_PRODUCTION` and you want to dynamically select between them.

Doing this in bash is possible but somewhat cumbersome. With `eget`, you can define the format of your environment variables once and then easily reuse it across calls.

## Usage

```bash
eget <variable_name>
```

### Example
```bash
some-command -e VAR=$(eget VAR)
```

### Customization
The default format string is `{var_name}_{$ENV_NAME}`.
This means that the above call will result in the environment variable `VAR_STAGING` being called, if `$ENV_NAME=staging`.

The format string can be changed by setting the environment variable `EGET_FMT`. It follows a simplified version of the Python string formatting syntax, with the following rules:
1. The variable `{var_name}` is special and will be the name of the environment variable passed to `eget`.
2. Variables beginning with `$` such as `{$ENV_NAME}` will be interpeted as environment variables and substituted with their values accordingly.
3. Format specifiers are supported, but currently only two are available: `u` (uppercase) and `l` (lowercase). `u` is the default, meaning all variable names will be uppercased by default. Format specifiers can be supplied like this: `{$ENV_NAME:u}` or `{$ENV_NAME:l}`
