import boto3
import json
import uuid
import datetime
import os
import logging
from decimal import Decimal
from boto3.dynamodb.conditions import Key

# --- CONFIGURATION ---
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# 1. SETUP CLIENTS
sqs = boto3.client("sqs", region_name="us-east-2")
dynamodb = boto3.resource("dynamodb", region_name="us-east-2")

# 2. CONFIG VARS
QUEUE_URL = "https://sqs.us-east-2.amazonaws.com/720691795787/FitnessJobQueue"
EXERCISE_TABLE_NAME = "Exercise_Routine"
MEAL_TABLE_NAME = "Meal_Routine"
WELLNESS_TABLE_NAME = "Wellness"
REFLECTION_TABLE_NAME = "Reflections"
FIRST_AID_BOT_TABLE_NAME = 'FirstAid_Bot'
WELLNESS_BOT_TABLE_NAME = 'Wellness_Bot'
USER_TABLE_NAME = "Users"

# 3. TABLE RESOURCES
user_table = dynamodb.Table(USER_TABLE_NAME)
exercise_table = dynamodb.Table(EXERCISE_TABLE_NAME)
meal_table = dynamodb.Table(MEAL_TABLE_NAME)
wellness_table = dynamodb.Table(WELLNESS_TABLE_NAME)
reflection_table = dynamodb.Table(REFLECTION_TABLE_NAME)
first_aid_table = dynamodb.Table(FIRST_AID_BOT_TABLE_NAME)
wellness_bot_table = dynamodb.Table(WELLNESS_BOT_TABLE_NAME)



def decimal_default(obj):
    if isinstance(obj, Decimal):
        # Convert to int if it's a whole number, otherwise float
        return int(obj) if obj % 1 == 0 else float(obj)
    raise TypeError



