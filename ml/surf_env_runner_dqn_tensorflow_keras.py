import surf_env

# disable annoying log about oneDNN custom ops
import os
os.environ["TF_ENABLE_ONEDNN_OPTS"] = "0"

# keras imports
import numpy as np
# from tensorflow.keras.models import Sequential
# import tensorflow.keras.models
from tensorflow.keras.layers import Dense, Flatten
from tensorflow.keras.optimizers import Adam

# keras-rl imports
from rl.agents import DQNAgent
from rl.policy import BoltzmannQPolicy
from rl.memory import SequentialMemory

env = surf_env.SurfEnv()

NUMBER_OF_EPISODES = 10

def main():
    actions = env.action_space
    states = env.observation_space.shape[0]
    model = build_model(states, actions)
    dqn = build_agent(model, actions)
    dqn.compile(optimizer=Adam(lr=1e-3))
    dqn.test(env, nb_episodes=5, visualize=False)

    for episode in range(NUMBER_OF_EPISODES):
        dqn.fit(env, nb_steps=200, visualize=False, verbose=True, nb_max_episode_steps=201, log_interval=10)
        print("test")
    env.close()

def build_model(states, actions):
    model = tensorflow.keras.models.Sequential()
    model.add(Flatten(input_shape=(1, states)))
    model.add(Dense(24, activation='relu'))
    model.add(Dense(24, activation='relu'))
    model.add(Dense(np.prod(actions.spaces[0].shape) + np.prod(actions.spaces[1].shape), activation='linear'))
    return model


def build_agent(model, actions):
    policy = BoltzmannQPolicy()
    memory = SequentialMemory(limit=50000, window_length=1)
    dqn = DQNAgent(model=model, memory=memory, policy=policy,
                  nb_actions=np.prod(actions.spaces[0].shape) + np.prod(actions.spaces[1].shape), nb_steps_warmup=10, target_model_update=1e-2)
    return dqn

main()