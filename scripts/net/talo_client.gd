extends Node
## Онлайн-топ по нажатиям через Talo (trytalo.com): регистрация, вход с кодом
## из почты, отправка рекорда и чтение топа. Свой маленький клиент вместо
## официального плагина: нужны всего несколько запросов REST API.
##
## Ключ игры лежит в res://secrets/talo_key.txt. Папка secrets не попадает в git
## (.gitignore), но попадает в сборку (include_filter в export_presets.cfg).
## Без ключа топ просто выключен.

signal state_changed

const API: String = "https://api.trytalo.com"
const KEY_PATH: String = "res://secrets/talo_key.txt"
const SESSION_PATH: String = "user://talo_session.cfg"
const BOARD: String = "taps"
const SUBMIT_EVERY: float = 60.0
## Больше этого руками не нажать: игра и так режет тапы до 20 в секунду.
const MAX_TAPS_PER_SEC: float = 20.0

var key: String = ""
var alias_id: int = -1
var player_id: String = ""
var nickname: String = ""
var busy: bool = false
var _session: String = ""
var _verify_alias: int = -1
var _submitted_taps: int = -1
var _submitted_at: float = 0.0
var _timer: float = 0.0


func _ready() -> void:
	if FileAccess.file_exists(KEY_PATH):
		key = FileAccess.get_file_as_string(KEY_PATH).strip_edges()
	if enabled():
		_restore_session()


func enabled() -> bool:
	return key.length() > 20


func logged_in() -> bool:
	return alias_id >= 0 and not _session.is_empty()


func waiting_for_code() -> bool:
	return _verify_alias >= 0


func _process(delta: float) -> void:
	if not logged_in():
		return
	_timer += delta
	if _timer >= SUBMIT_EVERY:
		_timer = 0.0
		submit_taps()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		if logged_in():
			submit_taps()


# ---------- HTTP ----------

## Запрос к Talo. Возвращает {status, body}; status 0 — нет сети.
func request(method: int, path: String, body: Dictionary = {}) -> Dictionary:
	var headers: PackedStringArray = [
		"Authorization: Bearer " + key,
		"Content-Type: application/json",
		"Accept: application/json",
		"X-Talo-Dev-Build: " + ("1" if OS.is_debug_build() else "0"),
		"X-Talo-Include-Dev-Data: " + ("1" if OS.is_debug_build() else "0"),
		"X-Talo-Client: capy-springs:1.2",
	]
	if alias_id >= 0:
		headers.append("X-Talo-Alias: %d" % alias_id)
	if not player_id.is_empty():
		headers.append("X-Talo-Player: " + player_id)
	if not _session.is_empty():
		headers.append("X-Talo-Session: " + _session)
	var http: HTTPRequest = HTTPRequest.new()
	http.timeout = 15.0
	add_child(http)
	var data: String = "" if body.is_empty() else JSON.stringify(body)
	var err: Error = http.request(API + path, headers, method, data)
	if err != OK:
		http.queue_free()
		return {"status": 0, "body": {}}
	var res: Array = await http.request_completed
	http.queue_free()
	var status: int = int(res[1])
	# Веб-сборка отдаёт ответ 204 как «нет ответа» со статусом 0
	if int(res[0]) == HTTPRequest.RESULT_NO_RESPONSE and status == 0:
		status = 204
	elif int(res[0]) != HTTPRequest.RESULT_SUCCESS:
		status = 0
	var parsed = JSON.parse_string((res[3] as PackedByteArray).get_string_from_utf8())
	return {"status": status, "body": parsed if typeof(parsed) == TYPE_DICTIONARY else {}}


## Понятный текст ошибки из ответа Talo.
static func error_text(res: Dictionary) -> String:
	if int(res["status"]) == 0:
		return "no_network"
	var b: Dictionary = res["body"]
	if b.has("errorCode"):
		return str(b["errorCode"])
	if b.has("message"):
		return str(b["message"])
	if b.has("errors"):
		return str(b["errors"])
	return "http_%d" % int(res["status"])


# ---------- вход ----------

## Регистрация. Подтверждение по почте включено, поэтому сразу после неё
## делаем вход: Talo пришлёт код на почту, без него сессии не будет.
func register(nick: String, email: String, password: String) -> String:
	busy = true
	var res: Dictionary = await request(HTTPClient.METHOD_POST, "/v1/players/auth/register", {
		"identifier": nick, "password": password, "email": email,
		"verificationEnabled": true, "withRefresh": true})
	busy = false
	if int(res["status"]) != 200:
		return error_text(res)
	# Сессию регистрации не используем: в топ попадают только после кода из почты
	return await login(nick, password)


