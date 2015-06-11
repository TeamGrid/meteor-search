settings =
  name: 'TeamSearch'
  mixins: ['logging']

class TeamSearch extends PackageBase(settings)
  @_definitions: {}
  @_startup: ->
    if Meteor.isServer
      @_ensureIndexes()
      @_setupPublish()

  @_ensureIndexes: ->
    Meteor.startup =>
      for searchname, def of @_definitions
        for name, collection of def.collections
          @_ensureIndex name, collection

  @_ensureIndex: (collectionName, options) ->
    collection = Mongo.Collection.get(collectionName)
    indexes = {}
    for field in options.indexFields
      indexes[field] = 'text'
    existingIndex = @_getTextIndex collection
    if existingIndex isnt @_getIndexName(options.indexFields)
      @log "resetting text index for #{collectionName}", 'warn'
      collection._dropIndex existingIndex
    collection._ensureIndex indexes

  @_getTextIndex: (collection) ->
    rawCollection = collection.rawCollection()
    indexInformation = Meteor.wrapAsync(rawCollection.indexInformation, rawCollection)()
    for key, index of indexInformation when _.object(index)['_fts'] is 'text'
      return key

  @_getIndexName: (fields) ->
    str = ""
    for field in fields
      str += "#{field}_text_"
    return str.substr 0, str.length - 1

  @_setupPublish: ->
    self = this
    Meteor.publish 'teamSearch', (params) ->
      check params,
        name: String
        text: Match.Optional String
        data: Match.Optional Object

      return @ready() unless params.text?

      for name, def of self._definitions when name is params.name
        return self._publishSearch.call self,
          name: params.name
          text: params.text
          data: params.data
          definition: def
          publication: this

      return @ready()

  @_publishSearch: (params) ->
    check params,
      name: String
      text: String
      data: Match.Optional Object
      definition:
        collections: Object
      publication: Match.Any

    observeHandles = []
    params.publication.onStop -> # cleanup
      handle.stop() for handle in observeHandles

    searchCollection = @_getSearchCollectionName params.name
    for name, options of params.definition.collections
      cursor = @_getSearchCursor name, options, params.text, params.data
      observeHandles.push cursor.observeChanges
        added: (id, fields) ->
          params.publication.added searchCollection, id, _.extend(fields, originalCollection: name)
        changed: (id, fields) ->
          params.publication.changed searchCollection, id, fields
        removed: (id) ->
          params.publication.removed searchCollection, id

    return params.publication.ready()

  @_getSearchCursor: (collectionName, params, searchValue, data) ->
    collection = Mongo.Collection.get collectionName
    query = {}
    query = $text: $search: searchValue if params.indexFields?.length > 0
    options =
      fields:
        score: $meta: 'textScore'
      sort:
        score: $meta: 'textScore'


    if typeof params.query is 'function'
      query = params.query.call query, searchValue, data
    else
      query = _.extend query, params.query

    if typeof params.options is 'function'
      options = params.options.call options, searchValue, data
    else
      options = _.extend options, params.options

    return collection.find query, options

  @_getSearchCollectionName: (name) -> "_searchCollection_#{name}"

  @_subscribe: (template, data) ->
    template.subscribe 'teamSearch',
      name: data.name
      text: data.searchValue
      data: _.omit data, ['name', 'searchValue']

  @define: (options) ->
    if Meteor.isClient
      throw new Error 'TeamSearch.define is only available on server!'

    for name, def of options
      @_definitions[name] = def

TeamSearch._startup()
