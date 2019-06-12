

# https://github.com/elastic/elasticsearch-js/blob/14.x/docs/_examples/update.asciidoc

```sh
# Update document title using partial document
client.update({
  index: 'myindex',
  type: 'mytype',
  id: '1',
  body: {
    // put the partial document under the `doc` key
    doc: {
      title: 'Updated'
    }
  }
}, function (error, response) {
  // ...
})
# Add a tag to document tags property using a script
client.update({
  index: 'myindex',
  type: 'mytype',
  id: '1',
  body: {
    script: 'ctx._source.tags += tag',
    params: { tag: 'some new tag' }
  }
}, function (error, response) {
  // ...
});
# Increment a document counter by 1 or initialize it, when the document does not exist
client.update({
  index: 'myindex',
  type: 'mytype',
  id: '777',
  body: {
    script: 'ctx._source.counter += 1',
    upsert: {
      counter: 1
    }
  }
}, function (error, response) {
  // ...
})
# Delete a document if it’s tagged “to-delete”
client.update({
  index: 'myindex',
  type: 'mytype',
  id: '1',
  body: {
    script: 'ctx._source.tags.contains(tag) ? ctx.op = "delete" : ctx.op = "none"',
    params: {
      tag: 'to-delete'
    }
  }
}, function (error, response) {
  // ...
});
```