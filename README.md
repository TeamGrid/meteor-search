# teamgrid:search
Meteor package that provides a simple API for implementing a fulltext-search.

## Installation
````

    meteor add teamgrid:search

````

## Usage

### On server
````coffee
TeamSearch.define
  uniqueSearchName:
    threshold: 3
    collections:
      posts:
        indexFields: ['name']
        query:
          archived: $ne: true
        query: (searchValue, data) ->
          _.extend this, authorId: data.authorId
        options:
          fields:
            name: 1
            limit: 10
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
