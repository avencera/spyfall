type action =
  | Tick
  | UpdateTime(int)
  | UpdateSecret(Secret.t)
  | AddTimerId(Js.Global.intervalId);

type state = {
  timerId: option(Js.Global.intervalId),
  timeLeft: option(int),
  secret: option(Secret.t),
};

[@react.component]
let make = (~game: Game.t, ~player: Player.t) => {
  let channel =
    ChannelContextProvider.channelContext
    ->React.useContext
    ->Belt.Option.getExn;

  let (state: state, dispatch: action => unit) =
    React.useReducer(
      (state: state, action: action) =>
        switch (action) {
        | UpdateTime(time) => {...state, timeLeft: Some(time)}
        | AddTimerId(timerId) => {...state, timerId: Some(timerId)}
        | Tick =>
          // clear timer when it reaches 0
          switch (state.timeLeft, state.timerId) {
          | (Some(left), Some(timerId)) when left <= 0 =>
            Phoenix.endTimer(channel);
            Js.Global.clearInterval(timerId);
            {...state, timeLeft: Some(0)};
          | _ => {
              ...state,
              timeLeft:
                Belt.Option.map(state.timeLeft, timeLeft => timeLeft - 1),
            }
          }
        },
      {timerId: None, timeLeft: None, secret: None},
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

  React.useEffect0(() => {
    let timerId = Js.Global.setInterval(() => dispatch(Tick), 1000);
    dispatch(AddTimerId(timerId));
    Some(() => Js.Global.clearInterval(timerId));
  });

  let padSecondsString = secs => {
    switch (String.length(secs)) {
    | 2 => secs
    | 1 => "0" ++ secs
    | _ => secs
    };
  };

  let secondsToTimeString = (timeLeft: int): string => {
    let mins = string_of_int(timeLeft / 60)->padSecondsString;
    let secs = string_of_int(timeLeft mod 60)->padSecondsString;

    switch (mins, secs) {
    | ("00", "00") => "The game has ended"
    | ("00", secs) => "00:" ++ secs
    | (mins, secs) => mins ++ ":" ++ secs
    };
  };

  let timeLeftComponent = state =>
    switch (state.timeLeft) {
    | Some(timeLeft) =>
      <div> {timeLeft->secondsToTimeString->React.string} </div>
    | None => <div> {React.string("Loading .... ")} </div>
    };


  <div>
    <div> {timeLeftComponent(state)} </div>
  </div>;
};
