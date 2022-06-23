import numpy as np
import matplotlib.pyplot as plt
from tqdm import tqdm
import gym
import math
import random
from collections import namedtuple, deque
import torch
import torch.nn as nn
import torch.optim as optim
import torch.nn.functional as F

# Parameters to import across the file
MAX_EPISODES = 500
MAX_ITERATIONS = 200
DEVICE = torch.device("cpu")
BATCH_SIZE = 128
GAMMA = 0.999
EPS_START = 0.9
EPS_END = 0.05
EPS_DECAY = 200
TARGET_UPDATE = 10
INPUT_SHAPE = 4
OUTPUT_SHAPE = 2
steps_done = 0

class ReplayMemory(object):
    """ReplayMemory

    Memory object that stores the previous set of experiences in the buffer. Can also return a set of memorys to be replayed and applied in the optimisation step
    """
    
    def __init__(self, capacity):
        self.memory = deque([], maxlen=capacity)
        
    def push(self, *args):
        """
        Pushes a new memory to the buffer
        
        Args:
            *args (Transition): Set of transitions consisting of (state, action, next state, reward)
        """
        self.memory.append(Transition(*args))
        
    def sample(self, batch_size):
        """
        Samples the 

        Args:
            batch_size (_type_): _description_

        Returns:
            _type_: _description_
        """
        return random.sample(self.memory, batch_size)
    
    def __len__(self):
        return len(self.memory)
    

class DQN(nn.Module):
    
    def __init__(self, inputs, outputs):
        super(DQN, self).__init__()
        self.l_input = nn.Linear(inputs, 32)
        self.hidden_1 = nn.Linear(32, 32)
        self.hidden_2 = nn.Linear(32, 32)
        self.l_output = nn.Linear(32, outputs)
        
    def forward(self, x):
        x.to(DEVICE)
        x = self.l_input(x)
        x = F.relu(x)
        x = self.hidden_1(x)
        x = F.relu(x)
        x = self.hidden_2(x)
        x = F.relu(x)
        return self.l_output(x)
    
# Initialise the transition tuple
Transition = namedtuple('Transition',
                        ('state', 'action', 'next_state', 'reward'))

# We have two nets. The first is the one trained at every time step, the second is periodically updated
policy_net = DQN(INPUT_SHAPE, OUTPUT_SHAPE).to(DEVICE)
target_net = DQN(INPUT_SHAPE, OUTPUT_SHAPE).to(DEVICE)
target_net.load_state_dict(policy_net.state_dict())

# Initialise the memory and optimisers
memory = ReplayMemory(1000)
optimizer = optim.RMSprop(policy_net.parameters())

def select_model_action(state):
    with torch.no_grad():
        return policy_net(state).max(0)[1].view(1,1)
        
        
def select_action(state):
    global steps_done
    sample = random.random()
    eps_threshold = EPS_END + (EPS_START - EPS_END) *  math.exp(-1*steps_done / EPS_DECAY)
    steps_done += 1
    if sample > eps_threshold:
        with torch.no_grad():
            return policy_net(state).max(0)[1].view(1,1)
    else:
        return torch.tensor([[random.randrange(OUTPUT_SHAPE)]], device=DEVICE, dtype=torch.long)
    
def optimise_model():
    if len(memory) < BATCH_SIZE:
        return
    transitions = memory.sample(BATCH_SIZE)
    batch = Transition(*zip(*transitions))
    non_final_mask = torch.tensor(tuple(map(lambda s: s is not None,
                                            batch.next_state)), device=DEVICE, dtype=torch.bool)
    non_final_next_states = torch.cat([s for s in batch.next_state if s is not None])
    
    state_batch = torch.cat(batch.state)
    action_batch = torch.cat(batch.action)
    reward_batch = torch.cat(batch.reward)
    
    # Compute Q(s_t, a) for the model. 
    state_action_values = policy_net(state_batch.view(-1,4)).gather(1, action_batch)
    
    # Compute V(s_{t+1}) for all the next states
    next_state_values = torch.zeros(BATCH_SIZE, device=DEVICE)
    next_state_values[non_final_mask] = target_net(non_final_next_states.view(-1,4)).max(1)[0].detach()
    
    # Compute the expected Q values
    expected_state_action_values = (next_state_values * GAMMA) + reward_batch
    
    # Compute the Huber loss
    criterion = nn.SmoothL1Loss()
    loss = criterion(state_action_values, expected_state_action_values.unsqueeze(1))
    
    optimizer.zero_grad()
    loss.backward()
    
    for param in policy_net.parameters():
        param.grad.data.clamp_(-1,1)
        
    # Step the optimiser
    optimizer.step()

def main():
    # Import the enviroment
    env = gym.make('CartPole-v1')
    env.reset()
    
    episode_durations = []
    
    for i_episode in range(MAX_EPISODES):
        
        print(f"Episode Number: {i_episode}")
        
        # Reset the env at the beginning of the episode
        obs = env.reset()
        
        for idx in tqdm(range(MAX_ITERATIONS)):
            # Convert the state and get the action
            state = torch.from_numpy(obs)
            action = select_action(state)
            
            # Step the environment with the chosen action
            state_obs, reward, done, info = env.step(action.item())
            reward = torch.tensor([reward], device=DEVICE)
            
            # Check to see if the env is done or not
            if not done:
                next_state = torch.from_numpy(state_obs)
            else:
                next_state = None
            
            # Add this information to the buffer
            memory.push(state, action, next_state, reward)
            
            # Move onto the next state and optimise the model
            obs = state_obs
            optimise_model()
            
            if done:
                episode_durations.append(idx + 1)
                break;
        if i_episode & TARGET_UPDATE == 0:
            target_net.load_state_dict(policy_net.state_dict())
        
    print("Finished training")
    env.reset()

    for idx in range(15):
        observation = env.reset()
        for t in range(MAX_ITERATIONS):
            env.render()
            state = torch.from_numpy(observation)
            action = select_model_action(state)
            observation, reward, done, info = env.step(action.item())
            
            if done:
                print(observation)
                print(f"Epsiode finished after {t+1} timesteps")
                break
    env.close()
    

if __name__ == "__main__":
    print(f"Using device {DEVICE}")
    main()
