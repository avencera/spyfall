let flags = [%bs.raw
  {| JSON.parse(document.querySelector('#react-flags').dataset.data) |}
];

ReactDOMRe.renderToElementWithId(<App flags />, "react-root");
