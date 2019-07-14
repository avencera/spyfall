let socket =
  Phx.initSocket("/socket")
  |> Phx.connectSocket
  |> Phx.putOnClose(() => Js.log("Socket closed"));

let handleReceive = (event, any) =>
  switch (event) {
  | "ok" => Js.log(("handleReiceive:" ++ any, "Joined"))
  | "error" => Js.log(("handleReiceive:" ++ event, "Failed to join channel"))
  | _ => Js.log(("handleReiceive:" ++ event, any))
  };

let joinChannel = (gameId: string, playerId: string, updateGame) => {
  let channel =
    Phx.initChannel(
      "game:" ++ gameId,
      ~chanParams={"player_id": playerId},
      socket,
    );
  let _ = Phx.joinChannel(channel);
  channel;
};
