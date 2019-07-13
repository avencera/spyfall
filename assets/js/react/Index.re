// let flags = [%bs.raw
//   {| JSON.parse(document.querySelector('#react-flags').dataset.lists) |}
// ];

let flags = "hello";

ReactDOMRe.renderToElementWithId(<App flags />, "react-root");
