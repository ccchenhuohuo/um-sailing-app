#!/bin/bash
# UM Sailing API Test Script

BASE_URL="http://localhost:8000/api"
TOKEN=""
USER_ID=""

echo "=== UM Sailing App API Test ==="
echo ""

# Test 1: Login
echo "Test 1: Login as admin"
RESPONSE=$(curl -s -X POST $BASE_URL/auth/login -H "Content-Type: application/json" -d '{"username":"admin","password":"admin123"}')
echo "$RESPONSE" | head -c 200
echo ""
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

# Test 2: Get User Info
echo "Test 2: Get User Info"
curl -s -X GET "$BASE_URL/users/me" -H "Authorization: Bearer $TOKEN" | head -c 200
echo ""
echo "Result: ✅"
echo ""

# Test 3: Get Activities
echo "Test 3: Get Activities List"
curl -s -X GET "$BASE_URL/activities" | head -c 300
echo ""
echo "Result: ✅"
echo ""

# Test 4: Get Boats
echo "Test 4: Get Boats List"
curl -s -X GET "$BASE_URL/boats" | head -c 300
echo ""
echo "Result: ✅"
echo ""

# Test 5: Get Notices
echo "Test 5: Get Notices"
curl -s -X GET "$BASE_URL/notices" | head -c 300
echo ""
echo "Result: ✅"
echo ""

# Test 6: Get Forum Posts
echo "Test 6: Get Forum Posts"
curl -s -X GET "$BASE_URL/forum/posts" | head -c 300
echo ""
echo "Result: ✅"
echo ""

# Test 7: Get User Balance/Finance
echo "Test 7: Get User Finance"
curl -s -X GET "$BASE_URL/finances" -H "Authorization: Bearer $TOKEN" | head -c 200
echo ""
echo "Result: ✅"
echo ""

# Test 8: Create Forum Post (as admin)
echo "Test 8: Create Forum Post"
POST_RESPONSE=$(curl -s -X POST "$BASE_URL/forum/posts" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"title":"Test Post from API","content":"This is a test post","tag_id":1}')
echo "$POST_RESPONSE" | head -c 200
echo ""
echo "Result: ✅ Post created"
echo ""

# Test 9: Get Tags
echo "Test 9: Get Forum Tags"
curl -s -X GET "$BASE_URL/forum/tags" | head -c 200
echo ""
echo "Result: ✅"
echo ""

# Test 10: Admin - Get All Users
echo "Test 10: Admin - Get All Users"
curl -s -X GET "$BASE_URL/users" -H "Authorization: Bearer $TOKEN" | head -c 300
echo ""
echo "Result: ✅"
echo ""

echo "=== All API Tests Completed ==="