## Вход. Возвращает "" (успех), "code" (ждём код из почты) или код ошибки.
func login(nick: String, password: String) -> String:
	busy = true
	_clear_local()
	var res: Dictionary = await request(HTTPClient.METHOD_POST, "/v1/players/auth/login",
		{"identifier": nick, "password": password, "withRefresh": true})
	busy = false
	if int(res["status"]) != 200:
		return error_text(res)
	var b: Dictionary = res["body"]
	if b.get("verificationRequired", false):
		_verify_alias = int(b.get("aliasId", -1))
		state_changed.emit()
		return "code"
	_take_session(b)
	return ""


func verify(code: String) -> String:
	busy = true
	var res: Dictionary = await request(HTTPClient.METHOD_POST, "/v1/players/auth/verify",
		{"aliasId": _verify_alias, "code": code.strip_edges(), "withRefresh": true})
	busy = false
	if int(res["status"]) != 200:
		return error_text(res)
	_verify_alias = -1
	_take_session(res["body"])
	await submit_taps()
	return ""


func logout() -> void:
	if logged_in():
		request(HTTPClient.METHOD_POST, "/v1/players/auth/logout")
	_clear_local()
	DirAccess.remove_absolute(SESSION_PATH)
	state_changed.emit()


func _take_session(b: Dictionary) -> void:
	var alias: Dictionary = b.get("alias", {})
	alias_id = int(alias.get("id", -1))
	nickname = str(alias.get("identifier", ""))
	player_id = str((alias.get("player", {}) as Dictionary).get("id", ""))
	_session = str(b.get("sessionToken", ""))
	var cfg: ConfigFile = ConfigFile.new()
	cfg.set_value("session", "refreshToken", str(b.get("refreshToken", "")))
	cfg.set_value("session", "identifier", nickname)
	cfg.save(SESSION_PATH)
	_submitted_taps = -1
	state_changed.emit()


func _clear_local() -> void:
	alias_id = -1
	player_id = ""
	nickname = ""
	_session = ""
	_verify_alias = -1


## При запуске: обновить сессию по сохранённому токену и узнать свой профиль.
func _restore_session() -> void:
	var cfg: ConfigFile = ConfigFile.new()
	if cfg.load(SESSION_PATH) != OK:
		return
	var refresh: String = str(cfg.get_value("session", "refreshToken", ""))
	var ident: String = str(cfg.get_value("session", "identifier", ""))
	if refresh.is_empty() or ident.is_empty():
		return
	var res: Dictionary = await request(HTTPClient.METHOD_POST, "/v1/players/auth/refresh", {"refreshToken": refresh})
	if int(res["status"]) != 200:
		if int(res["status"]) != 0:
			DirAccess.remove_absolute(SESSION_PATH)   # токен протух — войти заново
		return
	_session = str(res["body"].get("sessionToken", ""))
	cfg.set_value("session", "refreshToken", str(res["body"].get("refreshToken", refresh)))
	cfg.save(SESSION_PATH)
	var who: Dictionary = await request(HTTPClient.METHOD_GET, "/v1/players/identify?service=talo&identifier=" + ident.uri_encode())
	if int(who["status"]) != 200:
		_session = ""
		return
	var alias: Dictionary = who["body"].get("alias", {})
	alias_id = int(alias.get("id", -1))
	nickname = str(alias.get("identifier", ident))
	player_id = str((alias.get("player", {}) as Dictionary).get("id", ""))
	state_changed.emit()


# ---------- топ ----------

## Можно ли отправить столько нажатий: прирост с прошлой отправки не быстрее,
## чем возможно руками (плюс запас). Первая отправка после входа — без проверки
## скорости: в ней все нажатия, сделанные до регистрации.
func taps_plausible(taps: int, now: float) -> bool:
	if _submitted_taps < 0:
		return true
	var dt: float = maxf(1.0, now - _submitted_at)
	return taps - _submitted_taps <= int(dt * MAX_TAPS_PER_SEC) + 50


func submit_taps() -> void:
	if not logged_in():
		return
	var taps: int = Game.taps
	var now: float = Time.get_unix_time_from_system()
	if taps == _submitted_taps or not taps_plausible(taps, now):
		return
	var res: Dictionary = await request(HTTPClient.METHOD_POST, "/v1/leaderboards/%s/entries" % BOARD,
		{"score": taps, "props": []})
	if int(res["status"]) == 200:
		_submitted_taps = taps
		_submitted_at = now


## Топ: массив [{pos, name, score, me}] или {"error": код} при ошибке.
func top(limit: int = 50):
	var res: Dictionary = await request(HTTPClient.METHOD_GET, "/v1/leaderboards/%s/entries?page=0" % BOARD)
	if int(res["status"]) != 200:
		return {"error": error_text(res)}
	var out: Array = []
	for e in res["body"].get("entries", []):
		var a: Dictionary = e.get("playerAlias", {})
		out.append({"pos": int(e.get("position", out.size())) + 1, "name": str(a.get("identifier", "?")),
			"score": float(e.get("score", 0.0)), "me": int(a.get("id", -2)) == alias_id})
		if out.size() >= limit:
			break
	return out
