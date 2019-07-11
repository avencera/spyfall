import css from "../css/app.css";

import "phoenix_html";

let liveSocket = new LiveSocket("/live");
liveSocket.connect();
