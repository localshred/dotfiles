#!/usr/bin/env zsh

##
## Print a graphql graph in easier to read SDL format.
## See https://www.apollographql.com/blog/backend/schema-design/three-ways-to-represent-your-graphql-schema/#introspection-query-result-to-sdl
##
## Usage:
##  print_graph https://my.app.com/api/graphql
##
## Note:
##   Requires `node`, `npm`, and `jq` on your `PATH`, but makes no assumptions
##   about their versions. This script _will_ install `graphql` from npm
##   if it's not found.
##

function print_graph() {
  graphql_host=$1
  if [[ "$graphql_host" == "" ]]; then
    print_error "Must provide a host to introspect"
    return 1
  fi

  if ! command -v node &>/dev/null; then
    print_error "You need node/npm on your path"
    return 2
  fi

  if ! npm ls graphql >/dev/null; then
    print_info "Installing graphql npm package"
    npm install graphql
  fi

  result_file=$(mktemp)
  introspection_query='{
  "query":"
    fragment FullType on __Type { kind
                                  name
                                  fields(includeDeprecated: true) { name args { ...InputValue } type { ...TypeRef } isDeprecated deprecationReason }
                                  inputFields { ...InputValue }
                                  interfaces { ...TypeRef }
                                  enumValues(includeDeprecated: true) { name isDeprecated deprecationReason }
                                  possibleTypes { ...TypeRef } }
    fragment InputValue on __InputValue { name type { ...TypeRef } defaultValue }
    fragment TypeRef on __Type { kind name ofType { kind name ofType { kind name ofType { kind name ofType { kind name ofType { kind name ofType { kind name ofType { kind name } } } } } } } }
    query IntrospectionQuery { __schema { queryType { name }
                                          mutationType { name }
                                          types { ...FullType }
                                          directives { name locations args { ...InputValue } } } }
  "
}'

  curl \
    "$graphql_host" \
    -v \
    -H 'Content-Type: application/json' \
    -H 'Accept: application/json' \
    --compressed \
    --data-binary "$introspection_query" \
    > "$result_file"

  if [[ "$?" -gt 0 ]]; then
    print_error "Unable to fetch graph"
    return 3
  fi

  errors=$(jq .errors "$result_file")
  if [[ "$errors" != "null" ]]; then
    print_error "Failed to parse file, see ${result_file} for raw results"
    print_error $errors
    return 4
  fi

  SCRIPT=$(cat <<EOF
const { buildClientSchema, printSchema } = require("graphql");
const fs = require("fs");

const resultFile = process.argv[1];
const fileContents = fs.readFileSync(resultFile);
const introspectionSchemaResult = JSON.parse(fileContents)["data"];
const graphqlSchemaObj = buildClientSchema(introspectionSchemaResult);
const sdlString = printSchema(graphqlSchemaObj);
console.log(sdlString);
EOF
        )

  node -e $SCRIPT $result_file
}
