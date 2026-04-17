# Lunora Firestore Schema

## Naming Standard
- All field names use camelCase
- All document IDs use stable string IDs
- Timestamps use Firestore Timestamp
- Boolean fields start with is/has when meaningful

---

## Top-level Collections

### 1. users
Path:
`/users/{userId}`

Description:
Stores user profile and summary info.

Fields:
| Field | Type | Required | Description |
|------|------|----------|-------------|
| id | String | Yes | Firebase Auth user id |
| email | String | Yes | User email |
| displayName | String | No | Username |
| createdAt | Timestamp | Yes | Account creation date |
| updatedAt | Timestamp | Yes | Last update date |
| timezone | String | Yes | User timezone |
| onboardingCompleted | Bool | Yes | Whether onboarding is completed |
| currentActiveEnrollmentId | String | No | Current active program enrollment |
| totalCompletedPrograms | Int | No | Completed program count |
| totalEarnedBadges | Int | No | Earned badge count |

Example:
```json
{
  "id": "uid_123",
  "email": "test@example.com",
  "displayName": "Cagri",
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp",
  "timezone": "Europe/Istanbul",
  "onboardingCompleted": true,
  "currentActiveEnrollmentId": "enr_001",
  "totalCompletedPrograms": 2,
  "totalEarnedBadges": 2
}

{
  "id": "mindful_reset_21",
  "version": 1,
  "isActive": true,
  "title": "Mindful Reset",
  "summary": "A short awareness-building program.",
  "durationDays": 21,
  "difficultyLevel": 6,
  "difficultyScale": 10,
  "dailyDurationText": "10 minutes daily",
  "elements": ["AKASHA", "AIR"],
  "imageName": "program1",
  "badgeId": "badge_mindful_reset",
  "badgeDescription": "Awarded for completing the Mindful Reset program.",
  "completionRuleType": "strict_all_days",
  "minRequiredDays": 21,
  "allowMissedDays": 0,
  "allowRestart": true,
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
