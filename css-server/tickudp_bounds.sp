#include <sdktools>
#include <socket>

float playerVelocity[3];
float PlayerfSpeed;
float posAng[3];
float posCoord[3];

int x;
int y;
int z;
int Bounds = 1;
int WriteNum = 0;
int TickNum = 0;
int Episode = 0;

Handle g_BroadcastSocket;
int g_BroadcastPort = 27016; // Added missing semicolon

Handle UDPEnabled;
Handle PrintToChatEnabled;

public Plugin myinfo = {
    name = "TickPosUDP",
    author = "Richard Franks",
    description = "Writes player data to a UDP stream each tick",
    version = "1.0",
    url = "http://nkenberger.com"
};

public void OnSocketError(Handle socket, int errorType, int errorNum, any arg) {
    LogError("Socket error: %d", errorNum);
    CloseHandle(socket);
}

public void InitUDP() {
    g_BroadcastSocket = SocketCreate(SOCKET_UDP, OnSocketError);
    SocketSetOption(g_BroadcastSocket, SocketReuseAddr, true);
    SocketSetOption(g_BroadcastSocket, SocketBroadcast, true); // SO_BROADCAST = 6
}

public void OnPluginStart() {
    UDPEnabled = CreateConVar("sm_udp", "1", "1 enables UDP stream, any other disables");
    PrintToChatEnabled = CreateConVar("sm_tick_print", "0", "1 enables chat print, any other disables");
    AutoExecConfig();
    InitUDP();
}

public void OnGameFrame() {
    WriteNum++;

    for(int i = 1; i < MaxClients; i++) {
        if(IsClientInGame(i)) {
            GetEntPropVector(i, Prop_Data, "m_vecVelocity", playerVelocity);
            PlayerfSpeed = SquareRoot(playerVelocity[0]*playerVelocity[0] + playerVelocity[1]*playerVelocity[1]);
            TickNum++;
            GetClientAbsAngles(i, posAng);
            GetClientAbsOrigin(i, posCoord);

            x = RoundFloat(posCoord[0]);
            y = RoundFloat(posCoord[1]);
            z = RoundFloat(posCoord[2]);

            char message[256]; // Fixed declaration
            
            if(validate_surf_bounds(x, y, z)) {
                Bounds = 1;
                if(GetConVarInt(PrintToChatEnabled) == 1) {
                    PrintToChat(i, "IB");
                }
            
                if(GetConVarInt(UDPEnabled) == 1) {
                    // id, x, y, z, angle, speed, ticknum, writenum, bounds, episode
                    Format(message, sizeof(message), "Values: %d, %d, %d, %d, %0.0f, %-.2f, %d, %d", i, x, y, z, posAng[1], PlayerfSpeed, TickNum, Bounds);
                    
                    SendUDPData(message); // Pass query directly
                    PrintToConsole(i, "wrote to UDP with %s", message);
                }
            }
            else {
                Bounds = 0;
                TickNum = 0;
                Episode++;

                if(GetConVarInt(PrintToChatEnabled) == 1) {
                    PrintToChat(i, "OOB");
                }
            
                if(GetConVarInt(UDPEnabled) == 1) {
                    Format(message, sizeof(message), "Values: %d, %d, %d, %d, %0.0f, %-.2f, %d, %d, %d, %d", i, x, y, z, posAng[1], PlayerfSpeed, TickNum, WriteNum, Bounds, 0);
                    
                    SendUDPData(message); // Pass query directly
                    PrintToConsole(i, "wrote to UDP with %s", message);
                }
                teleport_player(i);
            }
        }
    }
}

// Fixed function signature
public void SendUDPData(const char[] broadcastData) {
    if(g_BroadcastSocket != INVALID_HANDLE) {
        SocketSendTo(g_BroadcastSocket, broadcastData, strlen(broadcastData), "255.255.255.255", g_BroadcastPort);
    }
}

public teleport_player(entity) {
    float teleCoord[3];
    teleCoord[0] = 0.0;     //x
    teleCoord[1] = -32.0;  //y
    teleCoord[2] = 1120.0;  //z

    float teleAngle[3];
    teleAngle[0] = 0.0;     //x
    teleAngle[1] = 90.0;     //y
    teleAngle[2] = 0.0;     //z

    float teleVelocity[3];
    teleVelocity[0] = 0.0;  //x
    teleVelocity[1] = 0.0;  //y
    teleVelocity[2] = 0.0;  //z

    TeleportEntity(entity, teleCoord, teleAngle, teleVelocity);
}

public validate_surf_bounds(a, b, c) { 
    int xLow  = -528;
    int xHigh = 7;
    int yLow  = -65;
    int yHigh = 3266;
    int zLow  = 285;
    int zHigh = 1130;

    if ((a > xLow && a < xHigh) &&
        (b > yLow && b < yHigh) &&
        (c > zLow && c < zHigh))
    {
        return true;
    }

    else
    {
        return false;
    }
}
