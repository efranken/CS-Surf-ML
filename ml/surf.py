import gym
from gym import Env
from gym.spaces import Discrete, Box
import time
import math
import vgamepad as vg
import socket
import numpy as np
import threading

PAD = vg.VX360Gamepad()
HZ = 20
LENGTH_SECONDS = 10
SLEEP_TIME = 1/HZ
UDP_PORT = 27016

CURRENT_POS = None
CURRENT_DATA_LOCK = threading.lock()

class SurfEnv(gym.Env):
    def __init__(self):
        discrete_actions = gym.spaces.MultiDiscrete([2,2,2])
        continuous_actions = gym.spaces.Box(low=-1, high=1, shape=(1,))

        self.action_space = gym.spaces.Tuple([
            discrete_actions,
            continuous_actions
        ])

        low = -250
        high = 10000

        self.observation_space = gym.spaces.Box(
            low,
            high,
            shape=(4,)
        )

        self.ticknum = 0
        self.angle = 0
        self.x = 0
        self.y = 0
        self.z = 0
        self.speed = 0

        self.counter = 0
        self.action_interval = 5
    
        self.state = 1 #?  check with database to ensure this is the same?  call a method to force a reset if not?
        self.surf_length = HZ*LENGTH_SECONDS 

        udp_thread = threading.Thread(target=udp_read, daemon=True)
        udp_thread.start()
        
    def step(self, action):  # runs every time there's a step taken, a tick in this case
        info = "running"

        action = self.action_space.sample()

        action_continuous = action[1]
        action_discrete = action[0]

        current, bounds_bool, lowest_distance = dbRead()

        try:
            self.ticknum = current[0]
            self.angle = current[1]
            self.x = current[2]
            self.y = current[3]
            self.z = current[4]
            self.speed = current[5]
            self.episode = current[6]
            self.bounds = bounds_bool
            observation = np.array([self.x, self.y, self.z, self.speed])
        except:
            print("Failed to set from data, likely plugin restarted or failed")
            self.ticknum = 0
            self.angle = 0
            self.x = 0
            self.y = 0
            self.z = 0
            self.speed = 0
            self.episode = 0
            self.bounds = False
            observation = np.array([0,0,0,0])

        self.surf_length -= 1

        if self.surf_length <= 1: 
            done = True
            info = "length reset"
            self.reset()
        else:
            done = False
        
        if self.bounds == False:
            done = True
            info = "bounds reset"
            self.reset()

        move(action_discrete[0], action_discrete[1], action_discrete[2])
        look(action_continuous[0])

        reward = 1000/lowest_distance
        time.sleep(SLEEP_TIME)
        return observation, reward, done, info
        
    def render(self):
        # do a render of the path at the end of the surf, save as a jpeg
        pass

    def reset(self):
        # ensure x, y, z is at starting point
        # if not, press w for .5 s
        # then check again
        move(0,0,0)
        look(0)
        self.state = 0 #all keypresses 0, yaw, etc 0
        self.surf_length = HZ*LENGTH_SECONDS
        spawn_platform_checker = 0 # instead of getting xyz of spawn, check and see if spawn != current after 5s, then reset

        current, _, _ = dbRead()
        current_coords = [current[2], current[3], current[4]]
        spawn_coords = [0,-32,1091]
        coord_buffer = 20 # spawn doesn't always return directly to tele entity. Check this many units around x/y/z and determine spawn

        while True:
            #if any(current_coords == coord for coord in spawn_coords):
            if all(abs(current_coords[i] - spawn_coords[i]) <= coord_buffer for i in range(len(current_coords))):
                #print("current = spawn")
                self.x = current[2]
                self.y = current[3]
                self.z = current[4]
                self.speed = current[5]
                observation = np.array([self.x, self.y, self.z, self.speed])
                return observation
            else:
                current, _, _ = dbRead()
                current_coords = [current[2], current[3], current[4]]
                #print("current coords", current_coords, "spawn coords", spawn_coords)
                time.sleep(.1)
                spawn_platform_checker += 1
            
            if spawn_platform_checker >= 20: # can get stuck on spawn, so press w for .5 sec to make it fall
                #print(spawn_platform_checker)
                spawn_platform_checker = 0
                move(1,1,0)
                time.sleep(.5)
                move(0,0,0)

