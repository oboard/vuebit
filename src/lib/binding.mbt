///|
pub(all) struct Ref[T] {
  value : T
  json : Json
} derive(ToJson, FromJson, Show)

///| Creates a new reference to a value.
pub fn Ref::new[T : ToJson](value : T) -> Ref[T] {
  let json = value.to_json()
  let reference = _refer(json)
  { value, json: reference }
}

///|
extern "js" fn _refer(value : Json) -> Json =
  #|(value) => Vue.ref(value)

///|
pub(all) struct T {
  app : Json
  options : AppOptions
} derive(ToJson)

///|
pub(all) struct AppOptions {
  data : Json?
  methods : Json?
  computed : Json?
} derive(ToJson)

///|
pub fn create(data? : Json, methods? : Json, computed? : Json) -> T {
  let options = { data, methods, computed }
  { app: _createApp(options.to_json().stringify()), options }
}

///|
pub extern "js" fn _createApp(app : String) -> Json =
  #|(_app) => {
  #|  let app = JSON.parse(_app);
  #|  return Vue.createApp({
  #|    data() {
  #|      return app.data
  #|    },
  #|    methods: app.methods || {},
  #|    computed: app.computed || {}
  #|  });
  #|}

///|
pub fn T::mount(self : T, target : String) -> Unit {
  _mount(self.app, target) |> ignore
}

///|
pub fn T::setState(self : T, data : Json) -> Unit {
  _setState(self.app, data.stringify())
}

///|
pub extern "js" fn _mount(app : Json, target : String) -> Json =
  #|(app, target) => {
  #|  app.mount(target);
  #|  window.app = app;
  #|  return app;
  #|}

///|
pub extern "js" fn _setState(app : Json, data : String) -> Unit =
  #|(app, dataString) => {
  #|  const instance = app._instance;
  #|  if (instance) {
  #|    const proxy = instance.proxy;
  #|    const data = JSON.parse(dataString);
  #|    Object.keys(data).forEach(key => {
  #|      proxy[key] = data[key];
  #|    });
  #|  }
  #|}

///| Creates an empty JSON object
pub fn empty_json() -> Json {
  Json::Object({})
}

///| Creates methods object
pub fn methods(methods : Json) -> Json {
  methods
}

///| Creates computed properties object
pub fn computed(computed : Json) -> Json {
  computed
}
