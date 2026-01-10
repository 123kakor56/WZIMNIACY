using Godot;

public partial class EOSManagerInteropTest : Node
{
	[Export]
	public Node test;


	public override void _Ready()
	{
		// IeosInstance instance = new IeosInstance();
		// GD.Print(Ieos.Singleton);
		// RefCounted abc = (RefCounted)Engine.GetSingleton("IEOS");
		// Variant abc1 = test.Call("get_instance1");
		// IeosInstance abc2 = (IeosInstance)abc1;
		// Variant abc1 = Engine.GetSingleton("IEOS").Call("get_instance");
		// IeosInstance instance = (IeosInstance)abc;



		// Ieos.Singleton.PlatformInterfaceInitialize(new EOSStructs.InitializeOptions());
		// GD.Print(Engine.GetSingletonList());
	}


	public void InteropTest()
	{
		// EosgMultiplayerPeer a = new EosgMultiplayerPeer();
		// a.CreateClient("test", "test1");
		// Multiplayer.MultiplayerPeer = a;
		// EosgMultiplayerPeer a = (EosgMultiplayerPeer)Multiplayer.MultiplayerPeer;
		GD.Print("InteropTest peer connected (server peer id should be 1)");

		if (Multiplayer.IsServer())
    	{
        	Rpc(MethodName.PrintOncePerClient);

			Rpc(MethodName.PrintOncePerClientWithString, "WIADOMOŚĆ Z SERWERA DO WSZYSTKICH 67 420 69 DZIAŁA");
    	}
		else
		{
			Rpc(MethodName.PrintOncePerClient);

			Rpc(MethodName.PrintOncePerClientWithString, "WIADOMOŚĆ Z KLIENTA DO WSZYSTKICH 67 420 69 DZIAŁA");
		}
	}

	// CallLocal domyślne jest false ale tak dla jasności żeby pokazać
	// Peer ID serwera powinno być 1
	[Rpc(MultiplayerApi.RpcMode.AnyPeer, CallLocal = false)]
	private void PrintOncePerClient()
	{
		int senderId = Multiplayer.GetRemoteSenderId();
		GD.PrintRich("[color=red]INTEROP TEST RPC RECEIVED FROM PEER ID: " + senderId);
	}

	[Rpc(MultiplayerApi.RpcMode.AnyPeer, CallLocal = false)]
	private void PrintOncePerClientWithString(string message)
	{
		int senderId = Multiplayer.GetRemoteSenderId();
		GD.PrintRich("[color=red]INTEROP TEST RPC WITH STRING RECEIVED FROM PEER ID: " + senderId + "MESSAGE: " + message);
	}
}