# --- HELPERS ---
def convert_floats_to_decimals(obj):
    """DynamoDB requires Decimals instead of Floats."""
    if isinstance(obj, float):
        return Decimal(str(obj))
    elif isinstance(obj, dict):
        return {k: convert_floats_to_decimals(v) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [convert_floats_to_decimals(i) for i in obj]
    return obj

class DecimalEncoder(json.JSONEncoder):
    """Helper to serialize Decimal objects back to float for JSON response."""
    def default(self, obj):
        if isinstance(obj, Decimal):
            return float(obj)
        return super(DecimalEncoder, self).default(obj)


# --- MAIN HANDLER ---
def lambda_handler(event, context):
    try:
        # --- PARSING ---
        if "body" in event:
            body = json.loads(event["body"]) if isinstance(event["body"], str) else event["body"]
        else:
            body = event
            
        event_type = body.get("event_type")
        
        # ====================================================
        #  SECTION 1: USER MANAGEMENT
        # ====================================================
        
        if event_type == "sign_in":
            email = body.get("email")
            password = body.get("password")
            
            if not email or not password:
                return {"statusCode": 400, "body": json.dumps({"error": "Missing email or password"})}

            user_profile = {
                "email": email,  # PARTITION KEY
                "password": password, 
                "name": body.get("name"),
                "age": body.get("age"),
                "weight": body.get("weight"),
                "height": body.get("height"),
                "conditions": body.get("conditions", []),
                "fitness_goals": body.get("fitness_goals", []),
                "nutritional_goals": body.get("nutritional_goals", []),
                "created_at": datetime.datetime.utcnow().isoformat(),
                "last_login": datetime.datetime.utcnow().isoformat()
            }
            
            user_table.put_item(Item=convert_floats_to_decimals(user_profile))
            
            return {
                "statusCode": 200, 
                "body": json.dumps({"message": "User created successfully", "email": email})
            }

        elif event_type == "log_in":
            email_attempt = body.get("email")
            password_attempt = body.get("password")
            
            if not email_attempt or not password_attempt:
                return {"statusCode": 400, "body": json.dumps({"error": "Missing email or password"})}

            try:
                # 1. Direct lookup using email
                response = user_table.get_item(Key={'email': email_attempt})
                user_data = response.get('Item')

                # 2. Check if user exists
                if not user_data:
                    return {"statusCode": 404, "body": json.dumps({"error": "No account found with this email"})}

                # 3. Check password 
                if user_data.get("password") != password_attempt:
                    return {"statusCode": 401, "body": json.dumps({"error": "Incorrect password"})}

                # 4. Success - Update last login
                user_table.update_item(
                    Key={'email': email_attempt},
                    UpdateExpression="SET last_login = :t",
                    ExpressionAttributeValues={":t": datetime.datetime.utcnow().isoformat()}
                )

                user_data.pop("password", None)
                return {
                    "statusCode": 200, 
                    "body": json.dumps(user_data, cls=DecimalEncoder)
                }

            except Exception as e:
                logger.error(f"Login Error: {str(e)}")
                return {"statusCode": 500, "body": json.dumps({"error": "Internal server error during login"})}

        # ====================================================
        #  SECTION 2: EXERCISE ROUTINES (UUID Generated)
        # ====================================================
        elif event_type == "check_routine_status":
            routine_id = body.get("routine_id")
            if not routine_id: return {"statusCode": 400, "body": json.dumps({"error": "Missing routine_id"})}
            
            response = exercise_table.get_item(Key={'routine_id': routine_id})
            item = response.get('Item')
            
            if not item: return {"statusCode": 404, "body": json.dumps({"error": "Routine not found"})}
            return {"statusCode": 200, "body": json.dumps(item, cls=DecimalEncoder)}

        elif event_type == "generate_weekly_routine":
            user_id = body.get("user_id") 
            if not user_id: return {"statusCode": 400, "body": json.dumps({"error": "Missing user_id"})}

            # [UUID] Generated here
            routine_id = f"ROUTINE#{str(uuid.uuid4())}"
            timestamp = datetime.datetime.utcnow().isoformat()

            initial_item = {
                "routine_id": routine_id,
                "user_id": user_id,
                "status": "PROCESSING",
                "created_at": timestamp,
                "event_type": event_type
            }
            exercise_table.put_item(Item=initial_item)

            sqs_payload = {
                "job_type": "JOB_WEEKLY_WORKOUT",
                "routine_id": routine_id,
                "user_id": user_id,
                "user_request": body 
            }
            sqs.send_message(QueueUrl=QUEUE_URL, MessageBody=json.dumps(sqs_payload))

            return {"statusCode": 202, "body": json.dumps({"message": "Started", "routine_id": routine_id, "status": "PROCESSING"})}

        elif event_type == "create_manual_routine":
            user_id = body.get("user_id")
            weekly_schedule = body.get("weekly_schedule")
            # ✅ 1. Extract Title (Default to 'My Manual Routine')
            title = body.get("title", "My Manual Routine")
            routine_summary = body.get("routine_summary", "Manual Routine")
            
            if not user_id or not weekly_schedule: 
                return {"statusCode": 400, "body": json.dumps({"error": "Missing data"})}

            # [UUID] Generated here
            routine_id = f"ROUTINE#{str(uuid.uuid4())}"
            timestamp = datetime.datetime.utcnow().isoformat()

            manual_item = {
                "routine_id": routine_id,
                "user_id": user_id,
                "status": "COMPLETED", 
                "created_at": timestamp,
                "generation_type": "manual_entry",
                "title": title,  # ✅ 2. Save Title to DB
                "routine_summary": routine_summary,
                "weekly_schedule": weekly_schedule
            }
            
            # Ensure float conversion if necessary (good practice)
            exercise_table.put_item(Item=convert_floats_to_decimals(manual_item))
            
            return {
                "statusCode": 200, 
                "body": json.dumps({
                    "message": "Saved", 
                    "routine_id": routine_id, 
                    "status": "COMPLETED"
                })
            }

        # ====================================================
        #  SECTION 3: MEAL PLANS (UUID Generated)
        # ====================================================
        elif event_type == "generate_weekly_meal_plan":
            user_id = body.get("user_id") 
            primary_goal = body.get("primary_goal", "Unknown")
            diet_type = body.get("diet_type", "Standard")

            if not user_id: return {"statusCode": 400, "body": json.dumps({"error": "Missing user_id"})}

            # [UUID] Generated here
            meal_routine_id = f"MEAL#{str(uuid.uuid4())}"
            timestamp = datetime.datetime.utcnow().isoformat()

            initial_item = {
                "meal_routine_id": meal_routine_id, 
                "user_id": user_id,
                "status": "PROCESSING",
                "created_at": timestamp,
                "event_type": event_type,
                "primary_goal": primary_goal,
                "diet_type": diet_type
            }
            meal_table.put_item(Item=initial_item)

            sqs_payload = {
                "job_type": "JOB_WEEKLY_MEAL_PLAN",
                "meal_routine_id": meal_routine_id,
                "user_id": user_id,
                "user_request": body 
            }
            sqs.send_message(QueueUrl=QUEUE_URL, MessageBody=json.dumps(sqs_payload))

            return {"statusCode": 202, "body": json.dumps({"message": "Meal plan generation started", "meal_routine_id": meal_routine_id, "status": "PROCESSING"})}

        elif event_type == "check_meal_plan_status":
            meal_routine_id = body.get("meal_routine_id")
            if not meal_routine_id: return {"statusCode": 400, "body": json.dumps({"error": "Missing meal_routine_id"})}

            response = meal_table.get_item(Key={'meal_routine_id': meal_routine_id})
            item = response.get('Item')

            if not item: return {"statusCode": 404, "body": json.dumps({"error": "Meal plan not found"})}
            return {"statusCode": 200, "body": json.dumps(item, cls=DecimalEncoder)}

        elif event_type == "create_manual_meal_plan":
            user_id = body.get("user_id")
            weekly_meals = body.get("weekly_meals") 
            plan_summary = body.get("plan_summary", "Manual Meal Plan")

            if not user_id or not weekly_meals: 
                return {"statusCode": 400, "body": json.dumps({"error": "Missing user_id or weekly_meals"})}

            # [UUID] Generated here
            meal_routine_id = f"MEAL#{str(uuid.uuid4())}"
            timestamp = datetime.datetime.utcnow().isoformat()

            manual_item = {
                "meal_routine_id": meal_routine_id,
                "user_id": user_id,
                "status": "COMPLETED",
                "created_at": timestamp,
                "generation_type": "manual_entry",
                "plan_summary": plan_summary,
                "weekly_meals": weekly_meals
            }
            meal_table.put_item(Item=manual_item)
            return {"statusCode": 200, "body": json.dumps({"message": "Manual meal plan saved", "meal_routine_id": meal_routine_id, "status": "COMPLETED"})}
        
        # ====================================================
        #  SECTION 4: WELLNESS JOURNAL (Date-Based ID)
        # ====================================================
        elif event_type == "mood_log":
            user_id = body.get("user_id") 
            payload = body.get("payload")
            
            if not user_id or not payload:
                return {"statusCode": 400, "body": json.dumps({"error": "Missing user_id or payload"})}

            # [NOTE] Keeping Date-based ID to ensure one entry per day (Idempotency)
            current_date = datetime.datetime.utcnow().strftime('%Y-%m-%d')
            journal_id = f"JOURNAL#{user_id}#{current_date}"
            timestamp = datetime.datetime.utcnow().isoformat()

            try:
                wellness_table.update_item(
                    Key={'journal_id': journal_id},
                    UpdateExpression="""
                        SET mood_data = :m, 
                            user_id = :u, 
                            entry_date = :d, 
                            log_type = :l, 
                            created_at = if_not_exists(created_at, :t),
                            sleep_data = if_not_exists(sleep_data, :empty),
                            adherence_data = if_not_exists(adherence_data, :empty)
                    """,
                    ExpressionAttributeValues={
                        ':m': {
                            "mood_id": payload.get("mood_id"),
                            "mood": payload.get("mood"),
                            "score": payload.get("score"),
                            "note": payload.get("note"),
                            "timestamp": timestamp 
                        },
                        ':u': user_id,
                        ':d': current_date,
                        ':l': "daily_journal",
                        ':t': timestamp,
                        ':empty': {} 
                    },
                    ReturnValues="UPDATED_NEW"
                )
                return {"statusCode": 200, "body": json.dumps({"message": "Daily mood updated successfully", "journal_id": journal_id, "date": current_date})}
            except Exception as e:
                logger.error(f"Error updating mood: {str(e)}")
                return {"statusCode": 500, "body": json.dumps({"error": str(e)})}
            
        elif event_type == "log_adherence":
            user_id = body.get("user_id")
            raw_payload = body.get("payload")
            
            if not user_id or not raw_payload:
                return {"statusCode": 400, "body": json.dumps({"error": "Missing data"})}

            payload = convert_floats_to_decimals(raw_payload)

            # [NOTE] Keeping Date-based ID to ensure one entry per day
            current_date = datetime.datetime.utcnow().strftime('%Y-%m-%d')
            journal_id = f"JOURNAL#{user_id}#{current_date}" 
            timestamp = datetime.datetime.utcnow().isoformat()

            sleep_payload = payload.pop("sleep", None) 
            adherence_payload = payload 

            update_expr = """
                SET user_id = :u, 
                    entry_date = :d, 
                    last_updated = :t,
                    created_at = if_not_exists(created_at, :t),
                    mood_data = if_not_exists(mood_data, :empty),
                    adherence_data = :a
            """
            
            expr_values = {
                ':u': user_id,
                ':d': current_date,
                ':t': timestamp,
                ':empty': {},
                ':a': adherence_payload 
            }

            if sleep_payload:
                update_expr += ", sleep_data = :s"
                expr_values[':s'] = sleep_payload
            else:
                update_expr += ", sleep_data = if_not_exists(sleep_data, :empty)"

            try:
                wellness_table.update_item(
                    Key={'journal_id': journal_id}, 
                    UpdateExpression=update_expr,
                    ExpressionAttributeValues=expr_values,
                    ReturnValues="UPDATED_NEW"
                )
                return {
                    "statusCode": 200, 
                    "body": json.dumps({
                        "message": "Daily log updated successfully", 
                        "id": journal_id,
                        "includes_sleep": bool(sleep_payload)
                    }, cls=DecimalEncoder)
                }
            except Exception as e:
                logger.error(f"Daily Log Error: {str(e)}")
                return {"statusCode": 500, "body": json.dumps({"error": str(e)})}

        # ====================================================
        #  SECTION 5: REFLECTIONS (Linked to Journal ID)
        # ====================================================
        elif event_type == "generate_wellness_reflection":
            user_id = body.get("user_id")
            journal_id = body.get("journal_id")
            
            if not user_id or not journal_id:
                return {"statusCode": 400, "body": json.dumps({"error": "Missing user_id or journal_id"})}

            # [NOTE] Mirroring Journal ID to keep them linked
            reflection_id = journal_id.replace("JOURNAL#", "REFLECTION#")

            reflection_table.put_item(
                Item={
                    "reflection_id": reflection_id, 
                    "journal_id": journal_id, 
                    "user_id": user_id,
                    "status": "PROCESSING",
                    "created_at": datetime.datetime.utcnow().isoformat()
                }
            )

            sqs.send_message(
                QueueUrl=QUEUE_URL,
                MessageBody=json.dumps({
                    "job_type": "JOB_GENERATE_REFLECTION",
                    "user_id": user_id,
                    "journal_id": journal_id,
                    "reflection_id": reflection_id
                })
            )
            
            return {"statusCode": 202, "body": json.dumps({"message": "Analyzing journal entry...", "reflection_id": reflection_id})}

        elif event_type == "check_reflection_status":
            reflection_id = body.get("reflection_id")
            if not reflection_id: return {"statusCode": 400, "body": json.dumps({"error": "Missing reflection_id"})}

            response = reflection_table.get_item(Key={'reflection_id': reflection_id})
            item = response.get('Item')

            if not item: return {"statusCode": 404, "body": json.dumps({"status": "NOT_FOUND"})}

            status = item.get("status")
            if status == "COMPLETED":
                return {"statusCode": 200, "body": json.dumps({"status": "COMPLETED", "data": item.get("payload")}, cls=DecimalEncoder)}
            elif status == "FAILED":
                 return {"statusCode": 500, "body": json.dumps({"status": "FAILED"})}
            else:
                return {"statusCode": 202, "body": json.dumps({"status": "PROCESSING"})}

        # ====================================================
        #  SECTION 6: CHAT BOT (UUID Generated)
        # ====================================================
        elif event_type == "ask_question":
            connection_id = body.get("connection_id")
            question = body.get("question")
            bot_type = body.get("bot_type") 

            # [UUID] GENERATE IDs if the frontend didn't send them
            session_id = body.get("session_id")
            if not session_id:
                 session_id = f"SESSION#{str(uuid.uuid4())}"

            message_id = body.get("message_id")
            if not message_id:
                 message_id = f"MSG#{str(uuid.uuid4())}"

            if not all([connection_id, question, bot_type]):
                return {"statusCode": 400, "body": json.dumps({"error": "Missing required fields (connection_id, question, bot_type)"})}

            target_table = first_aid_table if bot_type == "first_aid" else wellness_bot_table
            if bot_type not in ["first_aid", "wellness"]:
                return {"statusCode": 400, "body": json.dumps({"error": f"Invalid bot_type: {bot_type}"})}

            timestamp_now = datetime.datetime.utcnow().isoformat()
            user_msg_obj = {
                "message_id": message_id,
                "role": "user",
                "content": question,
                "timestamp": timestamp_now
            }

            try:
                target_table.update_item(
                    Key={'session_id': session_id},
                    UpdateExpression="SET history = list_append(if_not_exists(history, :empty_list), :msg), last_updated = :t",
                    ExpressionAttributeValues={
                        ':msg': [user_msg_obj],
                        ':empty_list': [],
                        ':t': timestamp_now
                    }
                )
            except Exception as e:
                print(f"Failed to save user message: {e}")

            sqs.send_message(
                QueueUrl=QUEUE_URL,
                MessageBody=json.dumps({
                    "job_type": "JOB_CHAT_ANSWER",
                    "connection_id": connection_id,
                    "session_id": session_id,
                    "question": question,
                    "message_id": message_id,
                    "bot_type": bot_type 
                })
            )

            # Return the Generated Session ID so frontend knows what to use next time
            return {
                "statusCode": 202, 
                "body": json.dumps({
                    "status": "processing", 
                    "session_id": session_id, 
                    "message_id": message_id
                })
            }

        elif event_type == "get_exercise_routine":
            user_id = body.get("user_id")
            if not user_id:
                return {
                    "statusCode": 400, 
                    "body": json.dumps({"error": "Missing user_id"})
                }

            try:
                # Querying the Global Secondary Index for Lumora routines
                response = exercise_table.query(
                    IndexName='email_id_index', 
                    KeyConditionExpression=Key('user_id').eq(user_id)
                )
                
                return {
                    "statusCode": 200, 
                    "body": json.dumps(
                        {"routines": response.get('Items', [])}, 
                        default=decimal_default # ✅ Handles Decimal serialization
                    )
                }
            except Exception as e:
                logger.error(f"DynamoDB Query Error for user {user_id}: {e}")
                return {
                    "statusCode": 500, 
                    "body": json.dumps({"error": "Internal Server Error"})
                }

        elif event_type == "get_meal_routine":
            user_id = body.get("user_id")
            if not user_id:
                return {
                    "statusCode": 400, 
                    "body": json.dumps({"error": "Missing user_id"})
                }

            try:
                # Querying the GSI 'meal_routine_index' as seen in your screenshot
                response = meal_table.query(
                    IndexName='meal_routine_index', 
                    KeyConditionExpression=Key('user_id').eq(user_id)
                )
                
                return {
                    "statusCode": 200, 
                    "body": json.dumps(
                        {"meals": response.get('Items', [])}, 
                        default=decimal_default # ✅ Prevents Decimal serialization errors
                    )
                }
            except Exception as e:
                logger.error(f"DynamoDB Query Error for meal user {user_id}: {e}")
                return {
                    "statusCode": 500, 
                    "body": json.dumps({"error": "Internal Server Error"})
                }

        elif event_type == "update_exercise":
            routine_id = body.get("routine_id")
            updates = body.get("payload", {}) # Dictionary of fields to change
            
            if not routine_id or not updates:
                return {"statusCode": 400, "body": json.dumps({"error": "Missing routine_id or payload"})}

            try:
                # Dynamically build the update expression
                update_expr = "SET " + ", ".join(f"#{k} = :{k}" for k in updates.keys())
                attr_names = {f"#{k}": k for k in updates.keys()}
                attr_values = {f":{k}": v for k, v in updates.items()}

                exercise_table.update_item(
                    Key={'routine_id': routine_id},
                    UpdateExpression=update_expr,
                    ExpressionAttributeNames=attr_names,
                    ExpressionAttributeValues=attr_values,
                    ReturnValues="UPDATED_NEW"
                )
                
                return {"statusCode": 200, "body": json.dumps({"message": "Exercise updated successfully"})}
            except Exception as e:
                logger.error(f"Update Error for exercise {routine_id}: {e}")
                return {"statusCode": 500, "body": json.dumps({"error": "Internal Server Error"})}

        elif event_type == "update_meal":
            # 1. Extract using your actual table key name
            meal_routine_id = body.get("meal_routine_id")
            updates = body.get("payload", {})
            
            # 2. Update the validation check
            if not meal_routine_id or not updates:
                return {
                    "statusCode": 400, 
                    "body": json.dumps({"error": "Missing meal_routine_id or payload"})
                }

            try:
                # Build dynamic update expressions
                update_expr = "SET " + ", ".join(f"#{k} = :{k}" for k in updates.keys())
                attr_names = {f"#{k}": k for k in updates.keys()}
                # Ensure Decimals are handled if your payload contains numbers
                attr_values = {f":{k}": v for k, v in updates.items()}

                # 3. Use 'meal_routine_id' in the Key dictionary
                meal_table.update_item(
                    Key={'meal_routine_id': meal_routine_id},
                    UpdateExpression=update_expr,
                    ExpressionAttributeNames=attr_names,
                    ExpressionAttributeValues=attr_values,
                    ReturnValues="UPDATED_NEW"
                )
                
                return {
                    "statusCode": 200, 
                    "body": json.dumps({"message": "Meal routine updated successfully"})
                }
            except Exception as e:
                logger.error(f"Update Error for meal {meal_routine_id}: {e}")
                return {
                    "statusCode": 500, 
                    "body": json.dumps({"error": "Internal Server Error"})
                }

        elif event_type == "queue_test":
             return {"statusCode": 200, "body": json.dumps({"status": "Queue Test OK"})}

        else:
            return {"statusCode": 400, "body": json.dumps({"error": f"Unknown event_type: {event_type}"})}

    except Exception as e:
        logger.error(f"Error: {str(e)}")
        return {"statusCode": 500, "body": json.dumps({"error": str(e)})}