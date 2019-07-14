open Phx;

let socket =
  initSocket("/socket")
  |> connectSocket
  |> putOnClose(() => Js.log("Socket closed"));

let joinChannel = (gameId: string, playerId: string) => {
  let channel =
    initChannel(
      "game:" ++ gameId,
      ~chanParams={"player_id": playerId},
      socket,
    );
  let _ = joinChannel(channel);
  ();
};
