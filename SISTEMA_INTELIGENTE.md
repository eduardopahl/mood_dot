# 🧠 Intelligent Notification System

## 📋 Overview
MoodDot's notification system uses intelligence to personalize reminders based on real user behavior and data from the Hive database.

## 🎯 Intelligent Features

### 1. **Real Mood Entry Detection**
- ✅ Checks actual database entries for today
- ✅ Prevents spam by avoiding notifications when already logged
- ✅ Uses real Hive data instead of simulation

**Implementation:**
```dart
Future<bool> _hasRegisteredTodaysMood() async {
  final allEntries = await _moodRepository.getAllMoodEntries();
  final todayEntries = allEntries.where((entry) {
    final entryDate = entry.date;
    return entryDate.year == today.year &&
           entryDate.month == today.month &&
           entryDate.day == today.day;
  }).toList();
  
  return todayEntries.isNotEmpty;
}
```

### 2. **Adaptive Optimal Time**
- 🌅 **Morning** (before 12pm): Schedule for 6:30 PM
- 🌆 **Afternoon** (12pm-6pm): Schedule for 8:00 PM  
- 🌙 **Evening** (after 6pm): Schedule for 9:00 AM next day
- 🎯 **Pattern Learning**: Analyzes user's actual registration times

**Implementation:**
```dart
Future<TimeOfDay> _getOptimalNotificationTime() async {
  // Analyzes last 30 mood entries for patterns
  final hourCounts = <int, int>{};
  for (final entry in allEntries.take(30)) {
    final hour = entry.createdAt.hour;
    hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
  }
  
  // Schedules 2 hours before most common registration time
  int optimalHour = mostCommonHour - 2;
}
```

### 3. **Real Engagement Score (0.0-1.0)**
Calculates engagement based on 5 real metrics from Hive data:

#### **Metric 1: Frequency (30-day)**
- Counts actual entries in last 30 days
- `score = entries_count / 30`

#### **Metric 2: Consistency (14-day)**  
- Counts unique days with entries in last 14 days
- `score = unique_days / 14`

#### **Metric 3: Longevity**
- Time since first mood entry
- `score = months_using / 6` (6 months = max score)

#### **Metric 4: Emotional Diversity**
- Variety of mood levels used
- `score = unique_moods / 10` (10 levels max)

#### **Metric 5: Qualitative Engagement**
- Percentage of entries with notes
- `score = entries_with_notes / total_entries`

**Implementation:**
```dart
Future<double> _getUserEngagementScore() async {
  // 1. Frequency analysis
  double frequencyScore = (recentEntries.length / 30.0).clamp(0.0, 1.0);
  
  // 2. Consistency analysis
  double consistencyScore = (uniqueDays.length / 14.0).clamp(0.0, 1.0);
  
  // 3. Longevity analysis
  double longevityScore = (monthsUsing / 6.0).clamp(0.0, 1.0);
  
  // 4. Diversity analysis
  double varietyScore = (uniqueMoods.length / 10.0).clamp(0.0, 1.0);
  
  // 5. Notes usage analysis
  double notesScore = (entriesWithNotes / allEntries.length).clamp(0.0, 1.0);
  
  return (totalScore / factors).clamp(0.0, 1.0);
}
```

### 4. **Personalized Strategies**

#### 😊 **Low Engagement** (score < 0.3)
- **Approach**: Gentle and motivational
- **Frequency**: Spaced out, less intrusive
- **Messages**: "How are you feeling today? 😊"
- **Notification Channel**: `gentle_reminder`

#### 📱 **Moderate Engagement** (score 0.3-0.7) - **DEFAULT**
- **Approach**: Balanced and direct
- **Frequency**: Daily at optimal time
- **Messages**: Context-based (morning/afternoon/evening)
- **Notification Channel**: `standard_reminder`

#### 🚀 **High Engagement** (score > 0.7)
- **Approach**: Dynamic and energetic
- **Frequency**: Daily, may include insights
- **Messages**: "Time to log your mood! 🎯"
- **Notification Channel**: `active_reminder`

