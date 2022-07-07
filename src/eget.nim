import std/os
import std/tables
import std/unicode
import std/strutils
import std/strformat

proc to_string[T: char|byte](src: openarray[T]): string =
  ## Converts a sequence of chars/bytes to a string.
  result = newString(src.len)
  copyMem(result[0].addr, src[0].unsafeAddr, src.len)

proc parse_markup(s: seq[char]): (string, string) =
  ## Parses field definitions similar to Python's format arguments.
  var
    field_name: seq[char]
    format_spec: seq[char]
    found_split = false
  for c in s:
    if c == ':':
      found_split = true
    elif found_split:
      format_spec.add(c)
    else:
      field_name.add(c)

  var result_field_name = ""
  if field_name.len > 0:
    result_field_name = field_name.to_string

  var result_format_spec = ""
  if format_spec.len > 0:
    result_format_spec = format_spec.to_string

  return (result_field_name, result_format_spec)

proc parse_format_string(s: string): seq[(string, string, string)] =
  ## Parses format strings similar to Python's format strings and returns
  ## the parsed data in the form (literal_text, field_name, format_spec).
  var
    index = 0
    in_markup = false
    literal_text: seq[char]
    markup_string: seq[char]
  while index < len(s):
    let c = s[index]
    if c == '{':
      if index != 0 and s[index - 1] == '\\':
        literal_text.add(c)
        index += 1
        continue
      in_markup = true
    elif c == '}':
      if index != 0 and s[index - 1] == '\\':
        literal_text.add(c)
        index += 1
        continue
      in_markup = false
      let (field_name, format_spec) = parse_markup(markup_string)
      if literal_text.len > 0:
        result.add((literal_text.to_string, field_name, format_spec))
      else:
        result.add(("", field_name, format_spec))
      markup_string = @[]
      literal_text = @[]
    elif in_markup:
      markup_string.add(c)
    else:
      literal_text.add(c)
    index += 1

  if literal_text.len > 0:
    result.add((literal_text.to_string, "", ""))

  if in_markup:
    raise newException(ValueError, "Unclosed markup field")

proc main() =
  ## Main eget method.
  if paramCount() == 0:
    echo "No argument given"
    quit(1)
  elif paramCount() > 1:
    echo "More than one argument given"
    quit(1)

  let
    var_name = paramStr(1)
    format_string = getEnv("EGET_FMT", "{var_name}_{$ENV_NAME}")
    internal_variables = {"var_name": var_name}.toTable

  var
    result: seq[string]
    arg_data: seq[string]
  for (literal_text, field_name, format_spec) in parse_format_string(format_string):
    if literal_text != "":
      result.add(literal_text)

    if field_name != "":
      result.add("$#")
      var value = ""

      if field_name[0] == '$':
        value = getEnv(field_name[1..^1])
        if value == "":
          echo &"Environment variable is empty: {field_name}"
          quit(1)
      elif field_name in internal_variables:
        value = internal_variables[field_name]
      else:
        echo &"Unknown variable: {field_name}"
        quit(1)

      if format_spec == "" or format_spec[0] == 'u':
        arg_data.add(value.toUpper)
      elif format_spec == "l":
        arg_data.add(value.toLower)

  let target_env_var = result.join("") % arg_data
  if not existsEnv(target_env_var):
    echo &"Target environment variable does not exist: {target_env_var}"
    quit(1)
  let target_value = getEnv(target_env_var)
  echo target_value

when isMainModule:
  main()
