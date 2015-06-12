Package.describe({
  name: 'team:search',
  summary: 'fulltext-search over multiple collections',
  version: '1.1.3'
});

Package.onUse(function(api) {
  api.versionsFrom('1.1.0.2');
  api.use([
    'coffeescript',
    'underscore',
    'check',
    'templating@1.0.0',
    'blaze@2.0.0',
    'dburles:mongo-collection-instances@0.3.3',
    'maximum:package-base@1.1.2'
  ]);

  api.addFiles([
    'both/teamsearch.coffee',
  ],['client', 'server']);

  api.addFiles([
    'client/teamsearch.html',
    'client/teamsearch.coffee',
  ],'client');

  api.export('TeamSearch');
});
