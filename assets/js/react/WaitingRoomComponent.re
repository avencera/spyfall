let renderPlayer = (player: Player.t) => {
  <li> player.name->React.string </li>;
};
let renderPlayers = (players: array(Player.t)) => {
  <ul> {players->Belt.Array.map(renderPlayer)->ReasonReact.array} </ul>;
};

[@react.component]
let make = (~game: Game.t, ~player: Player.t) => {
  <div>
    <div className="mb-4">
      <h2 className="text-xl text-gray-600 font-semibold">
        {React.string("Waiting for players...")}
      </h2>
    </div>
    <div className="mb-12">
      <h3 className="text-gray-700 font-medium">
        {React.string("Room Code: " ++ game.id)}
      </h3>
      <p className="text-sm text-gray-600 pt-1">
        {React.string("https://spyfall.avencera.com/join/" ++ game.id)}
      </p>
    </div>
    <div className="mb-4 text-left"> {renderPlayers(game.players)} </div>
  </div>;
};