def dbRead():
    query_data = []
    current = []
    bounds_check = []
    bounds_bool = True

    xyz_list = []
    distance_list = []
    end_point = [-277,2924,655]

    backtest = 5

    cursor = DB.cursor()

    # Retrieve the data from the database
    query = ("SELECT ticknum, angle, x, y, z, speed, episode, bounds FROM playerloc ORDER BY writenum DESC LIMIT " + str(backtest))
    cursor.execute(query)

    row = cursor.fetchone()
    while row is not None:
        query_data.append(row)
        row = cursor.fetchone()
        current = query_data[0]

    for num in range(backtest):
        # bounds block
        bounds_check.append(query_data[num][7])
        if 0 in bounds_check:
            bounds_bool = False
        else:
            bounds_bool = True
    
        #rewards block
        xyz_list.append([query_data[num][2],query_data[num][3],query_data[num][4]])
        distance_list.append([math.sqrt((end_point[0] - xyz_list[num][0])**2 + (end_point[1] - xyz_list[num][1])**2 + (end_point[2] - xyz_list[num][2])**2)])
        lowest_distance_list = min(distance_list)
        lowest_distance = float(lowest_distance_list[0])

    return current, bounds_bool, lowest_distance


def udp_read():
    global CURRENT_POS
# Format(message, sizeof(message), "Values: %d, %d, %d, %d, %0.0f, %-.2f, %d, %d, %d, %d", i, x, y, z, posAng[1], PlayerfSpeed, TickNum, WriteNum, Bounds, 0);
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as sock:
        # Allow the socket to receive broadcast packets
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
        
        # Bind to all available network interfaces on the specified port
        sock.bind(("", UDP_PORT))
        
        while True:
            # Receive UDP packet
            data, addr = sock.recvfrom(1024)  # Buffer size is 1024 bytes
            decoded_data = data.decode('utf-8', errors='ignore')

            parsed_data = parse_udp_data(decoded_data)

            with CURRENT_DATA_LOCK():
                CURRENT_POS = parsed_data

def parse_udp_data(data):
    try:
        values = list(map(float, data.split(',')))
        # figure out how to label data here, can i zip 2 lists together
        return {
            "player_num": values[0],
            "x": values[1],
            "y": values[2],
            "z": values[3],
            "look_angle": values[4],
            "player_speed": values[5],
            "tick_num": values[6],
            "bounds": values[7]
        }

    except ValueError:
        print("Failed to parse UDP Data: ", data)
        return None
    
def move(w, a, d):
    if w == 1:
        PAD.press_button(button=vg.XUSB_BUTTON.XUSB_GAMEPAD_DPAD_UP)
    elif w == 0:
        PAD.release_button(button=vg.XUSB_BUTTON.XUSB_GAMEPAD_DPAD_UP)

    if a == 1:
        PAD.press_button(button=vg.XUSB_BUTTON.XUSB_GAMEPAD_DPAD_LEFT)
    elif a == 0:
        PAD.release_button(button=vg.XUSB_BUTTON.XUSB_GAMEPAD_DPAD_LEFT)

    if d == 1:
        PAD.press_button(button=vg.XUSB_BUTTON.XUSB_GAMEPAD_DPAD_RIGHT)
    elif d == 0:
        PAD.release_button(button=vg.XUSB_BUTTON.XUSB_GAMEPAD_DPAD_RIGHT)

    PAD.update()

def look(yaw_float):
    PAD.right_joystick_float(x_value_float=yaw_float, y_value_float=0)

    PAD.update()
