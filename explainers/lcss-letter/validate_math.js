'use strict';
const fs = require('fs');
const path = require('path');
const vm = require('vm');
const assert = require('assert');
const katex = require('./dist/vendor/katex.min.js');
const context = {window: {}};
vm.runInNewContext(fs.readFileSync(path.join(__dirname, 'dist/lessons.js'), 'utf8'), context);
const lessons = context.window.GUIDE.chapters.flatMap(c => c.lessons);
const macros = {'\\E':'\\mathbb{E}','\\Var':'\\operatorname{Var}','\\Cov':'\\operatorname{Cov}',
  '\\one':'\\mathbf{1}','\\F':'\\mathcal{F}','\\G':'\\mathcal{G}','\\HH':'\\mathcal{H}','\\R':'\\mathbb{R}'};
let count = 0;
for (const lesson of lessons) {
  assert(lesson.body && lesson.explain.length, 'Empty lesson: ' + lesson.id);
  if (lesson.id.startsWith('proof-')) assert(lesson.details?.length, 'Missing derivation: ' + lesson.id);
  const texts = [lesson.body, ...lesson.explain, lesson.remember || '', ...(lesson.details || []).map(d => d.body)];
  for (const text of texts) {
    const parts = text.match(/\\\[[\s\S]*?\\\]|\$[^$]+\$/g) || [];
    for (const part of parts) {
      const display = part.startsWith('\\[');
      katex.renderToString(display ? part.slice(2, -2) : part.slice(1, -1),
        {displayMode: display, macros, strict: 'ignore', throwOnError: true, trust: false});
      count++;
    }
  }
  if (lesson.image) assert(fs.existsSync(path.join(__dirname, 'dist', lesson.image)));
}
assert.equal(new Set(lessons.map(s => s.id)).size, lessons.length);
console.log(`Validated ${lessons.length} lessons and ${count} mathematical expressions.`);
