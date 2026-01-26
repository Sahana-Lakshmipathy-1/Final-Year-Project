import boto3
import json
import os
import logging
import datetime
from google import genai
from google.genai import types
from decimal import Decimal
import uuid


# --- CONFIGURATION ---
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS Clients
dynamodb = boto3.resource("dynamodb", region_name="us-east-2") 

# Table Resources
exercise_table = dynamodb.Table("Exercise_Routine")
meal_table = dynamodb.Table("Meal_Routine") 
user_table = dynamodb.Table("Users")
wellness_table = dynamodb.Table("Wellness")
reflection_table = dynamodb.Table("Reflections")
first_aid_table = dynamodb.Table('FirstAid_Bot')
wellness_bot_table = dynamodb.Table('Wellness_Bot')

# Initialize Gemini Client (New SDK)
client = genai.Client(api_key=os.environ.get("GOOGLE_API_KEY"))

# Setup WebSocket Client (Ensure WS_API_ENDPOINT env var is set)
apigw = boto3.client(
    "apigatewaymanagementapi",
    endpoint_url=os.environ.get("WS_API_ENDPOINT")
)

# --- HELPER FUNCTIONS ---
def convert_floats_to_decimals(obj):
    """
    Recursively converts float values to Decimal for DynamoDB compatibility.
    """
    if isinstance(obj, float):
        return Decimal(str(obj))
    elif isinstance(obj, dict):
        return {k: convert_floats_to_decimals(v) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [convert_floats_to_decimals(i) for i in obj]
    return obj

def get_user_conditions(email):
    """Fetches user medical conditions using EMAIL as the Partition Key."""
    try:
        response = user_table.get_item(Key={'email': email})
        item = response.get("Item")
        if item:
            conditions = item.get("conditions", [])
            return list(conditions) if isinstance(conditions, set) else conditions
        return []
    except Exception as e:
        logger.error(f"DB Error fetching conditions for {email}: {e}")
        return []

# --- JOB HANDLERS ---

def generate_weekly_routine(message_body):
    """Generates Workout Routine with Strict JSON & Title"""
    routine_id = message_body.get("routine_id")
    user_id = message_body.get("user_id") 
    user_request = message_body.get("user_request")
    
    logger.info(f"STARTING AI Generation for Routine: {routine_id}")

    db_conditions = get_user_conditions(user_id) 
    
    user_profile = {k: v for k, v in user_request.items() if k not in ["event_type", "user_id"]}
    user_profile["medical_conditions"] = db_conditions

    # ✅ STRICT SYSTEM PROMPT
    # We define the exact keys we need.
    system_instruction = """
    You are an elite fitness coach. Generate a JSON workout routine for one week.
    
    INPUT DATA:
    - User Profile: Check 'training_days', 'conditions', 'equipment'.
    
    OUTPUT FORMAT:
    You must return a single JSON object with EXACTLY these keys:
    {
      "title": "String (A short, motivating name for this routine, e.g., 'Anxiety Relief Flow')",
      "routine_summary": "String (A 2-sentence overview)",
      "weekly_schedule": [
        {
          "day": "Monday",
          "exercises": [
             { "name": "Squat", "sets": 3, "reps": "10", "rest": "60s" }
          ]
        }
      ]
    }
    
    RULES:
    1. 'weekly_schedule' must be a LIST, not a dictionary.
    2. Do not wrap the output in markdown code blocks (no ```json).
    """

    try:
        # ✅ SINGLE GENERATION CALL
        response = client.models.generate_content(
            model="gemini-2.5-flash-lite",
            contents=f"User Profile: {json.dumps(user_profile)}",
            config=types.GenerateContentConfig(
                system_instruction=system_instruction,
                response_mime_type="application/json" # Enforces JSON syntax
            )
        )
        
        # --- Clean Markdown (Just in case) ---
        raw_text = response.text
        if "```" in raw_text:
            raw_text = raw_text.replace("```json", "").replace("```", "").strip()
        
        generated_content = json.loads(raw_text)
        logger.info("AI Generation Successful")

        # --- 3. EXTRACT AI TITLE ---
        # Fallback to "My Workout Routine" only if AI fails
        ai_generated_title = generated_content.get("title", "My Workout Routine")

        # --- Robust Parsing ---
        weekly_schedule = generated_content.get("weekly_schedule", [])

        if isinstance(weekly_schedule, dict):
            logger.warning("AI returned dict instead of list. Converting...")
            weekly_schedule = list(weekly_schedule.values())

        final_schedule = []
        for day in weekly_schedule:
            if not isinstance(day, dict):
                continue 

            exercises = day.get("exercises", [])
            
            if isinstance(exercises, list):
                for exercise in exercises:
                    if isinstance(exercise, dict):
                        exercise["completed"] = "No" 
                        
            final_schedule.append(day)

        # Construct Final Object
        current_time = datetime.datetime.utcnow().isoformat()
        
        final_routine = {
            "routine_id": routine_id, 
            "user_id": user_id,
            "status": "COMPLETED",
            "title": ai_generated_title, # ✅ SAVED TO DB
            "routine_summary": generated_content.get("routine_summary", "General Fitness"),
            "weekly_schedule": final_schedule,
            "user_conditions_considered": db_conditions,
            "created_at": current_time, 
            "generation_type": "ai_generated"
        }

        # 🚨 DEBUG LOGS (To confirm it works)
        logger.info(f" [DEBUG] Saving Title: {ai_generated_title}")

        # Save to DB
        # Ensure convert_floats_to_decimals doesn't strip keys!
        item_to_save = convert_floats_to_decimals(final_routine)
        exercise_table.put_item(Item=item_to_save)
        
        logger.info(f"Routine {routine_id} saved successfully.")

    except Exception as e:
        logger.error(f"AI Generation Failed: {str(e)}")
        try:
            exercise_table.update_item(
                Key={"routine_id": routine_id},
                UpdateExpression="SET #s = :status",
                ExpressionAttributeNames={"#s": "status"},
                ExpressionAttributeValues={":status": "FAILED"}
            )
        except:
            pass
        raise e

def generate_weekly_meal_plan(message_body):
    """Generates Meal Plan with Strict JSON & AI-Generated Title"""
    meal_routine_id = message_body.get("meal_routine_id")
    user_id = message_body.get("user_id") 
    user_request = message_body.get("user_request")

    logger.info(f"STARTING AI Meal Gen: {meal_routine_id}")

    user_profile = {k: v for k, v in user_request.items() if k not in ["event_type", "user_id"]}

    # ✅ STRICT SYSTEM PROMPT
    # We define the exact keys we need, including 'title'.
    system_instruction = """
    You are an expert nutritionist. Generate a JSON weekly meal plan.
    
    INPUT ANALYSIS: Respect 'allergies', match 'calorie_target'/'macros', use 'cuisine_preferences'.
    
    OUTPUT FORMAT:
    You must return a single JSON object with EXACTLY these keys:
    {
      "title": "String (A short, appetizing name, e.g., 'Mediterranean Detox Week')",
      "plan_summary": "String (Overview of the diet strategy)",
      "weekly_meals": [
        {
          "day_name": "Monday",
          "meals": [
             { 
               "meal_name": "Breakfast", 
               "description": "Oatmeal with berries", 
               "ingredients": ["Oats", "Blueberries", "Honey"] 
             }
          ]
        }
      ]
    }
    
    RULES:
    1. 'weekly_meals' must be a LIST of daily objects.
    2. Do not wrap the output in markdown code blocks (no ```json).
    """

    try:
        # ✅ SINGLE GENERATION CALL
        response = client.models.generate_content(
            model="gemini-2.5-flash-lite", 
            contents=f"Client Profile: {json.dumps(user_profile)}",
            config=types.GenerateContentConfig(
                system_instruction=system_instruction,
                response_mime_type="application/json"
            )
        )
        
        # --- Clean Markdown ---
        raw_text = response.text
        if "```" in raw_text:
            raw_text = raw_text.replace("```json", "").replace("```", "").strip()

        generated_content = json.loads(raw_text)
        logger.info("AI Meal Generation Successful")

        # --- 3. EXTRACT AI TITLE ---
        ai_generated_title = generated_content.get("title", "My Healthy Meal Plan")

        # --- Robust Parsing & Injection ---
        weekly_meals = generated_content.get("weekly_meals", [])

        if isinstance(weekly_meals, dict):
            logger.warning("AI returned dict instead of list. Converting...")
            weekly_meals = list(weekly_meals.values())

        final_meal_schedule = []
        for day in weekly_meals:
            if not isinstance(day, dict):
                continue

            meals_list = day.get("meals", [])
            
            if isinstance(meals_list, list):
                for meal in meals_list:
                    if isinstance(meal, dict):
                        # ✅ MANUALLY INJECT COMPLETED FIELD
                        meal["completed"] = "No" 
                        
                        # Ensure ingredients is a list
                        if "ingredients" not in meal:
                            meal["ingredients"] = []
                        elif isinstance(meal["ingredients"], str):
                            meal["ingredients"] = [meal["ingredients"]]

            final_meal_schedule.append(day)

        # Construct Final Object
        current_time = datetime.datetime.utcnow().isoformat()
        
        final_routine = {
            "meal_routine_id": meal_routine_id,
            "user_id": user_id,
            "status": "COMPLETED",
            "title": ai_generated_title, # ✅ SAVED TO DB
            "created_at": current_time, 
            "generation_type": "ai_generated",
            "plan_summary": generated_content.get("plan_summary", "Healthy Eating"),
            "weekly_meals": final_meal_schedule
        }

        # 🚨 DEBUG LOG
        logger.info(f" [DEBUG] Saving Meal Plan Title: {ai_generated_title}")

        # Save to DB
        meal_table.put_item(Item=convert_floats_to_decimals(final_routine))
        logger.info(f"Meal Plan {meal_routine_id} saved.")

    except Exception as e:
        logger.error(f"Meal AI Failed: {str(e)}")
        try:
            meal_table.update_item(
                Key={"meal_routine_id": meal_routine_id},
                UpdateExpression="SET #s = :status",
                ExpressionAttributeNames={"#s": "status"},
                ExpressionAttributeValues={":status": "FAILED"}
            )
        except:
            pass
        raise e

def get_history_from_dynamodb(table, session_id):
    try:
        response = table.get_item(Key={'session_id': session_id})
        item = response.get('Item', {})
        raw_history = item.get('history', [])
        
        gemini_history = []
        for msg in raw_history:
            role = 'model' if msg.get('role') == 'assistant' else 'user'
            content = msg.get('content', '')
            
            if content:
                gemini_history.append({
                    "role": role,
                    "parts": [{"text": content}] 
                })
        return gemini_history
    except Exception as e:
        logger.error(f"Error fetching history: {e}")
        return []

def generate_wellness_reflection(message_body):
    user_id = message_body.get("user_id") # Email
    reflection_id = message_body.get("reflection_id")
    journal_id = message_body.get("journal_id") 
    
    logger.info(f"STARTING Deep Reflection for Journal: {journal_id}")

    if not journal_id:
        logger.error("Journal ID is None. Cannot proceed.")
        return

    # --- STEP 1: FETCH CONTEXT ---
    user_profile = {}
    try:
        # CRITICAL FIX: Changed Key from 'user_id' to 'email'
        response = user_table.get_item(Key={'email': user_id})
        if 'Item' in response:
            user_data = response['Item']
            user_profile = {
                "name": user_data.get("name"),
                "primary_goal": user_data.get("primary_goal"),
                "conditions": user_data.get("conditions", []), 
                "core_values": user_data.get("core_values", ["health", "balance", "growth"]) 
            }
    except Exception as e:
        logger.error(f"User Fetch Error: {e}")

    # --- STEP 2: FETCH SPECIFIC JOURNAL ENTRY ---
    journal_entry = {}
    try:
        response = wellness_table.get_item(Key={'journal_id': journal_id})
        journal_entry = response.get('Item')
        
        if not journal_entry:
            logger.error(f"Journal Entry not found: {journal_id}")
            raise ValueError(f"Journal entry {journal_id} not found")

    except Exception as e:
        logger.error(f"Log Fetch Error: {e}")
        reflection_table.update_item(
            Key={'reflection_id': reflection_id},
            UpdateExpression="SET #s = :status",
            ExpressionAttributeNames={"#s": "status"},
            ExpressionAttributeValues={":status": "FAILED"}
        )
        return

    # --- STEP 3: PREPARE PROMPT ---
    system_instruction_text = """
    You are an advanced psychological wellness AI.
    TASK: Analyze the user's daily journal entry. Diagnose.
    Infer "Values Alignment", "Triggers", and "Coping Strategies".
    OUTPUT FORMAT (Strict JSON):
    {
      "mood_trend": { "score": 8.3, "summary": "String" },
      "sleep_impact": { "insight": "String", "tip": "String" },
      "exercise_impact": { "insight": "String", "momentum_score": "String" },
      "nutrition_impact": { "insight": "String", "tip": "String" },
      "lessons_learned": "String",
      "triggers": ["String"],
      "coping_strategies_used": ["String"],
      "values_alignment": { "score": 3, "note": "String" },
      "confidence_level": 7,
      "action_plan_next_day": "String",
      "commitment": true,
      "emotion_complexity": ["String"],
      "body_sensation_notes": "String",
      "ai_generated_summary": "String",
      "support_needed": "String",
      "trend_flags": ["String"]
    }
    """

    user_content_text = f"""
    USER PROFILE:
    - Goals: {user_profile.get('primary_goal')}
    - Known Conditions: {user_profile.get('conditions')}
    - Core Values: {user_profile.get('core_values')}
    
    TODAY'S JOURNAL DATA:
    {json.dumps(journal_entry, default=str)}
    """

    # --- STEP 4: CALL GEMINI ---
    try:
        response = client.models.generate_content(
            model="gemini-2.5-flash-lite", 
            contents=user_content_text,
            config=types.GenerateContentConfig(
                system_instruction=system_instruction_text,
                response_mime_type="application/json"
            )
        )
        
        raw_result = json.loads(response.text)
        
        # Helper to fix floats for DynamoDB
        analysis_result = convert_floats_to_decimals(raw_result)

        # --- STEP 5: SAVE FINAL REFLECTION ---
        reflection_table.put_item(
            Item={
                "reflection_id": reflection_id, 
                "journal_id": journal_id,       
                "user_id": user_id,
                "event_type": "daily_reflection",
                "created_at": datetime.datetime.utcnow().isoformat(),
                "status": "COMPLETED",
                "payload": analysis_result 
            }
        )
        logger.info(f"Deep Reflection saved: {reflection_id}")

    except Exception as e:
        logger.error(f"AI Reflection Failed: {e}")
        reflection_table.update_item(
            Key={'reflection_id': reflection_id},
            UpdateExpression="SET #s = :status",
            ExpressionAttributeNames={"#s": "status"},
            ExpressionAttributeValues={":status": "FAILED"}
        )
        raise e
    

def handle_chat_answer(message_body):
    connection_id = message_body.get("connection_id")
    session_id = message_body.get("session_id")
    question = message_body.get("question")
    bot_type = message_body.get("bot_type") 
    
    # ⚠️ CRITICAL: Ensure your apigw client is initialized with the endpoint_url
    # Example: apigw = boto3.client('apigatewaymanagementapi', 
    #              endpoint_url='https://your-api-id.execute-api.us-east-2.amazonaws.com/production')

    logger.info(f"Streaming Answer | Bot: {bot_type} | Session: {session_id} | Connection: {connection_id}")

    # 1. ROUTING & PERSONA SELECTION
    if bot_type == "first_aid":
        target_table = first_aid_table
        system_instruction = (
            "You are a First Aid AI assistant. Provide immediate, safety-first, medical guidance. "
            "Keep answers concise, actionable, and calm. Always advise calling emergency services for serious issues."
        )
    elif bot_type == "wellness":
        target_table = wellness_bot_table
        system_instruction = (
            "You are a Mental Wellness Companion. Be empathetic, supportive, and active listening. "
            "Offer gentle coping strategies and validation. Do not give medical diagnoses."
        )
    else:
        logger.error(f"Unknown bot_type '{bot_type}'")
        return

    # 2. FETCH HISTORY
    history_list = get_history_from_dynamodb(target_table, session_id)

    # 3. START CHAT & STREAM
    try:
        chat = client.chats.create(
            model='gemini-2.0-flash', # Corrected model string
            history=history_list,
            config=types.GenerateContentConfig(
                system_instruction=system_instruction
            )
        )
        
        response_stream = chat.send_message_stream(question)
        full_response_text = ""

        for chunk in response_stream:
            if chunk.text:
                full_response_text += chunk.text
                
                # ✅ FIX: Change key from "chunk" to "text" to match Flutter
                payload = {
                    "type": "chat_stream",
                    "session_id": session_id,
                    "text": chunk.text,  # Use 'text' key
                    "is_done": False
                }

                try:
                    apigw.post_to_connection(
                        ConnectionId=connection_id,
                        Data=json.dumps(payload).encode("utf-8")
                    )
                except apigw.exceptions.GoneException:
                    logger.info("Connection gone.")
                    return 
                except Exception as e:
                    logger.error(f"APIGW Post Error: {e}")

        # Send "Done" Signal
        apigw.post_to_connection(
            ConnectionId=connection_id,
            Data=json.dumps({
                "type": "chat_stream",
                "session_id": session_id,
                "text": "",
                "is_done": True
            }).encode("utf-8")
        )

        # 4. SAVE AI RESPONSE TO DYNAMODB
        ai_message_id = f"MSG#{uuid.uuid4()}"
        timestamp_now = datetime.datetime.utcnow().isoformat()
        
        ai_msg_obj = {
            "message_id": ai_message_id,
            "role": "assistant",
            "content": full_response_text,
            "timestamp": timestamp_now
        }
        
        target_table.update_item(
            Key={'session_id': session_id},
            UpdateExpression="SET history = list_append(if_not_exists(history, :empty_list), :msg), last_updated = :t",
            ExpressionAttributeValues={
                ':msg': [ai_msg_obj],
                ':empty_list': [],
                ':t': timestamp_now
            }
        )

    except Exception as e:
        logger.error(f"AI Streaming Error: {e}")
        try:
            apigw.post_to_connection(
                ConnectionId=connection_id,
                Data=json.dumps({"type": "error", "text": "Chat failed."}).encode("utf-8")
            )
        except:
            pass

# --- MAIN ENTRY POINT ---
def lambda_handler(event, context):
    for record in event['Records']:
        try:
            message_body = json.loads(record['body'])
            job_type = message_body.get("job_type")

            if job_type == "JOB_WEEKLY_WORKOUT":
                generate_weekly_routine(message_body)
            
            elif job_type == "JOB_WEEKLY_MEAL_PLAN": 
                generate_weekly_meal_plan(message_body)

            elif job_type == "JOB_GENERATE_REFLECTION":
                generate_wellness_reflection(message_body)
            
            elif job_type == "JOB_CHAT_ANSWER":
                handle_chat_answer(message_body)
            
            else:
                logger.warning(f"Unknown job_type received: {job_type}")

        except Exception as e:
            logger.error(f"Worker Error processing record: {str(e)}")
            raise e