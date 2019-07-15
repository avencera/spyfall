let renderPlayer = (index: int, player: Player.t, channel) => {
  let indexString = string_of_int(index + 1);

  let backgroundColor = index mod 2 == 0 ? "bg-gray-100" : "bg-white";

  <li className={"py-3 px-2 " ++ backgroundColor} key={player.id}>
    <div className="flex">
      <div className="w-full">
        <p>
          <span> {React.string(indexString ++ ". ")} </span>
          <span className="pl-2"> {React.string(player.name)} </span>
        </p>
      </div>
      <div className="text-right">
        <a
          href=""
          className="text-red-700 hover:text-red-900"
          onClick={e => {
            e->ReactEvent.Mouse.preventDefault;
            Phoenix.removePlayer(player.id, channel);
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
        {React.string("https://spyfall.avencera.com/" ++ game.id)}
      </p>
    </div>
    <div className="mb-10 text-left">
      {renderPlayers(game.players, channel)}
    </div>
    <div className="buttons-row flex">
      <div className="w-full">
        <button
          className="indigo-button-outline w-full"
          onClick={_e => Phoenix.startGame(channel)}>
          {React.string("Start Game")}
        </button>
      </div>
    </div>
  </div>;
};
