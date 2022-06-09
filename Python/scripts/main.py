import numpy as np
import tensorflow as tf
from tf_agents.bandits.agents import lin_ucb_agent
from tf_agents.bandits.environments import stationary_stochastic_py_environment as sspe
from tf_agents.bandits.metrics import tf_metrics
from tf_agents.drivers import dynamic_step_driver
from tf_agents.replay_buffers import tf_uniform_replay_buffer
import matplotlib.pyplot as plt

BATCH_SZ = 2

class LinearNormalReward(object):
    """
    Class that acts as a linear reward function when called
    """
    def __init__(self, theta, sigma):
        self.theta = theta
        self.sigma = sigma
        
    def __call__(self, x):
        mu = np.dot(x, self.theta)
        return np.random.normal(mu, self.sigma)
    
    
def context_sampling_fn(batch_size):
    """
    Context from [-10, 10]^4

    Args:
        batch_size (int): Number of samples to return
    """
    def _context_sampling_fn():
        return np.random.randint(-10, 10, [batch_size, 4]).astype(np.float32)
    return _context_sampling_fn

if __name__ == "__main__":
    
    # Define the three arms of the bandit problem
    arm0_param = [-3, 0, 1, -2] # @param
    arm1_param = [1, -2, 3, 0] # @param
    arm2_param = [0, 0, 1, 1] # @param
    
    # Define the reward functions
    arm0_reward_fn = LinearNormalReward(arm0_param, 1)
    arm1_reward_fn = LinearNormalReward(arm1_param, 1)
    arm2_reward_fn = LinearNormalReward(arm2_param, 1)
    
    # Define the environment
    environment = tf_py_environment.TFPyEnvironment(
        sspe.StationaryStochasticPyEnvironment(
            context_sampling_fn(batch_size),
            [arm0_reward_fn, arm1_reward_fn, arm2_reward_fn],
            batch_size=batch_size))
    
        
    
    
    