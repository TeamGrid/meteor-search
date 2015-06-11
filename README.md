# team:search
Meteor package that provides a simple API for implementing a fulltext-search.

## Installation
````

    meteor add team:search

````

## Usage

### On server
````coffee
TeamSearch.define
  uniqueSearchName:
    collections:
      posts:
        indexFields: ['name']
        query:
          archived: $ne: true
        options:
          fields:
            name: 1
````

### On client
````blaze
{{#TeamSearch name='uniqueSearchName' searchString=reactiveSearchString}}
  {{#each searchItems}}
    {{name}}
  {{else}}
    no results
  {{/each}}
{{else}}
  loading...
{{/TeamSearch}}

````
