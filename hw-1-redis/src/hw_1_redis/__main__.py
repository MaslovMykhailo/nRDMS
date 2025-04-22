from redis import Redis

host = "localhost"
port = 6379

redis_client = Redis(host=host, port=port, decode_responses=True)

[seconds, milliseconds] = redis_client.time()
print(f"Redis server time: {seconds} seconds, {milliseconds} microseconds.")

dt = float(f"{seconds}.{milliseconds}")
redis_client.set("dt", dt)

print("Redis server time set to key 'dt' in Redis.")