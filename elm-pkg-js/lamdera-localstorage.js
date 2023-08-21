exports.init = async function (app) {
  if ("ports" in app) {
    if ("save_to_localstorage" in app.ports) {
      app.ports.save_to_localstorage.subscribe(function (value) {
        localStorage.setItem("storage", value);
      });
    }
    if ("load_from_localstorage" in app.ports) {
      app.ports.load_from_localstorage.subscribe(function () {
        app.ports.loaded_from_localstorage.send(
          localStorage.getItem("storage") ?? ""
        );
      });
    }
  }
};
