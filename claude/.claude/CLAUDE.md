# General Coding Preferences

- Unless prompted to ignore, include metrics to gather usage stats for new
  features or bug fixes. Metrics should be defined as a Hash constant in the
  class or module, keys being symbols, and values being strings with the full
  keyspace. Avoid interpolating metric keys to preserve better searchability
  and visibility for future developers.
- Unless prompted to ignore, include Logging info and error messages in success
  and error cases. Be careful to avoid dumping object state into the log
  message, as some data may contain PII or MNPI and should not end up in our
  logs. When in doubt, ask the developer if a particular object is safe to log
  or not.
- In general, don't add code comments inside functions or tests to describe what
  the code is doing. If the code is hard to understand it should be simplified
  or extracted. Function docs are great, code comments are a smell.
- Add class/module docs to business logic modules.
- Add function/method docs to public business logic functions.
  Controllers, models, and resolvers rarely need function/method docs.
- Documentation in markdown files or code comments should be kept to 80
  characters per line with natural word breaks. Avoid hyphenating when breaking
  lines up. Avoid breaking up markdown link text, even if the link pushes the
  line longer than 80 chars.
- When changes are made to an implementation, we should find affected existing
  unit tests and update them, and consider writing new unit tests if new
  features/cases are introduced.
- When adding methods, functions, or constants to a module or class, put them in
  alphabetical order. When nothing is alphabetized, place the new module at the
  bottom of the section in question.

## Clojure Projects

- Prefer `(ns ...)` blocks over separate `(require ..)`, `(import ..)`, etc.
- Prefer threading macros (->>, ->, and as->) for building functional
  pipelines, as opposed to let blocks with lots of intermediate bindings.
- Prefer map lookups instead of simple case statements.
- Source files should have specific sections in the following order:
  1. Require/imports/etc
  2. Static defs
  3. public functions
  4. private functions
- Items in each section (vars, methods, imports) should always be alphabetized
  where possible. Pre-define functions if ordering will be problematic for
  missing functions.
- `defmulti` with `defmethod` often creates really readable code.
- For all other style/formatting, use the clojure style guide to guide
  formatting decisions

## Ruby/Rails Projects

- When refactoring code that references modules or classes, in general we should
  always prefix module names with `::` to get to the root of the classpath.
- Modules and Classes should have ordered sections, with newlines in between
  sections, with items in those sections alphabetized. The general set of
  sections (and their order) is:
  1. Includes/Extends
  2. Constants
  3. `attr_*` methods and other DSL-like class-level method calls
  4. Public Class methods
  5. Private class methods
  6. Public Instance methods (with initializer at top out of alphabetical order)
  7. Private instance methods
- Prefer `self.foo` instead of `class << self; def foo`
- After making changes to implementation and tests, run `bundle exec rubocop -A`
  to make sure we don't have any lint issues.

## Elixir Projects

- When adding functions or constants to a module, put them in alphabetical order.
- Always add or update public function `@spec` and `@doc` info.
- Modules should have ordered sections, with items in those sections
  alphabetized. The general set of sections (and their order) is:
  1. `use`
  2. `require`
  3. `alias` - Aliases should always be one per line, no using the glob
     pattern `Foo.{Bar, Baz}`.
  4. Module attributes (e.g. `@foo :bar`) and other DSL-like function calls.
  5. Public Functions
  6. Private functions
- After making changes to implementation and tests, run `mix dialyzer` and
  `mix format` to make sure we don't have any lint issues.
- When writing tests, use `ctx` as the context variable when needed. Do not
  expand the context variable to pull direct keys out.