## 🔄 **Intelligent Learning Cycle**

### **Real-Time Analysis:**
1. **Database Query**: Fetches real mood entries from Hive
2. **Pattern Detection**: Analyzes registration times and frequency
3. **Score Calculation**: Computes engagement based on 5 real metrics
4. **Strategy Selection**: Chooses approach based on actual behavior
5. **Smart Scheduling**: Sets notifications based on real patterns

### **Continuous Learning:**
```dart
Future<void> learnFromUserBehavior({
  required bool respondedToNotification,
  required TimeOfDay responseTime,
}) async {
  if (respondedToNotification) {
    // Increases engagement score
    final newScore = (currentScore + 0.1).clamp(0.0, 1.0);
    
    // Saves preferred time (HHMM format)
    final timeInt = responseTime.hour * 100 + responseTime.minute;
    await prefs.setInt(_preferredTimeKey, timeInt);
  }
}
```

## 🛠️ **Technical Implementation**

### **1. Database Integration:**
```dart
class NotificationService {
  final MoodRepository _moodRepository;
  
  // Singleton with repository injection
  static NotificationService getInstance(MoodRepository repository) {
    _instance ??= NotificationService._internal(repository);
    return _instance!;
  }
}
```

### **2. Provider Setup:**
```dart
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final repository = ref.watch(moodRepositoryProvider);
  return NotificationService.getInstance(repository);
});
```

### **3. Integration with Mood Saving:**
```dart
// In MoodEntryNotifier.addMoodEntry()
await _repository.addMoodEntry(entry);
debugPrint('🎭 Mood saved - data available for intelligent system');
```

## 📊 **Real Data Analysis**

### **Example Engagement Calculation:**
```
User with 90 days of data:
├── Frequency: 25/30 days = 0.83
├── Consistency: 12/14 days = 0.86  
├── Longevity: 3/6 months = 0.50
├── Diversity: 8/10 moods = 0.80
├── Notes: 60/90 entries = 0.67
└── Final Score: 0.73 (High Engagement)

Strategy: 🚀 Active reminders with dynamic messages
```

## 🔮 **Smart Features**

### **1. Anti-Spam Protection:**
- Real-time database check prevents duplicate notifications
- No notification if mood already logged today

### **2. Pattern Recognition:**
- Identifies user's preferred registration times
- Adapts scheduling based on actual behavior

### **3. Progressive Enhancement:**
- New users start with gentle approach
- System becomes more sophisticated as data grows
- Long-term users get highly personalized experience

### **4. Error Resilience:**
- Graceful fallbacks if database queries fail
- Default scheduling ensures notifications always work

## 🎯 **Benefits**

- ✅ **Data-Driven**: All decisions based on real user behavior
- ✅ **Non-Intrusive**: Respects user patterns and prevents spam
- ✅ **Adaptive**: Improves with usage and learns preferences
- ✅ **Personalized**: Each user gets unique experience
- ✅ **Reliable**: Fallback mechanisms ensure system always works

## � **User Controls**

### **Settings Page:**
- **Main Toggle**: Enable/Disable intelligent reminders
- **Test Button**: Send immediate test notification
- **Reset AI**: Clear all learning data and start fresh

### **Smart Reset:**
```dart
Future<void> resetLearningSystem() async {
  await prefs.remove(_userEngagementKey);
  await prefs.remove(_preferredTimeKey);
  await prefs.remove(_lastNotificationKey);
  debugPrint('✅ System reset - back to defaults');
}
```

## 🚀 **Future Enhancements**

### **Advanced Analytics:**
- Mood correlation with notification response rates
- Seasonal pattern detection
- Stress level indicators

### **Contextual Intelligence:**
- Weather-based message adaptation
- Calendar integration for busy periods
- Location-based scheduling

### **Machine Learning:**
- Predictive modeling for optimal timing
- Sentiment analysis of mood notes
- Behavioral clustering for user types

---

**The MoodDot intelligent notification system transforms a simple reminder into a personalized, data-driven companion that truly understands and adapts to each user's unique emotional journey.** 🧠✨