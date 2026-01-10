# Test Lobby Searcha na Lobby zrobionym przez SDK C#
# Wymaga Platformy i zalogowanego użytkownika na Addonie
# ~~konsultant Godotowcowy

extends Node

@export var CSNode: Node

@export var ClientJoinUI: Control
@export var RemoteUserIdLineEdit: LineEdit

@export var StartServer: bool

# SocketId to nie jest ID żadnego usera bo mi się tak wydawało z jakiegoś powodu, to trochę taki bucket
@export var SocketId: String

@export var RemoteUserId: String

var EOSGpeer: EOSGMultiplayerPeer
# var isReady: bool

# Called when the node enters the scene tree for the first time.
func CreateAndLoginGDEOS() -> void:
	var init_opts = EOS.Platform.InitializeOptions.new()
	init_opts.product_name ="WZIMniacy"
	init_opts.product_version ="1.0"


	var create_opts = EOS.Platform.CreateOptions.new()

	create_opts.product_id ="e0fad88fbfc147ddabce0900095c4f7b"
	create_opts.sandbox_id="ce451c8e18ef4cb3bc7c5cdc11a9aaae"
	create_opts.client_id="xyza7891eEYHFtDWNZaFlmauAplnUo5H"
	create_opts.client_secret="xD8rxykYUyqoaGoYZ5zhK+FD6Kg8+LvkATNkDb/7DPo"
	create_opts.deployment_id="0e28b5f3257a4dbca04ea0ca1c30f265"

	EOS.Logging.set_log_level(
		EOS.Logging.LogCategory.AllCategories,
		EOS.Logging.LogLevel.VeryVerbose
	)
	IEOS.logging_interface_callback.connect(log_eos)

	#IEOS.platform_interface_create(create_opts);
	EOS.Platform.PlatformInterface.initialize(init_opts);
	EOS.Platform.PlatformInterface.create(create_opts);

	var device_id_options = EOS.Connect.CreateDeviceIdOptions.new()
	device_id_options.device_model = "WZIM PHONE"
	EOS.Connect.ConnectInterface.create_device_id(device_id_options)

	var login_options = EOS.Connect.LoginOptions.new()
	var credentials = EOS.Connect.Credentials.new()
	var user_login_info = EOS.Connect.UserLoginInfo.new()

	credentials.type = EOS.ExternalCredentialType.DeviceidAccessToken
	credentials.token = null

	user_login_info.display_name = "wzimniac_player"

	login_options.credentials = credentials
	login_options.user_login_info = user_login_info

	EOS.Connect.ConnectInterface.login(login_options)

	print(EOSGRuntime.local_product_user_id)

	EOS.get_instance().connect_interface_login_callback.connect(_on_connect_login_callback)



func _on_connect_login_callback(DictionaryVar):
	print_rich(str(OS.has_feature("server"), "[color=red][GD EOS LOGIN] Result: ", DictionaryVar))
	print_rich(str(OS.has_feature("server"), "[color=red][GD EOS LOGIN] LocalProdutUserID: ", EOSGRuntime.local_product_user_id))

	EOSGpeer = EOSGMultiplayerPeer.new()
	# print(EOSGpeer)
	# isReady = true

	if StartServer || OS.has_feature("server"):
		print_rich("[color=red]STARTING AND CREATING SERVER")
		StartServer = true
		EOSGpeer.create_server(SocketId)
		multiplayer.multiplayer_peer = EOSGpeer
	elif !StartServer || OS.has_feature("client"):
		print_rich(OS.has_feature("server"), "[color=red]STARTING CLIENT")
		# UserSocketId = "test2"
		# RemoteUserId = EOSGRuntime.local_product_user_id
		# await get_tree().create_timer(20).timeout
		# EOSGpeer.create_client(SocketId, RemoteUserId)
		ClientJoinUI.visible = true

	# var EOSGpeer = EOSGMultiplayerPeer.new()
	# EOSGpeer.create_client("test", "test")
	# multiplayer.multiplayer_peer = EOSGpeer

	# NIE ŁĄCZYĆ SYGNAŁÓW Z PEERA BO MAJĄ JAKIEŚ PROBLEMY ZE SOBĄ I NIGDZIE NIE MA TEGO UDOKUMENTOWANEGO,
	# GUBIĄ PIERWSZE RPC BO NIE WIDZĄ PEERÓW PRZEZ CHWILĘ
	# CZASAMI, ZALEŻNIE OD JAKICHŚ MILISEKUNDOWYCH RÓŻNIC CZY KIJ WIE CZEGO
	# https://github.com/godotengine/godot/issues/67305
	# EOSGpeer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_connected.connect(_on_peer_connected)

	# CSNode.InteropTest()
	#pass

func _on_peer_connected(peerId):
	print_rich(str(OS.has_feature("server"), "[color=red]Peer connected with ID: ", peerId))
	CSNode.InteropTest()
	# pass

func _on_join_remote_user_id_pressed() -> void:
	if EOSGpeer.get_connection_status() == EOSGpeer.ConnectionStatus.CONNECTION_DISCONNECTED:
		RemoteUserId = RemoteUserIdLineEdit.text
		print_rich(str(OS.has_feature("server"), "[color=red]Trying to connect to a server with UserId: ", RemoteUserId, " using SocketId: ", SocketId))
		EOSGpeer.create_client(SocketId, RemoteUserId)
		multiplayer.multiplayer_peer = EOSGpeer
	else:
		print_rich("[color=red]Already trying to connect or already connected")
	# pass # Replace with function body.



# ADDON MA DOMYŚLNIE WŁĄCZONĄ AUTOAKCEPTACJĘ
# func _process(delta: float) -> void:
# 	# print(EOSGpeer)
# 	if isReady:
# 		EOSGpeer.accept_all_connection_requests()

func log_eos(log_message: Dictionary) -> void:
	#print_rich("[color=red]" + log_message.category);
	print_rich("[color=yellow]" + log_message.message)
	#pass





# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#IEOS.tick()
	#pass


func _on_create_lobby_3_pressed() -> void:
	var search_options = EOS.Lobby.CreateLobbySearchOptions.new()
	#search_options.max_results = 25

	var lobby_search_result = EOS.Lobby.LobbyInterface.create_lobby_search(
		search_options
	)
	var lobby_search: EOSGLobbySearch = lobby_search_result.lobby_search

	#var lobby_search_options = EOS.Lobby.CreateLobbySearchOptions.new()
	#var local_product_user_id = get_node("/root/EOSManager").localProductUserIdString
	var local_product_user_id = EOSGRuntime.local_product_user_id
	var current_lobby_id = get_node("/root/EOSManager").currentLobbyId
	print(current_lobby_id + "WZIM")
	lobby_search.set_parameter("bucket", "DefaultBucket", EOS.ComparisonOp.Equal)

	#lobby_search.set_lobby_id(current_lobby_id)
	#var set_parameter_options = EOS.Lobby.lobby

	#lobby_search.set_target_user_id(abc)
	#print(local_product_user_id)
	var count: int = lobby_search.get_search_result_count()
	print(str(count) + "WZIMIACprzedprzed")

	lobby_search.find(local_product_user_id)

	count = lobby_search.get_search_result_count()
	print(str(count) + "WZIMNIACprzed")

	#var search_ret = await IEOS.lobby_search_find_callback
	await IEOS.lobby_search_find_callback

	count = lobby_search.get_search_result_count()
	#print(lobby_search_result.lobby_search)
	print(str(count) + "WZIMNIACpo")
