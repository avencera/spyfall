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
  let _ = Phx.push(event, message, channel);
  ();
};

let removePlayer = (player_id: string, channel: Phx_channel.t) => {
  pushMessage("remove_player", {"player_id": player_id}, channel);
};

let startGame = (channel: Phx_channel.t) => {
  pushMessage("start_game", Js.Obj.empty(), channel);
};

let endTimer = (channel: Phx_channel.t) => {
  pushMessage("timer_ended", Js.Obj.empty(), channel);
};

let getTimeLeft = (channel, updateTime) => {
  let newChannel =
    channel
    |> Phx.putOn("received_time_left", responseJson => {
         let timeLeft = Json.Decode.(field("time_left", int, responseJson));
         updateTime(timeLeft);
       });

  pushMessage("get_time_left", Js.Obj.empty(), newChannel);
};

let getSecret = (channel, updateSecret) => {
  let newChannel =
    channel
    |> Phx.putOn("received_secret:spy", _resp => updateSecret(Secret.Spy))
    |> Phx.putOn("received_secret:location", responseJson => {
         let location = Json.Decode.(field("location", string, responseJson));
         updateSecret(Secret.Location(location));
       });

  pushMessage("get_secret", Js.Obj.empty(), newChannel);
};
