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
## Ключ подписи запросов (Talo → Game settings → проверка запросов): "версия|значение".
## Если файла нет, запросы уходят без подписи.
const VERIFY_PATH: String = "res://secrets/talo_verify.txt"
const SESSION_PATH: String = "user://talo_session.cfg"
const BOARD: String = "taps"
const SUBMIT_EVERY: float = 60.0
## Больше этого руками не нажать: игра и так режет тапы до 20 в секунду.
const MAX_TAPS_PER_SEC: float = 20.0
## Защита от подбора пароля и кода: после стольких ошибок подряд — пауза.
const MAX_FAILS: int = 5
const LOCK_SEC: float = 60.0
## Топ с сервера не чаще раза в столько секунд (повторные открытия — из кэша).
const TOP_CACHE_SEC: float = 15.0

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
var _verify_version: String = ""
var _verify_value: String = ""
var _fails: int = 0
var _locked_until: float = 0.0
var _top_cache: Array = []
var _top_at: float = -1000.0


func _ready() -> void:
	if FileAccess.file_exists(KEY_PATH):
		key = FileAccess.get_file_as_string(KEY_PATH).strip_edges()
	if FileAccess.file_exists(VERIFY_PATH):
		var v: PackedStringArray = FileAccess.get_file_as_string(VERIFY_PATH).strip_edges().split("|")
		if v.size() == 2:
			_verify_version = v[0]
			_verify_value = v[1]
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
	# Подпись: сервер Talo проверяет её у запросов на запись от игрока
	if alias_id >= 0 and method != HTTPClient.METHOD_GET and signing_enabled():
		headers.append("X-Talo-Signature: " + sign(data))
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


# ---------- подпись запросов ----------

func signing_enabled() -> bool:
	return not _verify_version.is_empty() and not _verify_value.is_empty()


## Подпись как в официальном плагине Talo: HMAC-SHA256 от заголовка
## {rid, sha256(тело), время}. rid и время не дают повторить перехваченный запрос.
func sign(body: String) -> String:
	var rid: String = Crypto.new().generate_random_bytes(8).hex_encode()
	var ts: int = int(Time.get_unix_time_from_system() * 1000.0)
	var header: String = JSON.stringify({"rid": rid, "payload": body.sha256_text(), "timestamp": ts})
	var header_b64: String = Marshalls.utf8_to_base64(header)
	var hmac: HMACContext = HMACContext.new()
	hmac.start(HashingContext.HASH_SHA256, _verify_value.to_utf8_buffer())
	hmac.update(header_b64.to_utf8_buffer())
	return "%s|%s.%s" % [_verify_version, header_b64, Marshalls.raw_to_base64(hmac.finish())]


# ---------- вход ----------

## Сколько секунд осталось до конца паузы после ошибок входа (0 — можно пробовать).
func lock_left() -> int:
	return maxi(0, int(ceil(_locked_until - Time.get_unix_time_from_system())))


func _note_result(ok: bool) -> void:
	if ok:
		_fails = 0
		return
	_fails += 1
	if _fails >= MAX_FAILS:
		_fails = 0
		_locked_until = Time.get_unix_time_from_system() + LOCK_SEC


## Регистрация. Подтверждение по почте включено, поэтому сразу после неё
## делаем вход: Talo пришлёт код на почту, без него сессии не будет.
func register(nick: String, email: String, password: String) -> String:
	if lock_left() > 0:
		return "too_many"
	busy = true
	var res: Dictionary = await request(HTTPClient.METHOD_POST, "/v1/players/auth/register", {
		"identifier": nick, "password": password, "email": email,
		"verificationEnabled": true, "withRefresh": true})
	busy = false
	if int(res["status"]) != 200:
		_note_result(false)
		return error_text(res)
	# Сессию регистрации не используем: в топ попадают только после кода из почты
	return await login(nick, password)


