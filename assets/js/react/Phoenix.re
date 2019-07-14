let socket =
  Phx.initSocket("/socket")
  |> Phx.connectSocket
  |> Phx.putOnClose(() => Js.log("Socket closed"));

let handleEvent = (updateGame, _event, response) => {
  response->Game.Decode.game->updateGame;
};

let joinChannel = (gameId: string, playerId: string, updateGame) => {
  let channel =
    Phx.initChannel(
      "game:" ++ gameId,
      ~chanParams={"player_id": playerId},
      socket,
    );
  let _ =
    channel
    |> Phx.putOn("new_game", handleEvent(updateGame, "new_game"))
    |> Phx.joinChannel;

  channel;
};
