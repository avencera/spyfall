let renderPlayer = (index: int, player: Player.t, channel) => {
  let indexString = string_of_int(index + 1);
  <li className="mb-4">
    <div className="flex">
      <div className="w-3/4">
        <p>
          <span> {React.string(indexString ++ ". ")} </span>
          <span className="ml-1"> {React.string(player.name)} </span>
        </p>
      </div>
      <div className="w-1/4 text-right">
        <a
          href=""
          className="text-red-700 hover:text-red-900"
          onClick={e => {
            e->ReactEvent.Mouse.preventDefault;
            let _ = Phoenix.removePlayer(player.id, channel);
            ();
          }}>
          {React.string("X")}
        </a>
      </div>
    </div>
  </li>;
};
let renderPlayers = (players: array(Player.t), channel) => {
  <ul>
    {players
     ->Belt.Array.mapWithIndex((index, player) =>
         renderPlayer(index, player, channel)
       )
     ->ReasonReact.array}
  </ul>;
};

[@react.component]
let make = (~game: Game.t, ~player: Player.t) => {
  let channel =
    ChannelContextProvider.channelContext
    ->React.useContext
    ->Belt.Option.getExn;

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
    <div className="mb-4 text-left">
      {renderPlayers(game.players, channel)}
    </div>
  </div>;
};
