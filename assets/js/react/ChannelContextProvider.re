let maybeChannel: option(Phx_channel.t) = None;
let channelContext = React.createContext(maybeChannel);

let makeProps = (~channel: Phx_channel.t, ~children, ()) => {
  "value": Some(channel),
  "children": children,
};

let make = React.Context.provider(channelContext);
