import surf_env

# Disable annoying log about oneDNN custom ops
import os
os.environ["TF_ENABLE_ONEDNN_OPTS"] = "0"

# Stable-Baselines3 imports
from stable_baselines3 import DQN
from stable_baselines3.common.env_util import make_vec_env
from stable_baselines3.common.callbacks import EvalCallback

# Other imports
# import numpy as np

# Create the environment
env = surf_env.SurfEnv()

# Hyperparameters
NUMBER_OF_EPISODES = 10
LEARNING_RATE = 1e-3
BUFFER_SIZE = 50000
BATCH_SIZE = 64
GAMMA = 0.99
TARGET_UPDATE_INTERVAL = 1000
EXPLORATION_FRACTION = 0.1
EXPLORATION_FINAL_EPS = 0.02

def main():
    # Create the DQN agent
    model = DQN(
        "MlpPolicy",
        env,
        learning_rate=LEARNING_RATE,
        buffer_size=BUFFER_SIZE,
        batch_size=BATCH_SIZE,
        gamma=GAMMA,
        target_update_interval=TARGET_UPDATE_INTERVAL,
        exploration_fraction=EXPLORATION_FRACTION,
        exploration_final_eps=EXPLORATION_FINAL_EPS,
        verbose=1,
        tensorboard_log="./dqn_surf_env_tensorboard/",  
        # tensorboard --logdir=./dqn_surf_env_tensorboard/
        # http://localhost:6006
    )

    # Set up the evaluation callback
    eval_env = make_vec_env(lambda: surf_env.SurfEnv(), n_envs=1)
    eval_callback = EvalCallback(
        eval_env,
        best_model_save_path="./best_model/",
        log_path="./logs/",
        eval_freq=1000,
        deterministic=True,
        render=False,
    )

    # Train the agent
    for episode in range(NUMBER_OF_EPISODES):
        print(f"running episode {episode}")
        model.learn(total_timesteps=200, callback=eval_callback, reset_num_timesteps=False)
        print(f"Episode {episode + 1} completed")

    # Save the final model
    model.save("dqn_surf_env_final")

    # Test the agent
    obs = env.reset()
    for _ in range(1000):
        action, _states = model.predict(obs, deterministic=True)
        obs, rewards, dones, info = env.step(action)
        env.render()  # Render the environment
        if dones:
            obs = env.reset()

    # Close the environment
    env.close()

if __name__ == "__main__":
    main()