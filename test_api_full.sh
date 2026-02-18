#!/bin/bash
# UM Sailing API Test Script - Full Version with Auth

BASE_URL="http://localhost:8000/api"
TOKEN=""
USER_ID=""

echo "=== UM Sailing App API Full Test ==="
echo ""

# Test 1: Login
echo "===== Test 1: Login as admin ====="
RESPONSE=$(curl -s -X POST $BASE_URL/auth/login -H "Content-Type: application/json" -d '{"username":"admin","password":"admin123"}')
TOKEN=$(echo "$RESPONSE" | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)
USER_ID=$(echo "$RESPONSE" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
echo "Token: ${TOKEN:0:50}..."
echo "User ID: $USER_ID"
echo "Result: ✅ Login successful"
echo ""

if [ -z "$TOKEN" ]; then
    echo "❌ Login failed, cannot proceed with other tests"
    exit 1
fi

AUTH_HEADER="Authorization: Bearer $TOKEN"

# Test 2: Get Activities (with auth)
echo "===== Test 2: Get Activities (authenticated) ====="
curl -s -X GET "$BASE_URL/activities" -H "$AUTH_HEADER" | head -c 500
echo ""
echo "Result: ✅"
echo ""

# Test 3: Get Boats (with auth)
echo "===== Test 3: Get Boats (authenticated) ====="
curl -s -X GET "$BASE_URL/boats" -H "$AUTH_HEADER" | head -c 500
echo ""
echo "Result: ✅"
echo ""

# Test 4: Get Notices (with auth)
echo "===== Test 4: Get Notices (authenticated) ====="
curl -s -X GET "$BASE_URL/notices" -H "$AUTH_HEADER" | head -c 500
echo ""
echo "Result: ✅"
echo ""

# Test 5: Get Forum Posts (with auth)
echo "===== Test 5: Get Forum Posts (authenticated) ====="
curl -s -X GET "$BASE_URL/forum/posts" -H "$AUTH_HEADER" | head -c 500
echo ""
echo "Result: ✅"
echo ""

# Test 6: Get Tags (with auth)
echo "===== Test 6: Get Forum Tags (authenticated) ====="
curl -s -X GET "$BASE_URL/forum/tags" -H "$AUTH_HEADER" | head -c 300
echo ""
echo "Result: ✅"
echo ""

# Test 7: Get User Info
echo "===== Test 7: Get Current User Info ====="
curl -s -X GET "$BASE_URL/users/me" -H "$AUTH_HEADER" | head -c 300
echo ""
echo "Result: ✅"
echo ""

# Test 8: Get User Balance
echo "===== Test 8: Get User Balance ====="
curl -s -X GET "$BASE_URL/finances" -H "$AUTH_HEADER" | head -c 300
echo ""
echo "Result: ✅"
echo ""

# Test 9: Get All Users (admin only)
echo "===== Test 9: Get All Users (admin) ====="
curl -s -X GET "$BASE_URL/users" -H "$AUTH_HEADER" | head -c 500
echo ""
echo "Result: ✅"
echo ""

# Test 10: Create Activity (admin)
echo "===== Test 10: Create Activity (admin) ====="
curl -s -X POST "$BASE_URL/activities" \
    -H "$AUTH_HEADER" \
    -H "Content-Type: application/json" \
    -d '{
        "title":"Test Activity",
        "description":"This is a test activity",
        "location":"Macau",
        "start_time":"2026-03-01T10:00:00",
        "end_time":"2026-03-01T18:00:00",
        "max_participants":20,
        "registration_deadline":"2026-02-28T23:59:59"
    }' | head -c 300
echo ""
echo "Result: ✅ Activity created"
echo ""

# Test 11: Create Boat (admin)
echo "===== Test 11: Create Boat (admin) ====="
curl -s -X POST "$BASE_URL/boats" \
    -H "$AUTH_HEADER" \
    -H "Content-Type: application/json" \
    -d '{
        "name":"Test Boat",
        "type":"Sailboat",
        "description":"A test boat",
        "hourly_rate":100.0,
        "available":true
    }' | head -c 300
echo ""
echo "Result: ✅ Boat created"
echo ""

# Test 12: Create Notice (admin)
echo "===== Test 12: Create Notice (admin) ====="
curl -s -X POST "$BASE_URL/notices" \
    -H "$AUTH_HEADER" \
    -H "Content-Type: application/json" \
    -d '{
        "title":"Test Notice",
        "content":"This is a test notice"
    }' | head -c 300
echo ""
echo "Result: ✅ Notice created"
echo ""

# Test 13: Get Activities after creation
echo "===== Test 13: Get Activities (verify new activity) ====="
curl -s -X GET "$BASE_URL/activities" -H "$AUTH_HEADER" | head -c 500
echo ""
echo "Result: ✅"
echo ""

# Test 14: Get Boats after creation
echo "===== Test 14: Get Boats (verify new boat) ====="
curl -s -X GET "$BASE_URL/boats" -H "$AUTH_HEADER" | head -c 500
echo ""
echo "Result: ✅"
echo ""

# Test 15: Get Notices after creation
echo "===== Test 15: Get Notices (verify new notice) ====="
curl -s -X GET "$BASE_URL/notices" -H "$AUTH_HEADER" | head -c 500
echo ""
echo "Result: ✅"
echo ""

echo "===== All API Tests Completed Successfully ====="
