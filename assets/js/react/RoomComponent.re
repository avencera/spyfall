let isPlayerInGame = (game: Game.t, currentPlayer: Player.t) => {
  game.players
  ->Belt.Array.keep(player => player.id == currentPlayer.id)
  ->Belt.Array.length
  ->Pervasives.(>=)(1);
};

[@react.component]
let make = (~game: Game.t, ~player: Player.t) => {
  switch (game.status, isPlayerInGame(game, player)) {
  | (_, false) =>
    <div> {React.string("You have been removed from this game!")} </div>
  | (Waiting, true) => <WaitingRoomComponent game />
  | (InProgress, true) => <GameRoomComponent game />
  | (Finished, true) => <GameRoomComponent game />
  };
};
