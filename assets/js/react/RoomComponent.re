[@react.component]
let make = (~game: Game.t, ~player: Player.t) => {
  switch (game.status) {
  | Waiting => <WaitingRoomComponent game player />
  | InProgress => <GameRoomComponent game player />
  | Ended => <GameRoomComponent game player />
  };
};
