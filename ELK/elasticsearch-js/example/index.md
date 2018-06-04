

# https://github.com/elastic/elasticsearch-js/blob/14.x/docs/_examples/index.asciidoc

Create or update a document
```js
client.index({
  index: 'myindex',
  type: 'mytype',
  id: '1',
  body: {
    title: 'Test 1',
    tags: ['y', 'z'],
    published: true,
  }
}, function (error, response) {

});
```