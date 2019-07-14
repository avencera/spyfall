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

let pushMessage = (event: string, message: Js.t('a), channel: Phx_channel.t) => {
  Phx.push(event, message, channel);
};

let removePlayer = (player_id: string, channel: Phx_channel.t) => {
  pushMessage("remove_player", {"player_id": player_id}, channel);
};

let startGame = (channel: Phx_channel.t) => {
  pushMessage("start_game", Js.Obj.empty(), channel);
};

let endGame = (channel: Phx_channel.t) => {
  pushMessage("end_game", Js.Obj.empty(), channel);
};
