import requests
import json

API_KEY = ""
BASE_URL = "https://www.googleapis.com/youtube/v3"
YT_CHANNEL_ID = "UC-lHJZR3Gqxm24_Vd_AJ5Yw"

def get_channel(channel_id):
    params = {
        'part': 'id,snippet,contentDetails,statistics',
        'id': channel_id,
        'key': API_KEY,
    }
    response = requests.get(f"{BASE_URL}/channels", params)
    initial = response.json()
    first_item = initial["items"][0]
    channel_id = first_item["id"]
    channel_details = first_item["contentDetails"]
    channel_overview = first_item["snippet"]
    channel_statistics = first_item["statistics"]

    description = channel_overview['description'][:10]
    description.replace("'", '')


    return (f"INSERT INTO CHANNEL VALUES ('{channel_id}', {channel_statistics['subscriberCount']}, '{channel_overview['publishedAt'][0:10]}', {channel_statistics['videoCount']}, '{channel_overview['title']}', '{description}');")

def get_latest_videos(channel_id, max_results=5):
    params = {
        'part': 'id',
        'channelId': channel_id,
        'maxResults': max_results,
        'order': 'date',
        'type': 'video',
        'key': API_KEY,
    }
    response = requests.get(f"{BASE_URL}/search", params)
    items = response.json().get('items', [])
    video_ids = [item['id']['videoId'] for item in items]
    sql = []
    for video in video_ids:
        sql.append(get_video(video))

    return sql


def get_video(video_id):
    params = {
        'part': 'snippet,statistics, contentDetails',
        'id': video_id,
        'key': API_KEY,
    }
    response = requests.get(f"{BASE_URL}/videos", params=params)
    items = response.json().get('items', [])

    v_snippet = items[0]["snippet"]
    v_stats = items[0]["statistics"]
    v_details = items[0]["contentDetails"]

    title = v_snippet['title'].replace("'", '')
    description = v_snippet['description'][0:25].replace("'", '')
    likes = v_stats.get('likeCount', 0)

    return (f"INSERT into VIDEO values ('{items[0]['id']}', '{v_snippet['channelId']}', '{title}', '{v_snippet['publishedAt'][0:10]}', {likes}, '{duration_to_hhmmss(v_details['duration'])}', {v_stats['viewCount']}, '{description}');")

    
def duration_to_hhmmss(duration):
    if not duration.startswith('PT'):
        return None 

    duration = duration[2:]

    hours, minutes, seconds = 0, 0, 0

    if 'H' in duration:
        hours_str, duration = duration.split('H')
        hours = int(hours_str)

    if 'M' in duration:
        minutes_str, duration = duration.split('M')
        minutes = int(minutes_str)

    if 'S' in duration:
        seconds_str, _ = duration.split('S')
        seconds = int(seconds_str)

    hhmmss = f"{hours:02d}:{minutes:02d}:{seconds:02d}"

    return hhmmss

def get_latest_playlist(channel_id, max_results=1):
    params = {
        'part': 'id',
        'channelId': channel_id,
        'maxResults': max_results,
        'order': 'date',
        'type': 'playlist',
        'key': API_KEY,
    }

    response = requests.get(f"{BASE_URL}/search", params)
    playlists = response.json().get('items', [])
    
    playlist_ids = [playlist['id']['playlistId'] for playlist in playlists]
    sql = []
    for playlist in playlist_ids:
        sql.append(get_playlist(playlist))
    return sql

def get_playlist_videos(playlist_id, max_results=50):
    params = {
        'part': 'snippet',
        'playlistId': playlist_id,
        'maxResults': max_results,
        'key': API_KEY,
    }

    response = requests.get(f"{BASE_URL}/playlistItems", params=params)
    items = response.json().get('items', [])

    playlist_videos = []

    for video in items:
        v_snippet = video['snippet']['resourceId']['videoId']
        playlist_videos.append(get_video(v_snippet))
    return playlist_videos

def get_playlist(playlist_id):
    params = {
        'part': 'snippet,contentDetails',
        'id': playlist_id,
        'key': API_KEY,
    }
    response = requests.get(f"{BASE_URL}/playlists", params)
    items = response.json().get('items', [])
    
    if not items:
        return None

    p_snippet = items[0]["snippet"]
    p_details = items[0]["contentDetails"]
    
    return (f"INSERT into PLAYLIST values ('{items[0]['id']}', '{p_snippet['channelId']}', '{p_snippet['title']}');")

def get_top_comments(video_id, max_results=5):
    params = {
        'part': 'snippet',
        'videoId': video_id,
        'maxResults': max_results,
        'key': API_KEY,
    }

    response = requests.get(f"{BASE_URL}/commentThreads", params=params)
    items = response.json().get('items', [])

    if not items:
        return None

    top_comments_sql = []

    for comment in items:
        snippet = comment['snippet']['topLevelComment']['snippet']
        comment_text = snippet.get('textDisplay', 'No text available')

        top_comments_sql.append(
            f"INSERT INTO COMMENT VALUES "
            f"({comment['id']}, {video_id}, '{snippet['authorChannelId']['value']}', "
            f"'{comment_text[:100]}', {snippet['likeCount']}, '{snippet['publishedAt'][0:10]}');"
        )

    return top_comments_sql


input_file_path = 'channelID40.txt'
output_file_path = 'video_output.txt'

try:
    with open(input_file_path, 'r', encoding='utf-8') as input_file, open(output_file_path, 'w', encoding='utf-8') as output_file:
        for channel_id in input_file:
            channel_id = channel_id.strip()  # Remove leading/trailing whitespaces
            results = get_latest_videos(channel_id)
            for result in results:
                print(result)
                output_file.write(result + '\n')
except FileNotFoundError:
    print(f"Error: The file '{input_file_path}' was not found.")
except Exception as e:
    print(f"An error occurred: {e}")




# channel = get_channel(YT_CHANNEL_ID)

# print(channel)

# playlists = get_latest_playlist(YT_CHANNEL_ID)

# for playlist in playlists:
#     print(playlist)

# videos = get_latest_videos(YT_CHANNEL_ID)

# for video in videos:
#     print(video)