## Вход. Возвращает "" (успех), "code" (ждём код из почты) или код ошибки.
func login(nick: String, password: String) -> String:
	if lock_left() > 0:
		return "too_many"
	busy = true
	_clear_local()
	var res: Dictionary = await request(HTTPClient.METHOD_POST, "/v1/players/auth/login",
		{"identifier": nick, "password": password, "withRefresh": true})
	busy = false
	if int(res["status"]) != 200:
		_note_result(int(res["status"]) == 0)   # нет сети — не ошибка пароля
		return error_text(res)
	_note_result(true)
	var b: Dictionary = res["body"]
	if b.get("verificationRequired", false):
		_verify_alias = int(b.get("aliasId", -1))
		state_changed.emit()
		return "code"
	_take_session(b)
	return ""


func verify(code: String) -> String:
	if lock_left() > 0:
		return "too_many"
	busy = true
	var res: Dictionary = await request(HTTPClient.METHOD_POST, "/v1/players/auth/verify",
		{"aliasId": _verify_alias, "code": code.strip_edges(), "withRefresh": true})
	busy = false
	if int(res["status"]) != 200:
		_note_result(int(res["status"]) == 0)
		return error_text(res)
	_note_result(true)
	_verify_alias = -1
	_take_session(res["body"])
	await submit_taps()
	return ""


func logout() -> void:
	if logged_in():
		request(HTTPClient.METHOD_POST, "/v1/players/auth/logout")
	_clear_local()
	DirAccess.remove_absolute(SESSION_PATH)
	_top_at = -1000.0
	state_changed.emit()


func _take_session(b: Dictionary) -> void:
	var alias: Dictionary = b.get("alias", {})
	alias_id = int(alias.get("id", -1))
	nickname = str(alias.get("identifier", ""))
	player_id = str((alias.get("player", {}) as Dictionary).get("id", ""))
	_session = str(b.get("sessionToken", ""))
	_save_session(str(b.get("refreshToken", "")), nickname)
	_submitted_taps = -1
	_top_at = -1000.0
	state_changed.emit()


func _clear_local() -> void:
	alias_id = -1
	player_id = ""
	nickname = ""
	_session = ""
	_verify_alias = -1


## Пароль для файла входа. Файл зашифрован, чтобы токен нельзя было просто
## прочитать из папки игры (в браузере у игр itch.io общее хранилище).
func _session_pass() -> String:
	return (key + "|capy|" + OS.get_unique_id()).sha256_text()


func _save_session(refresh: String, ident: String) -> void:
	var cfg: ConfigFile = ConfigFile.new()
	cfg.set_value("session", "refreshToken", refresh)
	cfg.set_value("session", "identifier", ident)
	cfg.save_encrypted_pass(SESSION_PATH, _session_pass())


## При запуске: обновить сессию по сохранённому токену и узнать свой профиль.
func _restore_session() -> void:
	var cfg: ConfigFile = ConfigFile.new()
	if cfg.load_encrypted_pass(SESSION_PATH, _session_pass()) != OK:
		# Старый незашифрованный файл (версия 1.2 до защиты) — прочитать и пересохранить
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
	_save_session(str(res["body"].get("refreshToken", refresh)), ident)
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
## Только игроки с настоящей регистрацией (aliasService=talo): записи от
## «опознанных» без пароля игроков, которыми мог бы спамить бот, не показываются.
func top(limit: int = 50):
	var now: float = Time.get_ticks_msec() / 1000.0
	if now - _top_at < TOP_CACHE_SEC:
		return _top_cache
	var res: Dictionary = await request(HTTPClient.METHOD_GET, "/v1/leaderboards/%s/entries?page=0&aliasService=talo" % BOARD)
	if int(res["status"]) != 200:
		return {"error": error_text(res)}
	var out: Array = []
	var pos: int = 0
	for e in res["body"].get("entries", []):
		var a: Dictionary = e.get("playerAlias", {})
		if str(a.get("service", "talo")) != "talo":
			continue   # на случай, если сервер не применил фильтр
		pos += 1
		out.append({"pos": pos, "name": str(a.get("identifier", "?")),
			"score": float(e.get("score", 0.0)), "me": int(a.get("id", -2)) == alias_id})
		if out.size() >= limit:
			break
	_top_cache = out
	_top_at = now
	return out
