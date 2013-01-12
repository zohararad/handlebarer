Handlebars.registerHelper('link_to', function(context) {
  return '<a href="/users/' + context.id + '">' + context.name + '</a>';
});