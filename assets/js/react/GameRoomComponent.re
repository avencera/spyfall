type action =
  | UpdateTime(int);

type state = {timeLeft: option(int)};

[@react.component]
let make = (~game: Game.t, ~player: Player.t) => {
  let channel =
    ChannelContextProvider.channelContext
    ->React.useContext
    ->Belt.Option.getExn;

  let (state: state, dispatch: action => unit) =
    React.useReducer(
      (_state: state, action: action) =>
        switch (action) {
        | UpdateTime(time) => {timeLeft: Some(time)}
        },
      {timeLeft: None},
    );

  React.useEffect1(
    () => {
      Phoenix.getTimeLeft(channel, timeLeft =>
        dispatch(UpdateTime(timeLeft))
      );
      None;
    },
    [||],
  );

  <div> {React.string("Welcome")} </div>;
};
