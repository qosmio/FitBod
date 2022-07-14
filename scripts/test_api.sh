#!/bin/bash
set -e

request() {
  curl -s -H 'Accept:application/json' \
    -H 'Content-Type: application/json' \
    -u "$LOGIN:$PASSWORD" \
    "$@"
}

mkdir -p spec/tmp

APP_URL=$(terraform output -raw app_url)
LOGIN="${LOGIN:-user1@fitbod.me}"
PASSWORD=$(terraform output -raw user1_pass)
USER_ID=$(request "$APP_URL/api/v1/users/" | jq -r '.[] | select(.email=="'"$LOGIN"'") | .id')
EXERCISE_ID=$(request "$APP_URL/api/v1/exercises" | jq '.[0].id')
EXERCISE_COUNT=$(request "$APP_URL/api/v1/exercises" | jq '. | length')

echo "Exercise Count: $EXERCISE_COUNT"
echo "USER_ID: $USER_ID"
echo "GET workouts:"

request "$APP_URL/api/v1/users/$USER_ID"/workouts | jq

echo "Creating workout"
cat <<EOF > spec/tmp/workout.json
{
  "workout": {
    "workout_duration": "30",
    "workout_date": "2018-06-02"
  }
}
EOF

WORKOUT_ID=$(request -X POST "$APP_URL/api/v1/users/$USER_ID"/workouts -d @spec/tmp/create_workout.json | jq -r '.id')
echo "Created WORKOUT_ID: $WORKOUT_ID"

echo "Creating single set:"
cat <<EOF >spec/tmp/create_single_set.json
{
  "single_set": {
    "reps": "30",
    "performed_at": "2018-06-02",
    "weight": 69,
    "exercise_id": $EXERCISE_ID,
    "workout_id": $WORKOUT_ID
  }
}
EOF

request -X POST "$APP_URL/api/v1/users/$USER_ID/workouts/$WORKOUT_ID"/single_sets -d @spec/tmp/create_single_set.json
echo ""
echo "=====>"
request "$APP_URL/api/v1/users/$USER_ID/workouts/$WORKOUT_ID"/single_sets | jq
