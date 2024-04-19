#!/usr/bin/env python
# coding: utf-8

# In[1]:


# Gemini Pictionary


# In[2]:


try:
  r_question_arr = r_question_arr if r_question_arr != None else []
except:
  r_question_arr = []

try:
  r_answer_arr = r_answer_arr if r_answer_arr != None else []
except:
  r_answer_arr = []


# In[3]:


try:
  clients = clients if clients != None else {}
except:
  clients = {}


# In[4]:


clients


# In[3]:


# !pip install requests
# !pip install aiohttp


# In[11]:


import requests
import json
import base64
import aiohttp


# In[12]:


async def obtain_image_and_base64():

    # API endpoint URL
    url = "https://picsum.photos/200/300"


    # Send GET request to the API using async/await
    async with aiohttp.ClientSession() as session:
        try:
            async with session.get(url) as response:
                if response.status != 200:
                    raise Exception(f"Image download failed with status code: {response.status}")

                image_data = await response.read()
                image_base64 = base64.b64encode(image_data).decode()
        except aiohttp.ClientError as e:
            raise Exception(f"Error occurred during image download: {str(e)}")
    
    return (image_data, image_base64)



# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[1]:


async def obtain_gemini_response_json_from_image_prompt(base64_image):

    # API endpoint URL
    api_url_gemini_imageprompt = "https://flutter-tom-ws.www.vanportdev.com:28888/v1beta/models/gemini-pro-vision:generateContent?key=AIzaSyCtDrJvZz3ioVTww-IVY2x1WL9WoFLRluw"


    # POST body
    payload = {
        "contents": [
            {
                "role": "user",
                "parts": [
                    {
                        "text": """Assume you are the game master of \"Guess the object\" who creates questions. \n
                        Could you return me a JSON format to contain: {
                            "descriptions": 5 separate short sentences describing the object (in the form of an array of strings),
                            "answers": 5 possible name(s) of the object (in the form of an array of strings, in descending order of answer relevance)
                        }
                        ?
                        The rule is: your description sentence should prevent using the same words as your answers.
                        """,
                    },
                    {
                        "inline_data": {
                            "mime_type": "image/jpeg",
                            "data": base64_image,
                        }
                    }
                ]
            }
        ]
    }
    

    headers = {
        "Content-Type": "application/json"
    }

    # payload


    # Send POST request to the API

    # Send GET request to the API using async/await
    async with aiohttp.ClientSession() as session:
        try:
            async with session.post(api_url_gemini_imageprompt, json=payload, headers=headers) as response:
                if response.status != 200:
                    raise Exception(f"Error: Failed to generate content. Status code: {response.status_code}")

                # Extract the JSON response from the content
                response_json = await response.json()
        except aiohttp.ClientError as e:
            raise Exception(f"Error: Failed to generate content {str(e)}")
    
    return response_json



# In[ ]:





# In[18]:


# image_data, image_base64 = await obtain_image_and_base64()
# response_json = await obtain_gemini_response_json_from_image_prompt(image_base64)
# response_json


# In[ ]:





# In[ ]:





# In[ ]:





# In[9]:


def parse_for_question_answer_bundle_from_gemini_response_json(response_json):
  try:
    r_candidates = response_json["candidates"]
    r_candidate = r_candidates[0]

  except:
    raise Exception(f"no_candidates: {response_json}")


  try:
    r_parts = r_candidate["content"]["parts"]
    r_part = r_parts[0]
  except:
    raise Exception(f"no_candidate_content: {response_json}")

  # r_part
  try:
    r_texts = r_part["text"]
    r_texts_json = json.loads(r_texts)
  except:
    raise Exception(f"no_candidate_content_text: {response_json}")

  #r_texts_json

  try:
    r_question_arr = r_texts_json["descriptions"]
    r_answer_arr = r_texts_json["answers"]
    return (r_question_arr, r_answer_arr)
  except:
    raise Exception(f"json_format_invalid: {response_json}")


# In[20]:


is_valid_question = False

image_data = None
base64_image = None
response_json = None
r_question_arr = None
r_answer_arr = None

async def invalidate_question_api_gen():
    global is_valid_question
    is_valid_question = False

def is_question_invalidated():
    return is_valid_question == False

async def refresh_question_api_gen():
    global image_data
    global base64_image
    global response_json
    global r_question_arr
    global r_answer_arr

    global is_valid_question 

    is_new = False
    
    if is_valid_question == False:
        
        image_data, base64_image = await obtain_image_and_base64()
        response_json = await obtain_gemini_response_json_from_image_prompt(base64_image)
        r_question_arr, r_answer_arr = parse_for_question_answer_bundle_from_gemini_response_json(response_json)
        
        is_valid_question = True
        is_new = True
        
    return {
        "is_new": is_new,
        "base64_image": base64_image,
        "response_json": response_json,
        "r_question_arr": r_question_arr, 
        "r_answer_arr": r_answer_arr,
    }



# In[11]:


# refresh_question_api_gen()


# In[12]:


# from PIL import Image
# from IPython.display import display
# import io
# from io import BytesIO


# img = Image.open(BytesIO(image_data))

# display(img)



# In[13]:


# r_question_arr


# In[14]:


# r_answer_arr


# In[15]:


import random
import string

def _gen_random_str():

  # Define the length of the random string
  length = 16

  # Generate a random string
  random_string = ''.join(random.choices(string.ascii_letters + string.digits, k=length))
  return random_string


# In[16]:


import random




def client_join(cid=None, name=None):
  global clients

  if (cid == None):
    cid = _gen_random_str()

  clients[cid] = clients[cid] if cid in clients else {}
  clients[cid]["id"] = cid
  name = name if name != None else (clients[cid]["name"] if "name" in clients[cid] else None)
  name = name if name != None else f"Guest{random.randint(0, 100000)}"
  clients[cid]["name"] = name
  clients[cid]["score"] = clients[cid]["score"] if "score" in clients[cid] else 0

  return cid

def client_get(cid):
  return clients[cid]



# In[17]:


def client_leave(cid):
  global clients

  if (cid == None):
    raise Exception("cid_null")

  del clients[cid]


# In[18]:


def client_submit_answer(cid, answer):
  lc_answer_arr = [element.lower() for element in r_answer_arr]
  lc_answer = answer.lower()

  if (lc_answer in lc_answer_arr):
    client_add_score(cid, +10)
    return +10
  return 0


# In[19]:


def client_add_score(cid, delta):
  client_update_score(cid, clients[cid]["score"] + delta)


# In[20]:


def client_update_score(cid, score):
  global clients
  clients[cid]["score"] = score


# In[21]:


def load_question():
  global r_question_arr
  global r_answer_arr
  r_question_arr, r_answer_arr = refresh_question_api_gen()


# In[22]:


def on_client_answer_correctly(cid, answer):
  pass


# In[23]:


def print_clients():
  return clients



# In[ ]:







# In[1]:


# print_clients()


# In[ ]:





# In[25]:


# load_question()


# In[26]:


# cid = client_join()


# In[27]:


# print_clients()


# In[28]:


# client_leave("r9fqjBGq0I5tznzl")
# client_leave("LvLRuT4fNUqv1jz3")


# In[29]:


# r_question_arr[0]


# In[30]:


# r_question_arr[1]


# In[31]:


# r_question_arr[2]


# In[32]:


# r_answer_arr[0]


# In[33]:


# r_answer_arr[1]


# In[34]:


# r_answer_arr[2]


# In[35]:


# client_submit_answer("cxjiyxK4uM3bEHqG", "train station")


# In[36]:


# clients


# In[ ]:




