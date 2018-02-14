Package.describe({
  name: 'teamgrid:search',
  summary: 'fulltext-search over multiple collections',
  version: '1.2.0'
});

Package.onUse(function(api) {
  api.versionsFrom('1.6.1');
  api.use([
    'coffeescript@2.0.0',
    'underscore',
    'reactive-var',
    'check',
    'templating@1.0.0',
    'blaze@2.0.0',
    'dburles:mongo-collection-instances@0.3.3',
    'maximum:package-base@1.2.0'
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
