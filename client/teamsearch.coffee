Template.TeamSearch.helpers
  items: ->
    cursor = Template.instance()?._searchCollection.find()
    return cursor if cursor?.count() > 0

Template.TeamSearch.onCreated ->
  @_searchCollection = Mongo.Collection.get TeamSearch._getSearchCollectionName @data.name
  unless @_searchCollection?
    @_searchCollection =  new Mongo.Collection TeamSearch._getSearchCollectionName @data.name
  @_searchCollection._transform = (doc) ->
    originalCollection = Mongo.Collection.get doc.originalCollection
    transformed = originalCollection?._transform? doc
    return transformed or doc

  @searchData = new ReactiveVar(@data, _.isEqual)
  @autorun =>
    @searchData.set Template.currentData()
  @autorun =>
    TeamSearch._subscribe this, @searchData.get()
