#!/usr/bin/env python
# coding: utf-8

# In[1]:


# !pip install flask-sock
# !pip install flask-cors




# !pip install asyncio
# !pip install websockets
# !pip install nest_asyncio


# In[2]:


from build.gemini_pictionary_logic import *
from lib.setInterval import setInterval



# In[3]:


from flask import Flask, render_template
from flask_sock import Sock
from flask_cors import CORS



# In[4]:


app = Flask(__name__)
cors = CORS(app)
sock = Sock(app)



# In[5]:


import nest_asyncio

nest_asyncio.apply()


# In[6]:


import json


# In[7]:


import time



# In[8]:


import asyncio
import websockets


# In[9]:


is_busy = False

question_start_time = 0
question_expose_level = -1


async def _refresh_question(client=None):

    global is_busy
    
    if is_busy == True:
        return None

    is_busy = True
    
    question_payload = await refresh_question_api_gen()
    
    is_busy = False

    
    if (question_payload["is_new"] == True):
        
        global question_start_time
        question_start_time = int(time.time())

        for c in connected_clients:
            await c.send(json.dumps({
                "on": "_refresh_question",
                "question_payload": _massage_question_payload(question_payload),
            }))

    
    if (client != None):
        await client.send(json.dumps({
            "on": "_refresh_question",
            "question_payload": _massage_question_payload(question_payload),
        }))



def _massage_question_payload(question_payload):
    return question_payload


async def _invalidate_question():
    await invalidate_question_api_gen()




# In[10]:


# def interval(name):
def interval():
    asyncio.run(_refresh_question())

# _interval = setInterval(interval, 1.5, ["Jane"]) 
_interval = setInterval(interval, 1.5) 

# _interval.stop()


# In[ ]:





# In[11]:


async def ws_on_client_connect(client):
    print(f"Client {str(client.id)} connected")
    pass

async def ws_on_client_disconnect(client):
    print(f"Client {str(client.id)} disconnected")
    client_leave(cid=str(client.id))
    pass

async def ws_on_client_message(client, message):
    dict = json.loads(message)

    r_action = dict["action"]

    # 1. game_join 
    if (r_action == "game_join"):

        r_name = dict["name"]
        
        client_join(cid=str(client.id), name=r_name)
        
        for c in connected_clients:
            await c.send(json.dumps({
                "on": r_action,
                "client": client_get(cid=str(client.id)),
            }))

        await _refresh_question(client=client)

    
    # 2. game_leave
    elif (r_action == "game_leave"):
        
        client_leave(cid=str(client.id))
        
        for c in connected_clients:
            await c.send(json.dumps({
                "on": r_action,
                "client": client_get(cid=str(client.id)),
            }))


    
    # 3. answer_submit
    elif (r_action == "answer_submit"):

        r_answer = dict["answer"]

        if is_question_invalidated():
            return
            
        
        score_delta = client_submit_answer(cid=str(client.id), answer=r_answer)

        if (score_delta > 0):
            await _invalidate_question()

        
        for c in connected_clients:
            await c.send(json.dumps({
                "on": r_action,
                "client": client_get(cid=str(client.id)),
                "score_delta": score_delta,
                "r_answer": r_answer,
            }))
        
        
    # 4. game_player_list 
    if (r_action == "game_player_list"):

        await client.send(json.dumps({
            "on": r_action,
            "clients": clients,
        }))

    



# In[ ]:


# Store all connected clients
connected_clients = set()

# Function to handle incoming messages from clients
async def handle_message(client, message):
    h()
    for c in connected_clients:
        if True or c != client:
            print(client)
            await c.send( str( client.id ) )


# Function to handle new client connections
async def handle_client(websocket, path):
    
    # Add the client to the connected_clients set
    connected_clients.add(websocket)
    await ws_on_client_connect(websocket)
    
    try:
        async for message in websocket:
            # Handle incoming message from the client
            await ws_on_client_message(websocket, message)

    finally:
        # Remove the client from the connected_clients set if they disconnect
        await ws_on_client_disconnect(websocket)
        connected_clients.remove(websocket)

# Start the server
start_server = websockets.serve(handle_client, 'localhost', 8762)

# Run the server indefinitely
print(f"Starting server.. {'localhost'} {8762}")
asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()










# In[ ]:









