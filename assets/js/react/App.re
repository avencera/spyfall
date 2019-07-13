let handleClick = _event => Js.log("clicked!");

[@react.component]
let make = (~flags) =>
  <div onClick=handleClick> {ReasonReact.string(flags)} </div>;
